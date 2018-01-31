import datetime
import time

def logger(fn):
    def wrap(*args, **kwargs):
        # before
        print('args={}, kwargs={}'.format(args, kwargs))
        start = datetime.datetime.now()

        result = fn(*args, **kwargs)

        # after
        delte = (datetime.datetime.now() - start).total_seconds()

        print('{} took {}s.'.format(fn.__name__, delte))
        return result
    return wrap

@logger
def new_add(x, y):
    time.sleep(3)
    return x + y

# new_add = logger(new_add)

print(new_add(888, 9.7))