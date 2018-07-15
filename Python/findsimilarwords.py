from nltk.tag import pos_tag as pos
from nltk.tokenize import word_tokenize as tokenize
import googleNGD as ngd


#Finner lister over substantiver fra en setning #NNS #NN
def findNouns(context):
    tokenized = tokenize(context)
    sentence = pos(tokenized)
    properNouns = [word for word, pos in sentence if pos == 'NN' or pos == 'NNS' or pos == 'NNP' or pos == 'NNPS']
    print("List over The nouns ")
    # print(properNouns)
    print("\n")
    return properNouns


#Returnerer listen over Substantiver som kan hjelpe i oppgaven med å disambiguere ord.
def extractNounsForDis(wordToMeasure, context):
    returnList = []
    for h in findNouns(context):
        measure = ngd.computeNGD(wordToMeasure, h)
        print("Measure for " + h + " : " + str(measure))
        if measure == 0:
            pass
        elif measure < 0.3:
            print("adding!")
            returnList.append(h)

    return returnList
