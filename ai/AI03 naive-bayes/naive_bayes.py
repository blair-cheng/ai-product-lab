import math
import re
from collections import defaultdict
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
from sklearn.feature_extraction.text import TfidfVectorizer

class Bayes_Classifier:

    def __init__(self):
        self.star_count = {1: 0, 5: 0}
        self.word_frcy = {1:defaultdict(int), 5: defaultdict(int)}
        self.word_count = {1:0, 5: 0}
        self.vocab = set()

    def preprocess_text(self, text):
        stop_words = set(stopwords.words('english'))
        ps = PorterStemmer()  
        words = re.sub(r'[^\w\s]', '', text.lower()).split()
        filtered_words = [ps.stem(word) for word in words if word not in stop_words]
        return  ' '.join(filtered_words)
      
    def train(self, lines):
        """
        The train function of the classifier class 
        should take a list of lines from the dataset 
        """
        for line in lines:
            parts = line.strip().split('|', 2)
            if len(parts) <3:
                continue
            try:
                label, _, text = parts
                label = int(label)
            except ValueError:
                continue

            processed_text = self.preprocess_text(text)
            print(f"Processed text: '{processed_text}'")
            filtered_words = processed_text.split()

            self.star_count[label] += 1
            
            for word in filtered_words:
                self.word_frcy[label][word]+= 1
                self.word_count[label] += 1
                self.vocab.add(word)

        total_reviews = sum(self.star_count.values())

        self.p_label = {
            1:self.star_count[1]/total_reviews,
            5:self.star_count[5]/total_reviews
        }
        print(f"Total reviews processed: {total_reviews}")
        print(f"Classes: {self.star_count}")

    def classify(self, lines):
        """
        The classify function should take another list of lines 
        to be classified and return a Python list of strings 
        indicating the predicted class (1 or 5).
        P(positive|f) = P(positive) * (P(f1|positive) * ...* P(fn|positive))
        """
        predictions = []

        for line in lines:
            parts = line.strip().split('|', 1)
            if len(parts) <2:
                continue
            
            _, text = parts

            processed_text = self.preprocess_text(text)
            text_words = processed_text.split()

            log_p_label_given_text = {}
            for label in [1, 5]:
                # log(p_lable): logP(1star), logP(5star)
                log_p_label = math.log(self.p_label[label] + 1e-10)

                # P(text|label) = P(word1|label) * ... * P(wordn|label)
                log_p_text_given_label = sum(math.log(
                    # P(word1|label) = P(word1 and label)/P(label)
                    # = count(label with word1 + 1)/ count(label + vocab)
                    # Add-One Smoothing
                    (self.word_frcy[label].get(word, 0) + 1) /
                    (self.word_count[label] + len(self.vocab))
                ) for word in text_words)

                # logP(label|text) = logP(label) + logP(words|label)
                log_p_label_given_text[label] = log_p_label + log_p_text_given_label 

            predicted_label = max(log_p_label_given_text, key = log_p_label_given_text.get)
            predictions.append(str(predicted_label))

        return predictions

