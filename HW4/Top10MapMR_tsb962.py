# -*- coding: utf-8 -*-
"""
Created on Fri Oct 25 12:21:19 2019

@author: tsbloxsom
"""

from mrjob.job import MRJob
import numpy as np

class MRtop10(MRJob):

    def mapper(self, _, line):
        yield None, int(line)

    def combiner(self, _, salary):
        top = list(np.zeros(10)) #init your top ten list
        
        for salary in salaries:
            for index, record in enumerate(top):
                if salary > record:
                    top.insert(index, salary)
                    del top[-1]
                    break
        for salary in range(len(top)):
            yeild None, top[salary]
        
    def reducer(self, _, salaries):
        top = list(np.zeros(10)) #init your top ten list
        
        for salary in salaries:
            for index, record in enumerate(top):
                if salary > record:
                    top.insert(index, salary)
                    del top[-1]
                    break
                
        yield None, top
        
if __name__ == '__main__':
    MRtop10.run()
