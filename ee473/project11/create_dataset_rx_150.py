#!/usr/bin/env python3
"""
create_dataset_rx150.py

Generate a dataset for RX-150 inverse kinematics using forward kinematics.

Each row of the CSV contains:
    q1_deg, q2_deg, q3_deg, q4_deg, q5_deg, x_mm, y_mm, z_mm

Joint angles are sampled uniformly within the RX-150 joint limits.

Usage examples:
    # default: 20000 samples -> rx150_dataset.csv
    python create_dataset_rx150.py

    # custom number of samples and output file
    python create_dataset_rx150.py --num-samples 50000 --output my_data.csv
"""

import argparse
import numpy as np

from forward_kinematics_rx150 import fk_rx150_deg

# RX-150 joint limits in DEGREES (from specs)
JOINT_MIN_DEG = np.array([-180.0, -106.0, -102.0, -100.0, -180.0])
JOINT_MAX_DEG = np.array([ 180.0,  100.0,   95.0,  123.0,  180.0])


def sample_joint_angles(num_samples: int, seed: int | None = 123) -> np.ndarray:
    """
    Uniformly sample joint angles within their limits.

    Parameters
    ----------
    num_samples : int
        Number of samples to generate.
    seed : int or None
        Random seed for reproducibility.

    Returns
    -------
    q_deg : (num_samples, 5) ndarray
        Sampled joint angles in degrees.
    """
    rng = np.random.default_rng(seed)
    mins = JOINT_MIN_DEG.reshape(1, 5)
    maxs = JOINT_MAX_DEG.reshape(1, 5)
    q_deg = mins + (maxs - mins) * rng.random((num_samples, 5))
    return q_deg


def create_dataset(num_samples: int,
                   output_path: str,
                   seed: int | None = 123) -> None:
    """
    Create the dataset and save as CSV.

    Parameters
    ----------
    num_samples : int
        Number of rows in the dataset.
    output_path : str
        Path to the output CSV file.
    seed : int or None
        Random seed for joint sampling.
    """
    q_samples = sample_joint_angles(num_samples, seed=seed)
    data = np.zeros((num_samples, 8), dtype=float)

    for i in range(num_samples):
        q = q_samples[i]               # (5,) joint angles in deg
        _, p = fk_rx150_deg(q)         # p = [x, y, z] in mm
        data[i, 0:5] = q
        data[i, 5:8] = p

    header = "q1_deg,q2_deg,q3_deg,q4_deg,q5_deg,x_mm,y_mm,z_mm"
    np.savetxt(output_path, data, delimiter=",", header=header, comments="")

    print(f"Saved dataset with {num_samples} samples to '{output_path}'")
    print("First 3 rows:")
    print(data[:3])


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate RX-150 FK dataset for IK neural network training."
    )
    parser.add_argument(
        "--num-samples",
        type=int,
        default=20000,
        help="Number of samples to generate (default: 20000)",
    )
    parser.add_argument(
        "--output",
        type=str,
        default="rx150_dataset.csv",
        help="Output CSV file path (default: rx150_dataset.csv)",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=123,
        help="Random seed for reproducibility (default: 123)",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    create_dataset(args.num_samples, args.output, seed=args.seed)


if __name__ == "__main__":
    main()
