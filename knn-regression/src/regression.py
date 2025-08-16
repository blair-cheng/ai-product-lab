import numpy as np
import src.random


class PolynomialRegression():
    def __init__(self, degree):
        """
        Implement PolynomialRegression from scratch.
        
        The `degree` argument controls the complexity of the function.  For
        example, degree = 2 would specify a hypothesis space of all functions
        of the form:

            f(x) = ax^2 + bx + c

        You should implement the closed form solution of least squares:
            w = (X^T X)^{-1} X^T y
        
        Do not import or use these packages: fairlearn, scipy, sklearn, sys, importlib.
        Do not use (the name of) these numpy or internal functions: lstsq, polynomial, polyfit, polyval, getattr, globals

        Args:
            degree (int): Degree used to fit the data.
        """
        self.degree = degree

        self.weights = np.ones((self.degree + 1,))

    def fit(self, features, targets):
        """
        Fit the model to the given data.

        Hints:
          - Remember to use `self.degree`
          - Remember to include an intercept (a column of all 1s) before you
            compute the least squares solution.
          - If you are getting `numpy.linalg.LinAlgError: Singular matrix`,
            you may want to compute a "pseudoinverse" or add a tiny bit of
            random noise to your input data.

        Args:
            features (np.ndarray): an array of shape [N, 1] containing real-valued inputs.
            targets (np.ndarray): an array of shape [N, 1] containing real-valued targets.
        Returns:
            None (saves model weights to `self.weights`)
        """
        X = np.hstack([features**i for i in range(self.degree +1)])
        y = targets.reshape(-1,1)

        XTX = X.T @ X
        XTy = X.T @ y

        # pinv: X^-1, or pseudo X^-1
        weights = np.linalg.pinv(XTX) @ XTy
        self.weights = weights


    def predict(self, features):
        """
        Given features, use the trained model to predict target estimates. Call
        this only after calling fit so that the model has its weights.

        Args:
            features (np.ndarray): array of shape [N, 1] containing real-valued inputs.
        Returns:
            predictions (np.ndarray): array of shape [N, 1] containing real-valued predictions
        """
        assert hasattr(self, "weights"), "Model hasn't been fit!"

        # x1 = [1 feature1 feature1 ^2 ... feature1^degree]
        # X = [
        # [x1] 
        # [x2]
        #  ... 
        # [xn]]
        X = np.hstack([features**i for i in range(self.degree +1)])
        # [N, 1]
        predictions = X @ self.weights

        return predictions
