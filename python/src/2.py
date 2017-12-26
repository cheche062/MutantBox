while True:
    a=input("请您输入一个数字：")
    if a == "stop":
        break
    elif not a.isdigit():
        print("您输入的不是数字！！")
    else:
        num = int(a)
        if num < 30:
            print("您输入的数字太小")
        elif num > 50:
            print("您输入的数字太大")
        else:
            print("恭喜您！猜对啦！")




