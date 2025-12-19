import argparse
from dataclasses import dataclass

import numpy as np
import torch
from torch import nn
from torch.utils.data import Dataset, DataLoader, random_split


# -----------------------------
# Dataset
# -----------------------------

class Rx150IKDataset(Dataset):
    """
    Dataset for RX150 IK:
    Inputs:  x, y, z  (Cartesian position, in meters)
    Targets: [sin(theta_i), cos(theta_i)] for i=1..5
    Angles are read from CSV in degrees and converted to radians internally.
    """

    def __init__(self, csv_path: str):
        # Assumes CSV columns: q1_deg,q2_deg,q3_deg,q4_deg,q5_deg,x_mm,y_mm,z_mm
        data = np.loadtxt(csv_path, delimiter=",", skiprows=1)
        q_deg = data[:, 0:5]
        xyz_mm = data[:, 5:8]

        # Convert mm to meters for better numerical scaling
        xyz_m = xyz_mm / 1000.0

        # Inputs in original (unnormalized) units
        self.x = xyz_m.astype(np.float32)

        # Convert outputs from deg -> rad
        q_rad = np.deg2rad(q_deg).astype(np.float32)

        # Compute sin/cos for each joint
        sin_q = np.sin(q_rad)
        cos_q = np.cos(q_rad)
        self.y = np.concatenate([sin_q, cos_q], axis=1).astype(np.float32)  # shape (N, 10)

        # Precompute input normalization stats (for whole dataset)
        self.x_mean = self.x.mean(axis=0, keepdims=True)
        self.x_std = self.x.std(axis=0, keepdims=True)
        self.x_std[self.x_std < 1e-8] = 1.0  # avoid divide-by-zero

    def __len__(self):
        return self.x.shape[0]

    def __getitem__(self, idx):
        return self.x[idx], self.y[idx]


# -----------------------------
# Model
# -----------------------------

class MLP(nn.Module):
    def __init__(self, in_dim=3, out_dim=10, hidden_dims=(256, 256, 256)):
        super().__init__()
        layers = []
        prev = in_dim
        for h in hidden_dims:
            layers.append(nn.Linear(prev, h))
            layers.append(nn.ReLU())
            prev = h
        layers.append(nn.Linear(prev, out_dim))
        self.net = nn.Sequential(*layers)

    def forward(self, x):
        return self.net(x)


# -----------------------------
# Training utilities
# -----------------------------

@dataclass
class NormStats:
    x_mean: np.ndarray
    x_std: np.ndarray
    # keep y_mean, y_std for compatibility, even if unused
    y_mean: np.ndarray
    y_std: np.ndarray


def compute_norm_stats(dataset: Rx150IKDataset) -> NormStats:
    x_mean = dataset.x_mean
    x_std = dataset.x_std
    y_mean = dataset.y.mean(axis=0, keepdims=True)
    y_std = dataset.y.std(axis=0, keepdims=True)
    y_std[y_std < 1e-8] = 1.0
    return NormStats(x_mean=x_mean, x_std=x_std, y_mean=y_mean, y_std=y_std)


def save_norm_stats(norm_stats: NormStats, path: str):
    np.savez(
        path,
        x_mean=norm_stats.x_mean,
        x_std=norm_stats.x_std,
        y_mean=norm_stats.y_mean,
        y_std=norm_stats.y_std,
    )


def angle_from_sin_cos(sin_vals: np.ndarray, cos_vals: np.ndarray) -> np.ndarray:
    """
    sin_vals, cos_vals: shape (N, 5)
    Returns angles in radians, shape (N, 5)
    """
    return np.arctan2(sin_vals, cos_vals)


def evaluate_model(model, dataloader, norm_stats: NormStats, device="cpu"):
    model.eval()
    all_pred_sin_cos = []
    all_true_sin_cos = []

    x_mean = torch.from_numpy(norm_stats.x_mean).to(device)
    x_std = torch.from_numpy(norm_stats.x_std).to(device)

    with torch.no_grad():
        for xb, yb in dataloader:
            xb = xb.to(device)
            yb = yb.to(device)

            # normalize inputs ONCE here, consistent with training
            xb_norm = (xb - x_mean) / x_std

            preds = model(xb_norm)
            all_pred_sin_cos.append(preds.cpu().numpy())
            all_true_sin_cos.append(yb.cpu().numpy())

    pred_sin_cos = np.concatenate(all_pred_sin_cos, axis=0)  # (N, 10)
    true_sin_cos = np.concatenate(all_true_sin_cos, axis=0)

    pred_sin = pred_sin_cos[:, 0:5]
    pred_cos = pred_sin_cos[:, 5:10]
    true_sin = true_sin_cos[:, 0:5]
    true_cos = true_sin_cos[:, 5:10]

    # Convert sin/cos to angles (rad)
    pred_angles_rad = angle_from_sin_cos(pred_sin, pred_cos)
    true_angles_rad = angle_from_sin_cos(true_sin, true_cos)

    # Convert to degrees for reporting
    pred_deg = np.rad2deg(pred_angles_rad)
    true_deg = np.rad2deg(true_angles_rad)

    diff = pred_deg - true_deg
    mae_per_joint = np.mean(np.abs(diff), axis=0)
    rmse_per_joint = np.sqrt(np.mean(diff ** 2, axis=0))

    overall_mae = mae_per_joint.mean()
    overall_rmse = rmse_per_joint.mean()

    return mae_per_joint, rmse_per_joint, overall_mae, overall_rmse


def train(
    csv_path: str,
    output_model_path: str = "rx150_ik_model.pt",
    output_norm_path: str = "rx150_ik_norm_stats.npz",
    batch_size: int = 256,
    lr: float = 1e-3,
    max_epochs: int = 200,
    val_ratio: float = 0.1,
    test_ratio: float = 0.1,
    hidden_dims=(256, 256, 256),
    device: str = None,
):

    if device is None:
        device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Using device: {device}")

    full_dataset = Rx150IKDataset(csv_path)
    norm_stats = compute_norm_stats(full_dataset)

    n_total = len(full_dataset)
    n_test = int(n_total * test_ratio)
    n_val = int(n_total * val_ratio)
    n_train = n_total - n_val - n_test

    train_dataset, val_dataset, test_dataset = random_split(
        full_dataset, [n_train, n_val, n_test],
        generator=torch.Generator().manual_seed(42)
    )

    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=batch_size)
    test_loader = DataLoader(test_dataset, batch_size=batch_size)

    model = MLP(in_dim=3, out_dim=10, hidden_dims=hidden_dims).to(device)
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    criterion = nn.MSELoss()

    x_mean = torch.from_numpy(norm_stats.x_mean).to(device)
    x_std = torch.from_numpy(norm_stats.x_std).to(device)

    best_val_loss = float("inf")
    best_state_dict = None
    patience = 20
    epochs_no_improve = 0

    for epoch in range(1, max_epochs + 1):
        # -----------------
        # Train
        # -----------------
        model.train()
        running_loss = 0.0
        for xb, yb in train_loader:
            xb = xb.to(device)
            yb = yb.to(device)

            xb_norm = (xb - x_mean) / x_std

            optimizer.zero_grad()
            preds = model(xb_norm)
            loss = criterion(preds, yb)
            loss.backward()
            optimizer.step()
            running_loss += loss.item() * xb.size(0)

        train_loss = running_loss / n_train

        # -----------------
        # Validation
        # -----------------
        model.eval()
        val_loss = 0.0
        with torch.no_grad():
            for xb, yb in val_loader:
                xb = xb.to(device)
                yb = yb.to(device)

                xb_norm = (xb - x_mean) / x_std
                preds = model(xb_norm)
                loss = criterion(preds, yb)
                val_loss += loss.item() * xb.size(0)
        val_loss /= n_val

        print(f"Epoch {epoch:03d}: train_loss={train_loss:.6f}, val_loss={val_loss:.6f}")

        # Early stopping
        if val_loss < best_val_loss - 1e-5:
            best_val_loss = val_loss
            best_state_dict = model.state_dict()
            epochs_no_improve = 0
        else:
            epochs_no_improve += 1
            if epochs_no_improve >= patience:
                print("Early stopping triggered.")
                break

    if best_state_dict is not None:
        model.load_state_dict(best_state_dict)

    # -----------------
    # Final test evaluation
    # -----------------
    mae_per_joint, rmse_per_joint, overall_mae, overall_rmse = evaluate_model(
        model, test_loader, norm_stats, device=device
    )

    print("\nTest performance in degrees (after sin/cos decoding):")
    print(f"MAE per joint: {mae_per_joint}")
    print(f"RMSE per joint: {rmse_per_joint}")
    print(f"Overall MAE (deg): {overall_mae}")
    print(f"Overall RMSE (deg): {overall_rmse}")

    # -----------------
    # Save model and norm stats
    # -----------------
    torch.save({
        "model_state_dict": model.state_dict(),
        "input_dim": 3,
        "output_dim": 10,
        "hidden_dims": hidden_dims,
    }, output_model_path)
    print(f"Saved model to {output_model_path}")

    save_norm_stats(norm_stats, output_norm_path)
    print(f"Saved normalization stats to {output_norm_path}")


def main():
    parser = argparse.ArgumentParser(description="Train NN IK model for RX150 using sin/cos outputs.")
    parser.add_argument("--data", type=str, default="rx150_dataset.csv",
                        help="Path to dataset CSV")
    parser.add_argument("--model-out", type=str, default="rx150_ik_model.pt",
                        help="Output path for trained model")
    parser.add_argument("--norm-out", type=str, default="rx150_ik_norm_stats.npz",
                        help="Output path for norm stats")
    parser.add_argument("--batch-size", type=int, default=256)
    parser.add_argument("--lr", type=float, default=1e-3)
    parser.add_argument("--epochs", type=int, default=200)
    parser.add_argument("--val-ratio", type=float, default=0.1)
    parser.add_argument("--test-ratio", type=float, default=0.1)
    args = parser.parse_args()

    train(
        csv_path=args.data,
        output_model_path=args.model_out,
        output_norm_path=args.norm_out,
        batch_size=args.batch_size,
        lr=args.lr,
        max_epochs=args.epochs,
        val_ratio=args.val_ratio,
        test_ratio=args.test_ratio,
    )


if __name__ == "__main__":
    main()
