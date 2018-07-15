from nltk.corpus import wordnet as wn
import urllib3
from bs4 import BeautifulSoup

url = input("paste in the URL");
http = urllib3.PoolManager()
r = http.request('GET', url)

soup = BeautifulSoup(r.data,'html.parser')
# print(r.data)
print()
print(soup.title.string)
print(soup.find_all('a'))