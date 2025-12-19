#!/usr/bin/env python3
"""train_dqn.py

Train a DQN agent to learn RX-150 inverse kinematics using RX150IKEnv.

The agent learns a policy that maps:
    state = [target_x, target_y, target_z, joint1..joint5, distance]
to one of 10 discrete joint increment / decrement actions.

This script uses Stable-Baselines3's DQN with a small MLP policy
(two hidden layers of size 32), tuned for modest hardware (e.g. RPi 4B).

Typical usage (from project root):
    python3 src/train_dqn.py

Optional arguments:
    python3 src/train_dqn.py --timesteps 50000 --models-dir models_big --log-dir logs_big
"""

from __future__ import annotations

import argparse
import os
from typing import Callable, Optional

import gym
from stable_baselines3 import DQN
from stable_baselines3.common.callbacks import CheckpointCallback, EvalCallback
from stable_baselines3.common.monitor import Monitor
from stable_baselines3.common.vec_env import DummyVecEnv

from rx150_ik_env import RX150IKEnv


def make_env(render: bool = False, seed: Optional[int] = None) -> Callable[[], gym.Env]:
    """Return a factory function that creates a monitored RX150IKEnv."""

    def _init() -> gym.Env:
        env = RX150IKEnv(render_mode="human" if render else None)
        env = Monitor(env)
        if seed is not None:
            env.seed(seed)
        return env

    return _init


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Train a DQN agent for RX-150 inverse kinematics."
    )
    parser.add_argument(
        "--timesteps",
        type=int,
        default=15000,
        help="Total number of training timesteps (default: 15000)",
    )
    parser.add_argument(
        "--models-dir",
        type=str,
        default="models",
        help="Directory to save models (default: models)",
    )
    parser.add_argument(
        "--log-dir",
        type=str,
        default="logs",
        help="Directory for TensorBoard logs (default: logs)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    os.makedirs(args.models_dir, exist_ok=True)
    os.makedirs(args.log_dir, exist_ok=True)

    # Create training and evaluation environments (vectorized for SB3)
    train_env = DummyVecEnv([make_env(render=False, seed=42)])
    eval_env = DummyVecEnv([make_env(render=False, seed=43)])

    # Checkpoint callback: save periodic checkpoints
    checkpoint_callback = CheckpointCallback(
        save_freq=5000,
        save_path=args.models_dir,
        name_prefix="dqn_ik_checkpoint",
        save_replay_buffer=False,
    )

    # Evaluation callback: periodically evaluate and save best model
    eval_callback = EvalCallback(
        eval_env,
        best_model_save_path=os.path.join(args.models_dir, "best"),
        log_path=args.log_dir,
        eval_freq=2000,
        n_eval_episodes=10,
        deterministic=True,
        render=False,
    )

    # DQN hyperparameters (small network)
    policy_kwargs = dict(net_arch=[32, 32])

    model = DQN(
        policy="MlpPolicy",
        env=train_env,
        learning_rate=1e-3,
        buffer_size=3000,
        learning_starts=1000,
        batch_size=32,
        gamma=0.99,
        tau=1.0,
        train_freq=4,
        gradient_steps=1,
        target_update_interval=1000,
        exploration_fraction=0.3,
        exploration_final_eps=0.05,
        verbose=1,
        tensorboard_log=args.log_dir,
        policy_kwargs=policy_kwargs,
    )

    print("Starting training...")
    model.learn(
        total_timesteps=args.timesteps,
        callback=[checkpoint_callback, eval_callback],
    )

    final_model_path = os.path.join(args.models_dir, "dqn_ik_final")
    model.save(final_model_path)
    print(f"Training complete. Final model saved to: {final_model_path}.zip")


if __name__ == "__main__":
    main()
