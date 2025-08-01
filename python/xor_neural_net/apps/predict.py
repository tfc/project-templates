"""Prediction application for XOR neural network."""

import argparse
import sys

import numpy as np

from ..model import XORNeuralNetwork


def parse_inputs(input_str: str) -> np.ndarray:
    """Parse input string into numpy array."""
    try:
        values = [float(x.strip()) for x in input_str.split(",")]
        if len(values) != 2:
            raise ValueError("Expected exactly 2 input values")
        return np.array([values], dtype=np.float32)
    except ValueError as e:
        print(f"Error parsing inputs: {e}")
        print("Please provide inputs as two comma-separated numbers (e.g., '1,0')")
        sys.exit(1)


def main() -> None:
    """Main prediction function."""
    parser = argparse.ArgumentParser(
        description="Make predictions with trained XOR neural network"
    )
    parser.add_argument(
        "--model-path",
        type=str,
        default="xor_model.keras",
        help="Path to the trained model (default: xor_model.keras)",
    )
    parser.add_argument(
        "--inputs",
        type=str,
        help="Input values as comma-separated numbers (e.g., '1,0')",
    )
    parser.add_argument(
        "--test-all", action="store_true", help="Test all XOR combinations"
    )

    args = parser.parse_args()

    if not args.inputs and not args.test_all:
        print("Error: Must provide either --inputs or --test-all")
        sys.exit(1)

    try:
        print(f"Loading model from {args.model_path}...")
        model = XORNeuralNetwork()
        model.load_model(args.model_path)
        print("Model loaded successfully!")
    except Exception as e:
        print(f"Error loading model: {e}")
        print("Make sure to train the model first using 'xor-train'")
        sys.exit(1)

    if args.test_all:
        print("\nTesting all XOR combinations:")
        print("-" * 40)
        X, y = model.get_xor_data()
        predictions = model.predict(X)

        for i, (inputs, expected, predicted) in enumerate(zip(X, y, predictions)):
            print(
                f"Input: [{inputs[0]:.0f}, {inputs[1]:.0f}] | Expected: {expected[0]:.0f} | Predicted: {predicted[0]:.4f} | Rounded: {round(predicted[0])}"
            )

    if args.inputs:
        print(f"\nMaking prediction for inputs: {args.inputs}")
        input_array = parse_inputs(args.inputs)
        prediction = model.predict(input_array)

        print("-" * 40)
        print(f"Input: [{input_array[0][0]:.0f}, {input_array[0][1]:.0f}]")
        print(f"Predicted: {prediction[0][0]:.4f}")
        print(f"Rounded: {round(prediction[0][0])}")


if __name__ == "__main__":
    main()
