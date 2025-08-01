"""Training application for XOR neural network."""

import argparse

from ..model import XORNeuralNetwork


def main() -> None:
    """Main training function."""
    parser = argparse.ArgumentParser(description="Train XOR neural network")
    parser.add_argument(
        "--epochs",
        type=int,
        default=1000,
        help="Number of training epochs (default: 1000)",
    )
    parser.add_argument(
        "--model-path",
        type=str,
        default="xor_model.keras",
        help="Path to save the trained model (default: xor_model.keras)",
    )
    parser.add_argument(
        "--verbose",
        type=int,
        default=1,
        choices=[0, 1, 2],
        help="Training verbosity level (default: 1)",
    )

    args = parser.parse_args()

    print("Initializing XOR Neural Network...")
    model = XORNeuralNetwork()

    print(f"Training for {args.epochs} epochs...")
    history = model.train(epochs=args.epochs, verbose=args.verbose)

    final_loss = history.history["loss"][-1]
    final_accuracy = history.history["accuracy"][-1]

    print("Training completed!")
    print(f"Final loss: {final_loss:.4f}")
    print(f"Final accuracy: {final_accuracy:.4f}")

    print("Evaluating model on XOR data...")
    loss, accuracy = model.evaluate()
    print(f"Test loss: {loss:.4f}")
    print(f"Test accuracy: {accuracy:.4f}")

    print("Testing predictions:")
    X, y = model.get_xor_data()
    predictions = model.predict(X)

    for i, (inputs, expected, predicted) in enumerate(zip(X, y, predictions)):
        print(
            f"Input: {inputs} | Expected: {expected[0]:.0f} | Predicted: {predicted[0]:.4f} | Rounded: {round(predicted[0])}"
        )

    print(f"Saving model to {args.model_path}...")
    model.save_model(args.model_path)
    print("Model saved successfully!")


if __name__ == "__main__":
    main()
