def add_end(L = None):
    if L is None:
        L = []
    L.append('END')
    return L
def add(*numbers):
    sum = 0
    for n in numbers:
        sum += n
    return sum

nums = [2, 8, 5]

def person(name, age, **kw):
    print('name:', name, 'age:', age, 'other:', kw)

person('cheche', 90, city='shanghai', job='coder')
# print(add(*nums))
