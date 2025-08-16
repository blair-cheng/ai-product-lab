import pytest
import numpy as np
import warnings

from free_response.data import build_dataset
from src.naive_bayes import NaiveBayes
from src.naive_bayes_em import NaiveBayesEM


@pytest.mark.filterwarnings("ignore:divide by zero:RuntimeWarning")
@pytest.mark.filterwarnings("ignore:invalid value encountered in multiply:RuntimeWarning")
def test_frq1():
    """
    A test case that a large-vocab dataset like that used in FRQ1 and checks to
    see whether the likelihood is finite and decreases after a couple iters
    """

    # Load the dataset
    data, labels, speeches, vocab = build_dataset(
        "data", num_docs=10, max_words=200, vocab_size=1000)

    labels[5:] = np.nan  # treat five speeches as unlabeled

    naive_bayes = NaiveBayes()
    naive_bayes.fit(data, labels)
    nb_likelihood = naive_bayes.likelihood(data, labels)
    nb_preds = naive_bayes.predict(data)

    isfinite = np.isfinite(labels)  # get rid of unlabelled speeches for accuracy
    assert np.isfinite(nb_likelihood), "NB should have finite likelihood"
    assert np.mean(nb_preds[isfinite] == labels[isfinite]) > 0.5, "NB should have 50+% accuracy"

    prev_likelihood = -np.inf
    nbem_likelihoods = []
    for i in range(1, 6):
        # Fit and evaluate the NB+EM model
        naive_bayes_em = NaiveBayesEM(max_iter=i)
        naive_bayes_em.fit(data, labels)
        nbem_likelihood = naive_bayes_em.likelihood(data, labels)
        preds = naive_bayes_em.predict(data)

        assert np.isfinite(nbem_likelihood), "NBEM should have finite likelihood"
        assert nbem_likelihood >= prev_likelihood, "NBEM likelihood should improve"
        assert np.mean(preds[isfinite] == labels[isfinite]) > 0.5, "NBEM should have 50+% accuracy"
        prev_likelihood = nbem_likelihood
        nbem_likelihoods.append(nbem_likelihood)

    nbem_improvements = [nbem_likelihoods[i + 1] - nbem_likelihoods[i]
                         for i in range(len(nbem_likelihoods) - 1)]
    assert np.sum(np.array(nbem_improvements) > 0) > 1, "NBEM likelihood should improve"

    assert nb_likelihood != nbem_likelihood, "NB should differ from NBEM"
    assert not np.all(nb_preds == preds), "NB should differ from NBEM"


if __name__ == "__main__":
    test_frq1()
