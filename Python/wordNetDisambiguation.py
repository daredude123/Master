from nltk.wsd import lesk
from nltk.corpus import wordnet as wn
import urllib3
import json


def retrieveJSON(word):
    http = urllib3.PoolManager()
    r = http.request('GET', 'https://imdb.uib.no/lexitags/lexitags/'+word)
    string = r.data
    print(r.status, string)
    decodeJSON(string)


    def decodeJSON(JsonString):
        j = json.loads(JsonString.decode("utf-8"))
        print("Printing JSON explanation" + "\n")
        print(j["senses"][0]["explanation"])


        def senses(word):
            senselist = wn.synsets(word)
            print("There are " + str(len(senselist)) + " senses available for the word: " + word)
            print("Senses:" + "\n")
            for x in senselist:
                print(x.definition() + "\n")


                def chooseWord():
                    word = input("Choose which word you want to disambiguate: ")
                    return word


                    def chooseSentence():
                        sentence = input("Write your sentence: ")
                        if "," in sentence:
                            sentence.replace(",", "")
                        elif "  " in sentence:
                            sentence.replace("  ", " ")
                            return sentence.split()

# def disambiguate():
#     #print(lesk(chooseSentence(),chooseWord()))
#     sentence = chooseSentence()
#     word = chooseWord()
#     sense = lesk(sentence,word)
#     print("-----------------------------------------------\n")
#     print(sense)
#     print("-----------------------------------------------\n")
#     print("definition: " + " " + sense.definition())
#     print("-----------------------------------------------\n")
#     retrieveJSON(word)
#     senses(word)


#sentence is a list og context words
def disambiguate(sentencelist, word):
    transvar = str.maketrans("", "", "?!,.")
    newsentence = [s.translate(transvar) for s in sentencelist]
    sense = lesk(newsentence, word, 'n')
    print(sense)
    # print(sense.definition())
    if sense is None:
        return "N/A"
    else:
        return sense.name()

def readAndDis():
    writeString = ''
    with open('D:/SKOLE/MASTER 2016/testing/Testing database/100URL-target-context.txt', encoding='utf8') as fp:
        for line in fp:
            testLineArr = line.split('|')
            context = testLineArr[2]
            disWord = testLineArr[1]
            # print(context+ ":" +disWord)

            contList = context.split(' ')   
            writeString += disambiguate(contList,disWord)
            writeString += "\n"
    return writeString

def writeMethod(writeString):
    f = open('Python_Vanilla_disambiguation.txt', 'w')
    f.write(writeString)  # python will convert \n to os.linesep
    f.close()  # you can omit in most cases as the destructor will call it


#print(wn.synsets("dog"))
#doglist = wn.synsets("dog")
#print(len(doglist))
# disambiguate(["the","dog","is","awesome","to","play","with"],"dog")

writeStringToFile = readAndDis()
writeMethod(writeStringToFile)
