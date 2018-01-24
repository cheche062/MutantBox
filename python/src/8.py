import functools

def log(text):
    def log2(func):
        @functools.wraps(func)
        def wrapper(*args, **kw):
            print(text + '  2018~')
            return func(*args, **kw)
        return wrapper
    return log2


@log('my log')
def now():
    print('hello cheche')

now()
print(now.__name__)