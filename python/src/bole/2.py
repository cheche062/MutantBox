''' symbols = 'hello'
codes = [v for v in symbols] '''

''' colors = ['black', 'white']
sizes = ['S', 'M']
result = ['%s %s' % (c, s) for c in colors for s in sizes] '''

''' DIAL_CODE = [(86, 'China'), (91, 'India'), (7, 'Russia'), (81, 'Japan')]

### 利用字典推导快速生成字典
country_code = ['%s -> %s' % (country, code) for code, country in DIAL_CODE] '''

import collections
from types import MappingProxyType

# d_proxy = MappingProxyType({'1': 'A'})
# d_proxy['1'] = 'B'

# print('d_proxy', d_proxy)

s1 = set(['2', 2, (1, 2), False, lambda x: x + 1])
s2 = set([2, 3, 4])


def show():
    base = 0
    def inner():
        nonlocal base
        base = base + 1
        return base

    return inner

inner = show()

print(inner())
print(inner())
print(inner())
