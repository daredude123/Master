import subprocess, sys
import urllib3
import wordNetDisambiguation
from bs4 import BeautifulSoup
from nltk.corpus import wordnet as wn
import findsimilarwords as findWords
import json

context = ""
#decoding the json and returning what word has been 
def decodeJson(JsonString):
	j = json.loads(JsonString)
	print(j[0]["wordThatWasTagged"] + "\n")
	print(j[0]["context"] + "\n")
	return j

#opening and reading contents to context variable
def openFile(fileName):
	file_obj = open(fileName)
	fileContents = file_obj.read()
	print(fileContents)
	#Setter variablene wordToDisambiguate og context til 
	return decodeJson(fileContents)

def chooseWord():
	#printing the context
	splitHeaderList = context.split(' ')
	counter = 0 
	for x in splitHeaderList:
		counter+=1
		print(" " + str(counter) +" : " + x)
	word = input("Write the word you want to disambiguate: ")
	return word

#Run the disambiguation on both the Perl and Python WSD algorithms. 
#Both uses the Lesk algorithm for now
def doTheDeed(context1,word):
	print("disambiguation the word: " + word)
	print("Based on this context: ")
	print(context1)
	print("Perl dismabiguation\n----------------\n")
	perlContext = " ".join(context1)
	perlDis(perlContext,word)
	print("\n")
	print("Python dismabiguation\n----------------\n")
	wordNetDisambiguation.disambiguate(context1,word)

#Kobler til den gitte url gitt gjennom parameteren og leverer HTML koden som en String
def connectToSiteAndRetrieve(URL):
	http = urllib3.PoolManager()
	r = http.request('GET',URL)
	string = r.data
	try:
		string
	except NameError:
		print("HTML fetch failed")
		return "There are nothing to retrieve"
	else:
		return string

#Henter bare <H1> elementer. For det er det eg kommer til å jobbe med
#Paragrafer Kommer siden.
def retrieveHeaders():

	soup = BeautifulSoup(connectToSiteAndRetrieve(url),'html.parser')
	
	header = soup.h1.string



	# paragraph = soup.p.string;

	# print(str(paragraph) + "\n---------------------------")

	# print(str(header)+"\n----------------")
	
	print("\n---------------")

	return header


def perlDis(sentence,word):

	perl = "C:\\Strawberry\\perl\\bin\\perl5.22.1.exe"

	perlScr = "D:/Perl/perlDisambiguate.pl"

	params = sentence+"--"+word

	perlScr = subprocess.Popen([perl,perlScr, params], stdout=subprocess.PIPE)

	print(perlScr.stdout.read())
	value = perlScr.stdout.read()
	return value


def path_similarity(word1,word2):
	x = wn.synset(word1+'.n.01')


json = openFile("-           tags downloaded for en.wikipedia.org -            time of download 21.3.2016, 10.25.32-            .json")

newContext = findWords.extractNounsForDis(json[0]['wordThatWasTagged'],json[0]['context'])
wordToDisambiguate= json[0]['wordThatWasTagged']
doTheDeed(newContext,wordToDisambiguate)