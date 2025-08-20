'''
Merge Strings Alternately
Method: Two Pointers
'''

import unittest

class Solution:
    def mergeAlternately(self, word1: str, word2: str) -> str:
        m = len(word1)
        n = len(word2)
        i = 0
        j = 0

        """
        Ds: list
        Difference between List and Str:
        1. DS:
            List: ordered sequence of items: int, float, str
            Str: a sequence of characters
        2. Mutability: 
            List: insert, remove, reverse, slicing elements
            String: immutable
        3. Operation: 
            List: append, extend, insert, pop, remove, sort, reverse, slicing
            Str: Concatenation (+), repetition (*), slicing (s[1:3]), join, find, replace, format
        4. Syntax: 
            List: [1, 2, 's']
            Str: 'sdf'
        """
        result = []

        while i < m or j < n:
            if i < m:
                result += word1[i]
                i += 1
            if j < n:
                result += word2[j]
                j += 1
        return "".join(result)
    
class TestMergeAlternately(unittest.TestCase):
    def setUp(self):    
        self.solution = Solution()


    def test_equal_length(self):
        word1, word2 = "abc", "pqr"
        self.assertEqual(self.solution.mergeAlternately(word1, word2), "apbqcr")


    def test_second_word_longer(self):
        word1, word2 = "ab", "pqrs"
        self.assertEqual(self.solution.mergeAlternately(word1, word2), "apbqrs")


    def test_first_word_longer(self):
        word1, word2 = "abcd", "pq"
        self.assertEqual(self.solution.mergeAlternately(word1, word2), "apbqcd")


if __name__ == "__main__":
    unittest.main()