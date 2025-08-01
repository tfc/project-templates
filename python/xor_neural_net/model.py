"""Neural network model for XOR function."""

import tensorflow as tf
import numpy as np
from typing import Tuple


class XORNeuralNetwork:
    """A simple neural network for learning the XOR function."""

    def __init__(self) -> None:
        """Initialize the neural network with a simple architecture."""
        self.model = tf.keras.Sequential(
            [
                tf.keras.layers.Dense(4, activation="relu", input_shape=(2,)),
                tf.keras.layers.Dense(1, activation="sigmoid"),
            ]
        )

        self.model.compile(
            optimizer="adam", loss="binary_crossentropy", metrics=["accuracy"]
        )

    def get_xor_data(self) -> Tuple[np.ndarray, np.ndarray]:
        """Generate XOR training data."""
        X = np.array([[0, 0], [0, 1], [1, 0], [1, 1]], dtype=np.float32)
        y = np.array([[0], [1], [1], [0]], dtype=np.float32)
        return X, y

    def train(self, epochs: int = 1000, verbose: int = 0) -> tf.keras.callbacks.History:
        """Train the neural network on XOR data."""
        X, y = self.get_xor_data()
        history = self.model.fit(X, y, epochs=epochs, verbose=verbose)
        return history

    def predict(self, inputs: np.ndarray) -> np.ndarray:
        """Make predictions with the trained model."""
        return self.model.predict(inputs, verbose=0)

    def evaluate(self) -> Tuple[float, float]:
        """Evaluate the model on XOR data."""
        X, y = self.get_xor_data()
        loss, accuracy = self.model.evaluate(X, y, verbose=0)
        return loss, accuracy

    def save_model(self, filepath: str) -> None:
        """Save the trained model."""
        self.model.save(filepath)

    def load_model(self, filepath: str) -> None:
        """Load a trained model."""
        self.model = tf.keras.models.load_model(filepath)
