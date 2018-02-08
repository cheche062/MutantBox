def jiechen(n):
    if n == 0:
        return 0
    if n == 1:
        return 1
    lst = []
    mul = 1
    for k in range(1, n + 1):
        mul *= k
        lst.append(mul)

    return sum(lst) 


print(jiechen(5))       


