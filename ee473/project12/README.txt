Project 12 - RL_IK Scripts
============================

This folder contains the Python scripts required for the EE473 Project 12
Reinforcement Learning Inverse Kinematics assignment.

Structure:
    src/
        rx150_ik_env.py
            Gym + PyBullet environment for the RX-150 IK task.

        train_dqn.py
            Trains a DQN agent in RX150IKEnv using Stable-Baselines3.

        test_policy.py
            Loads a trained DQN model, evaluates it in RX150IKEnv, and
            compares the learned policy to the analytical IK solution.

        inverse_kinematics_rx150.py
            Analytical IK implementation reused from Project 11.

        forward_kinematics_rx150.py
            Forward kinematics implementation reused from Project 11.

Usage (from project root, where src/ lives):

    # Train the RL policy
    python3 src/train_dqn.py

    # Test a trained model (example path)
    python3 src/test_policy.py --model models/dqn_ik_final.zip --episodes 20

Make sure you have installed:
    gym==0.21.0
    stable-baselines3[extra]==1.8.0
    pybullet

and that your RX-150 URDF file (rx150.urdf) is available in the working directory.
