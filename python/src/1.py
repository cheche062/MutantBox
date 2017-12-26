import os

lis = ['dada', 'hehe']
# dic = {"name": 'meihao', "age": 18}

lis = [item + "\n" for item in lis]

f = open("./people.txt", 'r', encoding="utf8")
# f.writelines(lis)

with f as f:
    for line in f:
        print(line, end="")

# f.close()
# print(lis)


