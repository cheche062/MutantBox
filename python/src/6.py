from functools import reduce
from decimal import Decimal

def f(x):
    return x * x

r = map(f, [1, 2, 3, 4])


list1 = ['adam', 'LISA', 'barT']
list2 = [2, 3, 5]

L = [('Bob', 75), ('Adam', 92), ('Bart', 66), ('Lisa', 88)]

L2 = sorted(L, key = lambda v: -v[1])

print(L2)




