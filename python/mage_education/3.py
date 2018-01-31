lst = [2, 4, 6, 4, 2, 3, 8, 3]

def sort(lst):
    newlist = []
    
    for x in lst:
        for i, y in enumerate(newlist):
            if x < y:
                newlist.insert(i, x)
                break
        else:
            newlist.append(x)

    return newlist

print(sort(lst))
# obj = {'name':'cheche'}
# arr = [3, 99]
# for k in arr:
#     print(k)

