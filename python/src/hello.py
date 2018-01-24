
'a test module'

__author__ = 'cheche'

import sys

class Person(object):
    count = 0
    def __init__(self, name, score):
        Person.count += 1
        self.__name = name    
        self.__score = score    

    def print_score(self):
        print('%s, %s' % (self.__name, self.__score))

