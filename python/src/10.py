import functools

int2 = functools.partial(int, base = 2)

num = int('12', base = 8)

print(int2('11'))