#!/usr/bin/env python3
"""rx150_ik_env.py

OpenAI Gym environment for RX-150 inverse kinematics using PyBullet.

- State  (9D):
    [target_x, target_y, target_z, joint1, joint2, joint3, joint4, joint5, distance]

- Actions (Discrete(10)):
    0: +Δθ1   1: -Δθ1
    2: +Δθ2   3: -Δθ2
    4: +Δθ3   5: -Δθ3
    6: +Δθ4   7: -Δθ4
    8: +Δθ5   9: -Δθ5

The agent is rewarded for reducing the distance between the end-effector
and a randomly-sampled target position.

This environment is designed to be used with Stable-Baselines3 DQN.

Usage (sanity check from project root):
    python3 src/rx150_ik_env.py --render
"""

from __future__ import annotations

import argparse
from typing import Any, Dict, Tuple

import gym
from gym import spaces
import numpy as np
import pybullet as p
import pybullet_data


# RX-150 joint limits in RADIANS (approx., from specs)
JOINT_MIN_DEG = np.array([-180.0, -106.0, -102.0, -100.0, -180.0], dtype=float)
JOINT_MAX_DEG = np.array([180.0, 100.0, 95.0, 123.0, 180.0], dtype=float)
JOINT_MIN_RAD = np.deg2rad(JOINT_MIN_DEG)
JOINT_MAX_RAD = np.deg2rad(JOINT_MAX_DEG)


class RX150IKEnv(gym.Env):
    """Custom Gym environment for RX-150 IK with discrete joint increments."""

    metadata = {"render.modes": ["human", None]}

    def __init__(
        self,
        render_mode: str | None = None,
        max_episode_steps: int = 75,
        action_delta_deg: float = 2.0,
        goal_threshold: float = 0.01,
    ) -> None:
        """Initialize the environment.

        Parameters
        ----------
        render_mode : {"human", None}
            If "human", opens a PyBullet GUI window. If None, runs headless.
        max_episode_steps : int
            Maximum number of steps before an episode terminates.
        action_delta_deg : float
            Magnitude of each joint increment in DEGREES.
        goal_threshold : float
            Distance threshold (meters) for considering the target reached.
        """
        super().__init__()

        self.render_mode = render_mode
        self.max_episode_steps = int(max_episode_steps)
        self.goal_threshold = float(goal_threshold)
        self.action_delta = float(np.deg2rad(action_delta_deg))

        # Workspace sampling bounds (meters)
        self.target_r_min = 0.15
        self.target_r_max = 0.35
        self.target_z_min = 0.05
        self.target_z_max = 0.25

        # Reward parameters
        self.step_penalty = 0.01
        self.goal_reward = 100.0

        # Actions: 10 discrete joint +/- increments
        self.action_space = spaces.Discrete(10)

        # Observations: [tx, ty, tz, q1, q2, q3, q4, q5, distance]
        self.observation_space = spaces.Box(
            low=-np.inf,
            high=np.inf,
            shape=(9,),
            dtype=np.float32,
        )

        # Connect to PyBullet
        if render_mode == "human":
            self._client_id = p.connect(p.GUI)
        else:
            self._client_id = p.connect(p.DIRECT)

        p.setAdditionalSearchPath(pybullet_data.getDataPath())
        p.setGravity(0.0, 0.0, -9.81, physicsClientId=self._client_id)

        # Ground plane (optional but nice for visualization)
        self._plane_id = p.loadURDF("plane.urdf", physicsClientId=self._client_id)

        # RX-150 URDF should be in the working directory or search path
        # (copy rx150.urdf here or adjust this path)
        self.robot_urdf_path = "rx150.urdf"
        self.robot_id = p.loadURDF(
            self.robot_urdf_path,
            basePosition=[0.0, 0.0, 0.0],
            useFixedBase=True,
            physicsClientId=self._client_id,
        )

        # Assume first 5 joints correspond to arm DOFs
        self.joint_indices = list(range(5))
        # Use the last link as end-effector index by default
        self.ee_link_index = (
            p.getNumJoints(self.robot_id, physicsClientId=self._client_id) - 1
        )

        self.sim_steps_per_action = 4

        # Episode state
        self.current_step: int = 0
        self.target_pos = np.zeros(3, dtype=np.float32)

    # ------------------------------------------------------------------
    # PyBullet helpers
    # ------------------------------------------------------------------
    def _get_joint_angles(self) -> np.ndarray:
        q = []
        for j in self.joint_indices:
            state = p.getJointState(self.robot_id, j, physicsClientId=self._client_id)
            q.append(state[0])
        return np.asarray(q, dtype=np.float32)

    def _get_ee_position(self) -> np.ndarray:
        link_state = p.getLinkState(
            self.robot_id,
            self.ee_link_index,
            computeForwardKinematics=True,
            physicsClientId=self._client_id,
        )
        pos = np.asarray(link_state[0], dtype=np.float32)  # (x, y, z)
        return pos

    def _get_obs(self) -> np.ndarray:
        q = self._get_joint_angles()
        ee_pos = self._get_ee_position()
        distance = float(np.linalg.norm(self.target_pos - ee_pos))

        obs = np.empty(9, dtype=np.float32)
        obs[0:3] = self.target_pos
        obs[3:8] = q
        obs[8] = distance
        return obs

    # ------------------------------------------------------------------
    # Gym API
    # ------------------------------------------------------------------
    def reset(
        self,
        *,
        seed: int | None = None,
        options: Dict[str, Any] | None = None,
    ) -> np.ndarray:
        # Gym's newer API includes seed/options; for compatibility we ignore options.
        super().reset(seed=seed)

        self.current_step = 0

        # Randomize initial joint configuration within limits
        q_init = np.random.uniform(JOINT_MIN_RAD, JOINT_MAX_RAD)
        for j, q in zip(self.joint_indices, q_init):
            p.resetJointState(
                self.robot_id,
                j,
                targetValue=float(q),
                targetVelocity=0.0,
                physicsClientId=self._client_id,
            )

        # Sample a random reachable-ish target in cylindrical coords
        radius = np.random.uniform(self.target_r_min, self.target_r_max)
        theta = np.random.uniform(-np.pi, np.pi)
        z = np.random.uniform(self.target_z_min, self.target_z_max)
        x = radius * np.cos(theta)
        y = radius * np.sin(theta)
        self.target_pos = np.array([x, y, z], dtype=np.float32)

        # Step once to make sure everything is updated
        p.stepSimulation(physicsClientId=self._client_id)

        obs = self._get_obs()
        return obs

    def step(self, action: int) -> Tuple[np.ndarray, float, bool, Dict[str, Any]]:
        # Convert action index into joint index + direction
        if not self.action_space.contains(action):
            raise ValueError(f"Invalid action {action}")

        self.current_step += 1

        joint_idx = int(action) // 2  # 0..4
        direction = 1.0 if (int(action) % 2 == 0) else -1.0

        q = self._get_joint_angles()
        q_new = q.copy()
        q_new[joint_idx] = np.clip(
            q_new[joint_idx] + direction * self.action_delta,
            JOINT_MIN_RAD[joint_idx],
            JOINT_MAX_RAD[joint_idx],
        )

        # Apply new joint angle via position control
        p.setJointMotorControl2(
            self.robot_id,
            self.joint_indices[joint_idx],
            controlMode=p.POSITION_CONTROL,
            targetPosition=float(q_new[joint_idx]),
            force=3.0,
            physicsClientId=self._client_id,
        )

        # Step the physics a few times to let the joint move
        for _ in range(self.sim_steps_per_action):
            p.stepSimulation(physicsClientId=self._client_id)

        obs = self._get_obs()
        distance = float(obs[8])

        # Reward: dominate term is -distance^2, small step penalty, large bonus for success
        reward = -distance * distance - self.step_penalty
        goal_reached = distance < self.goal_threshold
        done = False

        if goal_reached:
            reward += self.goal_reward
            done = True

        if self.current_step >= self.max_episode_steps:
            done = True

        info: Dict[str, Any] = {
            "distance": distance,
            "is_success": goal_reached,
        }
        return obs, float(reward), bool(done), info

    def render(self, mode: str = "human") -> None:
        # Rendering is handled automatically by PyBullet GUI when render_mode="human".
        return None

    def close(self) -> None:
        if p.isConnected(self._client_id):
            p.disconnect(self._client_id)


# ----------------------------------------------------------------------
# Simple CLI for random-policy sanity check
# ----------------------------------------------------------------------
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Quick sanity check for RX150IKEnv."
    )
    parser.add_argument(
        "--steps",
        type=int,
        default=200,
        help="Number of random steps to run (default: 200)",
    )
    parser.add_argument(
        "--render",
        action="store_true",
        help="Use PyBullet GUI (render_mode='human')",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    render_mode = "human" if args.render else None
    env = RX150IKEnv(render_mode=render_mode)

    obs = env.reset()
    print("Initial observation shape:", obs.shape)

    for t in range(args.steps):
        action = env.action_space.sample()
        obs, reward, done, info = env.step(action)
        if (t + 1) % 20 == 0:
            print(
                f"Step {t+1:4d} | reward={reward: .3f} | "
                f"dist={info['distance']:.4f} | done={done}"
            )
        if done:
            obs = env.reset()

    env.close()


if __name__ == "__main__":
    main()
