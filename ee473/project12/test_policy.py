#!/usr/bin/env python3
"""test_policy.py

Load a trained DQN policy for RX-150 IK and evaluate it in RX150IKEnv.

In addition to basic RL evaluation, this script also compares the
final policy-generated joint angles to an analytical IK solution
(from Project 11) for the SAME target pose.

It uses:
    - inverse_kinematics_rx150.ik_rx150_pos()
    - forward_kinematics_rx150.fk_rx150_deg()

Units:
    - RX150IKEnv reports positions in METERS.
    - The analytical FK/IK functions use MILLIMETERS at their interface.
      This script converts between meters and millimeters as needed.

Default usage (from project root):
    # Using best model saved by train_dqn.py
    python3 src/test_policy.py --model models/best/dqn_ik_checkpoint_best_model.zip

    # Using final model
    python3 src/test_policy.py --model models/dqn_ik_final.zip --episodes 20 --render
"""

from __future__ import annotations

import argparse
import os
from typing import List, Tuple

import numpy as np
from stable_baselines3 import DQN

from rx150_ik_env import RX150IKEnv

# ----------------------------------------------------------------------
# Analytical IK / FK imports from Project 11
# ----------------------------------------------------------------------
try:
    from inverse_kinematics_rx150 import ik_rx150_pos
    from forward_kinematics_rx150 import fk_rx150_deg
    HAVE_ANALYTIC = True
except ImportError:
    HAVE_ANALYTIC = False
    ik_rx150_pos = None
    fk_rx150_deg = None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Test a trained DQN IK policy for the RX-150 arm, "
                    "and compare against analytical IK."
    )
    parser.add_argument(
        "--model",
        type=str,
        required=True,
        help="Path to trained DQN .zip file (e.g., models/dqn_ik_final.zip)",
    )
    parser.add_argument(
        "--episodes",
        type=int,
        default=20,
        help="Number of test episodes (default: 20)",
    )
    parser.add_argument(
        "--render",
        action="store_true",
        help="Render with PyBullet GUI (slower, but good for demo)",
    )
    return parser.parse_args()


def analytic_ik_fk(
    target_pos_m: np.ndarray,
) -> Tuple[np.ndarray, np.ndarray, bool]:
    """Compute analytical IK and FK for a given target position (meters).

    Parameters
    ----------
    target_pos_m : (3,) ndarray
        Target position [x, y, z] in meters.

    Returns
    -------
    q_deg : (5,) ndarray
        IK solution joint angles in degrees (if success), NaNs otherwise.
    ee_pos_m : (3,) ndarray
        FK-computed end-effector position in meters (if success), NaNs otherwise.
    success : bool
        Whether the analytical IK reported success.
    """
    if not HAVE_ANALYTIC:
        return np.full(5, np.nan), np.full(3, np.nan), False

    # Convert target from meters (env) to millimeters (IK/ FK)
    target_mm = np.asarray(target_pos_m, dtype=float) * 1000.0

    q_deg, success = ik_rx150_pos(target_mm)
    if not success:
        return q_deg, np.full(3, np.nan), False

    # Use FK to get the EE position corresponding to the analytic solution
    _, ee_pos_mm = fk_rx150_deg(q_deg)
    ee_pos_m = np.asarray(ee_pos_mm, dtype=float) / 1000.0

    return q_deg, ee_pos_m, True


def main() -> None:
    args = parse_args()

    if not os.path.isfile(args.model):
        raise FileNotFoundError(f"Model file not found: {args.model}")

    if not HAVE_ANALYTIC:
        print(
            "WARNING: Could not import analytical IK/FK modules. "
            "Analytical comparison will be skipped.\n"
            "Make sure 'inverse_kinematics_rx150.py' and "
            "'forward_kinematics_rx150.py' are on the PYTHONPATH."
        )

    render_mode = "human" if args.render else None
    env = RX150IKEnv(render_mode=render_mode)

    print(f"Loading model from: {args.model}")
    model = DQN.load(args.model, env=env)

    episode_rewards: List[float] = []
    final_distances_env: List[float] = []
    successes_env: List[bool] = []
    steps_taken: List[int] = []

    # For analytic comparison statistics
    analytic_errors: List[float] = []
    rl_fk_errors: List[float] = []

    for ep in range(args.episodes):
        obs = env.reset()
        done = False
        ep_reward = 0.0
        step = 0
        last_info = {}
        last_obs = obs.copy()

        # Target (m) is fixed for this episode and encoded in the observation
        target_pos_m = obs[0:3].astype(float)

        while not done:
            action, _ = model.predict(obs, deterministic=True)
            obs, reward, done, info = env.step(action)
            ep_reward += float(reward)
            step += 1
            last_info = info
            last_obs = obs.copy()

        # Environment-reported final distance and success
        dist_env = float(last_info.get("distance", np.nan))
        success_env = bool(last_info.get("is_success", False))

        episode_rewards.append(ep_reward)
        final_distances_env.append(dist_env)
        successes_env.append(success_env)
        steps_taken.append(step)

        # RL policy final joint angles (radians) are encoded in last_obs[3:8]
        rl_q_rad = last_obs[3:8].astype(float)
        rl_q_deg = np.rad2deg(rl_q_rad)

        # Compute FK position for RL policy joint angles using the same FK model
        rl_ee_pos_m = np.full(3, np.nan)
        if HAVE_ANALYTIC:
            try:
                _, rl_ee_pos_mm = fk_rx150_deg(rl_q_deg)
                rl_ee_pos_m = np.asarray(rl_ee_pos_mm, dtype=float) / 1000.0
            except Exception as e:
                print(f"[Episode {ep+1}] WARNING: FK for RL policy failed: {e}")

        # Analytical IK + FK for the same target
        analytic_q_deg, analytic_ee_pos_m, analytic_success = analytic_ik_fk(
            target_pos_m
        )

        # Distance errors (using the DH FK model)
        analytic_err = np.nan
        rl_fk_err = np.nan
        if analytic_success:
            analytic_err = float(np.linalg.norm(analytic_ee_pos_m - target_pos_m))
            analytic_errors.append(analytic_err)
        if np.all(np.isfinite(rl_ee_pos_m)):
            rl_fk_err = float(np.linalg.norm(rl_ee_pos_m - target_pos_m))
            rl_fk_errors.append(rl_fk_err)

        # Episode summary
        print(
            f"Episode {ep+1:3d} | "
            f"reward = {ep_reward: .3f} | "
            f"env final dist = {dist_env:.4f} m | "
            f"steps = {step:3d} | "
            f"success (env) = {success_env}"
        )
        print(
            f"  Target (m): "
            f"x={target_pos_m[0]: .3f}, y={target_pos_m[1]: .3f}, z={target_pos_m[2]: .3f}"
        )
        if HAVE_ANALYTIC:
            print(
                f"  Analytic IK: success={analytic_success}, "
                f"FK error={analytic_err if np.isfinite(analytic_err) else float('nan'):.4f} m"
            )
            print(f"    q_deg (analytic) = {np.array2string(analytic_q_deg, precision=2)}")
        else:
            print("  Analytic IK: (modules not available)")

        print(
            f"  RL policy (DH FK): "
            f"FK error={rl_fk_err if np.isfinite(rl_fk_err) else float('nan'):.4f} m, "
            f"env dist={dist_env:.4f} m"
        )
        print(f"    q_deg (RL)       = {np.array2string(rl_q_deg, precision=2)}")
        print("-" * 72)

    env.close()

    # Summary statistics
    success_rate_env = 100.0 * np.mean(successes_env) if successes_env else 0.0
    mean_dist_env = float(np.mean(final_distances_env)) if final_distances_env else float("nan")
    std_dist_env = float(np.std(final_distances_env)) if final_distances_env else float("nan")
    mean_reward = float(np.mean(episode_rewards)) if episode_rewards else float("nan")

    print("\n=== RL Policy Test Summary (Environment) ===")
    print(f"Episodes:            {args.episodes}")
    print(f"Success rate:        {success_rate_env:.1f}%")
    print(f"Final distance (env): mean = {mean_dist_env:.4f} m, std = {std_dist_env:.4f} m")
    print(f"Episode reward:      mean = {mean_reward:.3f}")

    if HAVE_ANALYTIC and analytic_errors:
        mean_analytic_err = float(np.mean(analytic_errors))
        std_analytic_err = float(np.std(analytic_errors))
        print("\n=== Analytic IK vs Target (DH FK) ===")
        print(f"Analytic FK error:   mean = {mean_analytic_err:.4f} m, " 
              f"std = {std_analytic_err:.4f} m")

    if HAVE_ANALYTIC and rl_fk_errors:
        mean_rl_fk_err = float(np.mean(rl_fk_errors))
        std_rl_fk_err = float(np.std(rl_fk_errors))
        print("\n=== RL Policy vs Target (DH FK) ===")
        print(f"RL FK error:         mean = {mean_rl_fk_err:.4f} m, " 
              f"std = {std_rl_fk_err:.4f} m")


if __name__ == "__main__":
    main()
