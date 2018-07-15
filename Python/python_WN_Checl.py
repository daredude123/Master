from nltk.corpus import wordnet as wn

word = input("Write your word ")

q = wn.synsets(word)

print(q)
