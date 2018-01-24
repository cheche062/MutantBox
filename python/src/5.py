range1 = range(1, 11)

list1 = [x * x for x in range1]



g = (x * x for x in range1)

print(g)
print(next(g))
print(next(g))
print(next(g))

dict1 = {
    "name": "cheche",
    "age": '19',
    "job": "Python"
}

L1 = ['Hello', 'World', 18, 'Apple', None]
L2 = ['Hello', 'World', 'IBM', 'Apple']

L3 = [v.lower() for v in L1 if isinstance(v, str)]

# print(L3)
    