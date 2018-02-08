def add(base):
    def inner():
        nonlocal base
        base = base + 1
        print(base) 
    return inner


newadd1 = add(5)
newadd2 = add(10)

newadd1()
newadd1()
newadd1()

newadd2()
newadd2()
newadd2()
    