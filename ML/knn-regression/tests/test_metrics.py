import numpy as np
from src import mean_squared_error as src_mse
from src import equalized_odds_difference as src_eod
from src import demographic_parity_difference as src_dpd
import src.random


def make_fake_regression_data(n=100):
    y_true = src.random.rand(n)
    y_pred = src.random.rand(n)
    return y_pred, y_true


def make_fake_classification_data(n=100):
    y_true = src.random.randint(0, 2, n)
    y_pred = src.random.randint(0, 2, n)
    group = src.random.randint(0, 2, n)
    return y_pred, y_true, group


def test_mean_squared_error():
    from sklearn.metrics import mean_squared_error as sklearn_mse 

    for _ in range(3):
        y_pred, y_true = make_fake_regression_data()

        _est = src_mse(y_true, y_pred)
        _actual = sklearn_mse(y_true, y_pred)

        assert np.allclose(_actual, _est)


def test_equalized_odds_difference():
    from sklearn.metrics import confusion_matrix
    from fairlearn.metrics import equalized_odds_difference

    for _ in range(3):
        y_pred, y_true, group = make_fake_classification_data()

        _actual = equalized_odds_difference(
            y_true, y_pred, sensitive_features=group)

        mat_a = confusion_matrix(y_true[group == 0], y_pred[group == 0])
        mat_b = confusion_matrix(y_true[group == 1], y_pred[group == 1])

        _est = src_eod(mat_a, mat_b)
        print(mat_a)
        print(mat_b)
        print(_est)

        assert np.allclose(_actual, _est)


def test_demographic_parity_difference():
    from sklearn.metrics import confusion_matrix
    from fairlearn.metrics import demographic_parity_difference

    for _ in range(3):
        y_pred, y_true, group = make_fake_classification_data()

        _actual = demographic_parity_difference(
            y_true, y_pred, sensitive_features=group)

        mat_a = confusion_matrix(y_true[group == 0], y_pred[group == 0])
        mat_b = confusion_matrix(y_true[group == 1], y_pred[group == 1])

        _est = src_dpd(mat_a, mat_b)

        assert np.allclose(_actual, _est)
