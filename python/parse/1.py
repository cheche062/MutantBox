import urllib.request
import urllib.parse
import re

url = "http://sh.58.com/job/?key=python&final=1&jump=1"
response = urllib.request.urlopen(url)
b = response.read()
html = b.decode()

results = re.findall(r'<a href=.*?title="(\w+)\">.*?</a>', html)

print(results) 
print(len(results))