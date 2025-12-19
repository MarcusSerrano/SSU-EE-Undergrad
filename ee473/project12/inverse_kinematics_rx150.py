#!/usr/bin/env python3
"""
inverse_kinematics_rx150.py

Numerical inverse kinematics for the Trossen / Interbotix ReactorX-150 (RX-150)
5-DOF arm. The solver is position-only (x, y, z in mm). Orientation is not
constrained.

Interface:
    - Target position in mm (x, y, z).
    - Returns joint angles in DEGREES [θ1..θ5].

Usage (CLI example):
    python inverse_kinematics_rx150.py 150 0 150
"""

import sys
import numpy as np
from forward_kinematics_rx150 import fk_rx150_deg

# Joint limits in DEGREES (from RX-150 specs)
JOINT_MIN_DEG = np.array([-180.0, -106.0, -102.0, -100.0, -180.0])
JOINT_MAX_DEG = np.array([ 180.0,  100.0,   95.0,  123.0,  180.0])

JOINT_MIN_RAD = np.deg2rad(JOINT_MIN_DEG)
JOINT_MAX_RAD = np.deg2rad(JOINT_MAX_DEG)


def numerical_jacobian(q_rad: np.ndarray, delta: float = 1e-4) -> np.ndarray:
    """
    Numerically estimate the 3x5 position Jacobian J(q) using forward differences.

    Parameters
    ----------
    q_rad : (5,) array
        Joint angles in radians.
    delta : float
        Perturbation step in radians.

    Returns
    -------
    J : (3,5) ndarray
        Jacobian mapping joint rate to end-effector linear velocity.
    """
    # Work with degrees for fk_rx150_deg, but perturb in radians
    q_deg = np.rad2deg(q_rad)
    _, p0 = fk_rx150_deg(q_deg)
    J = np.zeros((3, 5))

    for j in range(5):
        q_pert = q_rad.copy()
        q_pert[j] += delta
        q_pert_deg = np.rad2deg(q_pert)
        _, p_pert = fk_rx150_deg(q_pert_deg)
        J[:, j] = (p_pert - p0) / delta  # mm / rad

    return J


def ik_rx150_pos(target_pos_mm: np.ndarray,
                 q_init_deg: np.ndarray | None = None,
                 max_iters: int = 1000,
                 tol: float = 1e-3,
                 alpha: float = 0.3) -> tuple[np.ndarray, bool]:
    """
    Inverse kinematics: find joint angles that achieve a desired (x, y, z) position.

    Parameters
    ----------
    target_pos_mm : (3,) array-like
        Desired [x, y, z] in mm.
    q_init_deg : (5,) array-like or None
        Optional initial guess for joint angles in degrees.
        If None, uses the middle of the joint limits.
    max_iters : int
        Maximum number of iterations.
    tol : float
        Position tolerance in mm for convergence.
    alpha : float
        Step size gain for the Jacobian-transpose update.

    Returns
    -------
    q_deg : (5,) ndarray
        Found joint angles in DEGREES (clipped to joint limits).
    success : bool
        True if converged within tolerance, False otherwise.
    """
    target_pos = np.asarray(target_pos_mm, dtype=float).reshape(3)

    if q_init_deg is None:
        q_init_deg = 0.5 * (JOINT_MIN_DEG + JOINT_MAX_DEG)

    q_rad = np.deg2rad(np.asarray(q_init_deg, dtype=float))

    for _ in range(max_iters):
        # Current FK
        q_deg = np.rad2deg(q_rad)
        _, p = fk_rx150_deg(q_deg)
        error = target_pos - p  # in mm

        if np.linalg.norm(error) < tol:
            q_deg = np.clip(np.rad2deg(q_rad), JOINT_MIN_DEG, JOINT_MAX_DEG)
            return q_deg, True

        # Jacobian (3x5)
        J = numerical_jacobian(q_rad)

        # Jacobian transpose update (gradient descent on position error)
        dq = alpha * J.T @ error  # rad

        q_rad = q_rad + dq

        # Enforce joint limits in radians
        q_rad = np.clip(q_rad, JOINT_MIN_RAD, JOINT_MAX_RAD)

    # If we get here, IK didn't converge within max_iters
    q_deg = np.clip(np.rad2deg(q_rad), JOINT_MIN_DEG, JOINT_MAX_DEG)
    return q_deg, False


def main():
    if len(sys.argv) != 4:
        print("Usage: python inverse_kinematics_rx150.py x y z")
        print("All positions in MILLIMETERS, in the base frame.")
        sys.exit(1)

    target = np.array([float(a) for a in sys.argv[1:4]], dtype=float)
    q_deg, success = ik_rx150_pos(target)

    print(f"Target position (mm): x={target[0]:.3f}, y={target[1]:.3f}, z={target[2]:.3f}")
    print("\nSolved joint angles (deg):")
    print(q_deg)
    print("\nConverged:", success)

    # Optionally, show the resulting FK position to check error
    _, p_fk = fk_rx150_deg(q_deg)
    print("\nFK of solved angles (mm):")
    print(f"x={p_fk[0]:.3f}, y={p_fk[1]:.3f}, z={p_fk[2]:.3f}")
    print("Position error norm (mm):", np.linalg.norm(target - p_fk))


if __name__ == "__main__":
    main()
