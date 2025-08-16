import numpy as np


def custom_transform(data):
    """
    Transform the `spiral.csv` data such that it can be more easily classified.

    To pass test_custom_transform_hard, your transformation should create at
    most three features and should allow a LogisticRegression model to achieve
    at least 90% accuracy.

    You can use free_response.q2.visualize_spiral() to visualize the spiral
    as we give it to you, and free_response.q2.visualize_transform() to
    visualize the 3D data transformation you implement here.

    Args:
        data: a Nx2 matrix from the `spiral.csv` dataset.

    Returns:
        A transformed data matrix that is (more) easily classified.
    """
    x = data[:, 0]
    y = data[:, 1]


    a = np.cos(-2*x)
    b = np.sin(-y)
    c = np.cbrt(a**3 + b**3)
    e = np.sin(x) * np.cos(y)

    return np.column_stack(( c, e, a))


