import numpy as np


def mean_squared_error(predictions, targets):
    """
    Mean squared error measures the average of the square of the errors (the
    average squared difference between the estimated values and what is
    estimated.

    Refer to the slides, or read more here:
      https://en.wikipedia.org/wiki/Mean_squared_error

    Do not import or use these packages: fairlearn, scipy, sklearn, sys, importlib.

    Args:
        predictions (np.ndarray): array of shape [N, 1] containing real-valued predictions
        targets (np.ndarray): the ground truth values

    Returns:
        MSE (float): the mean squared error across all predictions and targets
    """

    assert predictions.shape == targets.shape

    return np.mean((targets -predictions)**2)



def demographic_parity_difference(confusion_matrix_a, confusion_matrix_b):
    """
    A classifier satisfies demographic parity if the subjects in the protected
    and unprotected groups have equal probability of being assigned to the
    positive predicted class.
    https://en.wikipedia.org/wiki/Fairness_(machine_learning)#Definitions_based_on_predicted_outcome

    You can assume each confusion_matrix input is of shape (2, 2), where the
    entries are:
    [
        [true_negatives, false_positives],
        [false_negatives, true_positives]
    ]

    >>> demographic_parity_difference(
    ...     np.array([[10, 0], [0, 10]]), np.array([[10, 0], [0, 10]]))
    0.0

    >>> demographic_parity_difference(
    ...     np.array([[9, 13], [10, 18]]), np.array([[15, 14], [9, 12]]))
    0.1

    Args:
        confusion_matrix_a (np.ndarray): a 2x2 confusion matrix, for members of "group a"
        confusion_matrix_b (np.ndarray): a 2x2 confusion matrix, for members of "group b"

    Returns:
        DPD: The demographic parity difference between group a and group b

    """
    mat_a_shape = confusion_matrix_a.shape
    assert mat_a_shape == confusion_matrix_b.shape
    assert mat_a_shape == (2, 2)
    # demographic parity difference = (tp1 + fp1)/total1 - (tp2 + fp2)/total2
    tp1, fp1 = confusion_matrix_a[1,1], confusion_matrix_a[0,1]
    tp2, fp2 = confusion_matrix_b[1,1], confusion_matrix_b[0,1]

    # ppr: positive prediction rate
    ppr1 =  (tp1 + fp1)/ np.sum(confusion_matrix_a)
    ppr2 = (tp2 + fp2)/np.sum(confusion_matrix_b)
    DPD = abs(ppr1 - ppr2)
    return DPD


def equalized_odds_difference(confusion_matrix_a, confusion_matrix_b):
    """
    A classifier satisfies equalized odds if the subjects in the protected and
    unprotected groups have equal TPR and equal FPR
    https://en.wikipedia.org/wiki/Equalized_odds

    We define equalized odds difference (EOD) as the maximum absolute disparity between
    either false-positive rates or true-positive rates between groups.

    You can assume each confusion_matrix input is of shape (2, 2), where the
    entries are:
    [
        [true_negatives, false_positives],
        [false_negatives, true_positives]
    ]

    >>> equalized_odds_difference(
    ...     np.array([[10, 0], [0, 10]]), np.array([[10, 0], [0, 10]]))
    0.0

    >>> equalized_odds_difference(
    ...     np.array([[9, 13], [10, 18]]), np.array([[15, 14], [11, 10]]))
    0.1666666666666667

    Args:
        confusion_matrix_a (np.ndarray): a 2x2 confusion matrix, for members of "group a"
        confusion_matrix_b (np.ndarray): a 2x2 confusion matrix, for members of "group b"

    Returns:
        EOD: The equalized odds difference between group a and group b

    """
    mat_a_shape = confusion_matrix_a.shape
    assert mat_a_shape == confusion_matrix_b.shape
    assert mat_a_shape == (2, 2)
    # EOD = max.abs(fpr1- fpr2 ,tpr1-tpr2)
    # fpr = fp/n
    # tpr = tp/n
    tn1, tp1, fp1,fn1 = confusion_matrix_a[0,0],confusion_matrix_a[1,1], confusion_matrix_a[0,1], confusion_matrix_a[1,0]
    tn2, tp2, fp2,fn2 =confusion_matrix_b[0,0], confusion_matrix_b[1,1], confusion_matrix_b[0,1], confusion_matrix_b[1,0]

    n1 = tn1 + fp1 
    n2 = tn2 + fp2
    p1 = fn1 + tp1
    p2 = fn2 + tp2
    EOD = max(abs(fp1/n1-fp2/n2),abs(tp1/p1-tp2/p2))

    return EOD
