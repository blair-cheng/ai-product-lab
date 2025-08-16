import warnings
import numpy as np

from src.utils import softmax, stable_log_sum
from src.sparse_practice import flip_bits_sparse_matrix
from src.naive_bayes import NaiveBayes


class NaiveBayesEM(NaiveBayes):
    """
    A NaiveBayes classifier for binary data, that uses both unlabeled and
        labeled data in the Expectation-Maximization algorithm

    Note that the class definition above indicates that this class
        inherits from the NaiveBayes class. This means it has the same
        functions as the NaiveBayes class unless they are re-defined in this
        function. In particular you should be able to call `self.predict_proba`
        using your implementation from `src/naive_bayes.py`.
    """

    def __init__(self, max_iter=10, smoothing=1):
        """
        Args:
            max_iter: the maximum number of iterations in the EM algorithm
            smoothing: controls the smoothing behavior when computing beta
        """
        self.max_iter = max_iter
        self.smoothing = smoothing

    def initialize_params(self, vocab_size, n_labels):
        """
        Initialize self.alpha such that
            `p(y_i = k) = 1 / n_labels`
            for all k
        and initialize self.beta such that
            `p(w_j | y_i = k) = 1/2`
            for all j, k.
        """

        self.alpha = np.ones(n_labels)/n_labels
        self.beta = np.ones((vocab_size,n_labels))/2

    def fit(self, X, y):
        """
        Compute self.alpha and self.beta using the training data.
        You should store log probabilities to avoid underflow.
        This function *should* use unlabeled data within the EM algorithm.

        During the E-step, use the NaiveBayes superclass self.predict_proba to
            infer a distribution over the labels for the unlabeled examples.
            Note: you should *NOT* overwrite the provided `y` array with the
            true labels with your predicted labels. 

        During the M-step, update self.alpha and self.beta, similar to the
            `fit()` call from the NaiveBayes superclass. Unlike NaiveBayes,
            you will use unlabeled data. When counting the words in an
            unlabeled document in the computation for self.beta, to replace
            the missing binary label y, you should use the predicted probability
            p(y | X) inferred during the E-step above.

        For help understanding the EM algorithm, refer to the lectures and
            the handout.

        self.alpha should contain the marginal probability of each class label.

        self.beta is an array of shape [n_vocab, n_labels]. self.beta[j, k]
            is the probability of seeing the word j in a document with label k.
            Remember to use self.smoothing. If there are M documents with label
            k, and the `j`th word shows up in L of them, then `self.beta[j, k]`.

        Note: if self.max_iter is 0, your function should call
            `self.initialize_params` and then break. In each
            iteration, you should complete both an E-step and
            an M-step.

        Don't worry about divide-by-zero RuntimeWarnings.

        Args: X, a sparse matrix of word counts; Y, an array of labels
        Returns: None
        """
        n_docs, vocab_size = X.shape
        n_labels = 2
        self.vocab_size = vocab_size

        self.initialize_params(vocab_size, n_labels)
            
        for _ in range(self.max_iter):
            # E-step: use self.predict_proba to infer p(y | X)
            # p(yi|Xi, alpha_t_th, beta_t_th) 
            # = p(Xi|yi = y',beta_t_th )p(yi = y'|alpha_t_th)
            # y': predicted y; yi: given y
            y_pred = self.predict_proba(X)
            for i in range(len(y)):
                if not np.isnan(y[i]):
                    y_pred[i,:] = 0
                    y_pred[i, int(y[i])] = 1

            # M-step: update self.alpha, self.beta through y_pred
            sum_y_pred = np.sum(y_pred,axis = 0)
            sum_X_y_pred = X.T @ y_pred 
            self.alpha = sum_y_pred/np.sum(sum_y_pred)
            self.beta = (self.smoothing + sum_X_y_pred)/(2 * self.smoothing + sum_y_pred[None, :] )


    def likelihood(self, X, y):
        """
        Using the self.alpha and self.beta that were already computed in
            `self.fit`, compute the LOG likelihood of the data. You should use
            logs to avoid underflow.  This function *should* use unlabeled
            data.

        For unlabeled data, we predict `p(y_i = y' | X_i)` using the
            previously-learned p(x|y, beta) and p(y | alpha).
            For labeled data, we define `p(y_i = y' | X_i)` as
            1 if `y_i = y'` and 0 otherwise; this is because for labeled data,
            the probability that the ith example has label y_i is 1.

        The tricky aspect of this likelihood is that we are simultaneously
            computing $p(y_i = y' | X_i, \alpha^t, \beta^t)$ to predict a
            distribution over our latent variables (the unobserved $y_i$) while
            at the same time computing the probability of seeing such $y_i$
            using $p(y_i =y' | \alpha^t)$.

        Note: In implementing this equation, it will help to use your
            implementation of `stable_log_sum` to avoid underflow. See the
            documentation of that function for more details.

        We will provide a detailed writeup for this likelihood in the PDF
            handout.

        Don't worry about divide-by-zero RuntimeWarnings.

        Args: X, a sparse matrix of word counts; Y, an array of labels
        Returns: the log likelihood of the data.
        """
        assert hasattr(self, "alpha") and hasattr(self, "beta"), "Model not fit!"

        n_docs, vocab_size = X.shape
        n_labels = 2
        log_alpha = np.log(self.alpha)
        log_beta = np.log(self.beta)

        flipped_X = flip_bits_sparse_matrix(X)
        log_minus_beta = np.log(1-self.beta)
        
        # log p(Xij|yj)  
        log_p_X_given_y = X @ log_beta + flipped_X @ log_minus_beta
        # log_p(y,Xij)  = log p(yj|Xij)
        log_pyX = log_alpha + log_p_X_given_y 

        y_pred = self.predict_proba(X)
        for i in range(len(y)):
            if not np.isnan(y[i]):
                y_pred[i,:] = 0
                y_pred[i, int(y[i])] = 1

        log_likelihood = np.sum(y_pred * log_pyX )

        return log_likelihood
