import numpy as np


def euclidean_distances(X, Y):
    """Compute pairwise Euclidean distance between the rows of two matrices X (shape MxK)
    and Y (shape NxK). The output of this function is a matrix of shape MxN containing
    the Euclidean distance between two rows.

    (Hint: You're free to implement this with numpy.linalg.norm)

    Arguments:
        X {np.ndarray} -- First matrix, containing M examples with K features each.
        Y {np.ndarray} -- Second matrix, containing N examples with K features each.

    Returns:
        D {np.ndarray}: MxN matrix with Euclidean distances between rows of X and rows of Y.
    """
    # X = M:K, A = M:1:K
    A = X[:, np.newaxis , :]
    # Y = N:K, B = 1:N:K
    B = Y[np.newaxis, : , :]


    # D = M:N = (
    #        [d11, d12, ... , d1N], 
    #        [d21, d22, ... , d2N], 
    #        ...,
    #        [dM1, dM2, ... , dMN])

    # d11 = (x11 - y11)^2 + (x12 - y12)^2 + ... + (x1K - y1K)^2

    # ord = 2 or None: euclidean_distances
    D = np.linalg.norm(A - B, axis = 2)

    return D


def manhattan_distances(X, Y):
    """Compute pairwise Manhattan distance between the rows of two matrices X (shape MxK)
    and Y (shape NxK). The output of this function is a matrix of shape MxN containing
    the Manhattan distance between two rows.

    (Hint: You're free to implement this with numpy.linalg.norm)

    Arguments:
        X {np.ndarray} -- First matrix, containing M examples with K features each.
        Y {np.ndarray} -- Second matrix, containing N examples with K features each.

    Returns:
        D {np.ndarray}: MxN matrix with Manhattan distances between rows of X and rows of Y.
    """
    # X = M:K, A = M:1:K
    A = X[:, np.newaxis , :]
    # Y = N:K, B = 1:N:K
    B = Y[np.newaxis, : , :]

    # ord = 1: manhattan_distances
    # d11 = |x11 - y11| + |x12 - y12|+ ... + |x1K - y1K|
    D = np.linalg.norm(A - B,ord = 1, axis = 2)
    return D


def cosine_distances(X, Y):
    """Compute pairwise Cosine distance between the rows of two matrices X (shape MxK)
    and Y (shape NxK). The output of this function is a matrix of shape MxN containing
    the Cosine distance between two rows.

    (Hint: You're free to implement this with numpy.linalg.norm)
    (Hint: this is cosine distance, not cosine similarity)

    Arguments:
        X {np.ndarray} -- First matrix, containing M examples with K features each.
        Y {np.ndarray} -- Second matrix, containing N examples with K features each.

    Returns:
        D {np.ndarray}: MxN matrix with Cosine distances between rows of X and rows of Y.
    """
    # cosine distance(X, Y) = 1 - [X*Y/(||X||*||X||)]
        # X = M:K, A = M:1:K
    A = X[:, np.newaxis , :]
    # Y = N:K, B = 1:N:K
    B = Y[np.newaxis, : , :]

    epsilon = 1e-10
    normA = np.linalg.norm(A, ord = 2,axis = 2)
    normB = np.linalg.norm(B, ord = 2,axis = 2)
    AB = np.sum(A * B, axis = 2)
    D = 1 - AB / np.maximum((normA * normB),epsilon)
    return D
