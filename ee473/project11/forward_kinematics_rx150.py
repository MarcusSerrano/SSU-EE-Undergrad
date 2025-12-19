#!/usr/bin/env python3
"""
forward_kinematics_rx150.py

Forward kinematics for the Trossen / Interbotix ReactorX-150 (RX-150) 5-DOF arm
using the standard Denavit–Hartenberg convention.

- Joint angles are given in DEGREES at the function interface / CLI.
- End-effector position is returned in MILLIMETERS in the base frame.

Usage (CLI example):
    python forward_kinematics_rx150.py 0 0 0 0 0
"""

import sys
import numpy as np

# DH parameters (standard DH) for RX-150, from the quiz solution figure (mm, deg)
D = np.array([103.91, 0.0, 0.0, 0.0, 131.0])  # d_i
A = np.array([0.0, 157.7, 150.0, 0.0, 0.0])   # a_i
ALPHA_DEG = np.array([90.0, 0.0, 0.0, 90.0, 0.0])  # alpha_i in degrees
ALPHA = np.deg2rad(ALPHA_DEG)


def dh_transform(theta: float, d: float, a: float, alpha: float) -> np.ndarray:
    """
    Single standard DH transform A_i(θ_i, d_i, a_i, α_i).

    Parameters
    ----------
    theta : float
        Joint angle in radians.
    d : float
        Offset along z_{i-1} in mm.
    a : float
        Link length along x_i in mm.
    alpha : float
        Twist angle between z_{i-1} and z_i in radians.

    Returns
    -------
    T : (4,4) ndarray
        Homogeneous transform matrix.
    """
    ct, st = np.cos(theta), np.sin(theta)
    ca, sa = np.cos(alpha), np.sin(alpha)

    return np.array([
        [ct, -st * ca,  st * sa, a * ct],
        [st,  ct * ca, -ct * sa, a * st],
        [0.0,     sa,      ca,      d],
        [0.0,   0.0,     0.0,    1.0]
    ])


def fk_rx150_deg(q_deg: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """
    Forward kinematics for the RX-150.

    Parameters
    ----------
    q_deg : array-like, shape (5,)
        Joint angles [θ1..θ5] in DEGREES.

    Returns
    -------
    T_0_5 : (4,4) ndarray
        Homogeneous transform of the end-effector frame {5} with respect to base {0}.
    p_0_5 : (3,) ndarray
        End-effector position [x, y, z] in mm expressed in base frame.
    """
    q_rad = np.deg2rad(np.asarray(q_deg, dtype=float))
    T = np.eye(4)

    for i in range(5):
        T_i = dh_transform(q_rad[i], D[i], A[i], ALPHA[i])
        T = T @ T_i

    p = T[:3, 3].copy()  # x, y, z in mm
    return T, p


def main():
    if len(sys.argv) != 6:
        print("Usage: python forward_kinematics_rx150.py q1 q2 q3 q4 q5")
        print("All joint angles in DEGREES.")
        sys.exit(1)

    q_deg = np.array([float(a) for a in sys.argv[1:6]], dtype=float)
    T, p = fk_rx150_deg(q_deg)

    np.set_printoptions(precision=4, suppress=True)
    print("Joint angles (deg):", q_deg)
    print("\nEnd-effector homogeneous transform T_0_5:")
    print(T)
    print("\nEnd-effector position (mm):")
    print(f"x = {p[0]:.3f}, y = {p[1]:.3f}, z = {p[2]:.3f}")


if __name__ == "__main__":
    main()
