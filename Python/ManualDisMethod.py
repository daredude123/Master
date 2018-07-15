
from nltk.corpus import wordnet as wn
# from nltk.corpus import genesis, wordnet_ic
from nltk.tag import pos_tag as pos
from nltk.tokenize import word_tokenize as tokenize
from findsimilarwords import findNouns
import operator
import re
import timeit

# semcor_ic = wordnet_ic.ic('ic-semcor.dat')
# brown_ic = wordnet_ic.ic('ic-brown.dat')
# genesis_ic = wn.ic(genesis, False, 0.0)


#Default context synset is now n.01. For now....(example: dog.n.01)
#Restricted to similarity measures between same POS v-v n-n etc.
#For now it only computes nouns
#This algorithm only adds each measure.
def disambiguationAlgo(targetWordSynsets,context1):
    returnSynsetHashValues = {}
    #Gå igjennom Target sine senser/synsets
    for targetSS in targetWordSynsets:
        print("#############\nTarget synset: ", targetSS, "\n#############")
        # print(targetSS)
        returnSynsetHashValues[targetSS] = 0
        #Sammenligne mot hvert av ordene i setning
        for word in context1:
            wordSynset = ''
            try:
                wordSynset = wn.synsets(word, pos=wn.NOUN)[0]
            except IndexError:
                continue
            if wordSynset == targetSS:
                measure = 0
                measure = targetSS.wup_similarity(wordSynset)
                #dividing the score in half helps not giving the number one sense to much score.
                newMeasure = measure/2
                print("newMEASURE ****************", newMeasure)
                #Adds the Measure here... Probably a better way to do it.   #### It only adds the score #### Problem when the target synset is equal to the contextsynset, retrieves a way to high score, which can ruin the measurment
                returnSynsetHashValues[targetSS] += newMeasure
                print("********** VALUE ************       :     ", returnSynsetHashValues[targetSS])
                print("Measure: "+str(wordSynset)+" : "+str(targetSS)+" = "+str(measure))
            elif len(targetWordSynsets) == 1:
                print("Only one synset.")
                returnSynsetHashValues[targetSS] = 10000
                return targetSS
            else:
                measure = 0
                measure = targetSS.wup_similarity(wordSynset)
                print(measure,"#############\n",targetSS," : ",wordSynset)
                #Add the measure to the list.
                returnSynsetHashValues[targetSS] += measure
                print("********** VALUE ************       :     ", returnSynsetHashValues[targetSS])
                print("Measure: "+str(wordSynset)+" : "+str(targetSS)+" = "+str(measure))
    return returnSynsetHashValues

# context = " was an English author, journalist and naval intelligence officer who is best known for his James Bond series of spy novels. Fleming came from a wealthy family connected to the merchant bank Robert Fleming & Co"
# context = "Flying through turbulence, or experiencing a bumpy landing is like getting caught off-guard by a pop quiz you didn't study for. Unfortunately, all you have to go off of are some vague statistics you heard about flight being the safest way to travel and terrifying plane crashes you see in movies and on the news. It turns out, there are a handful of pretty crucial things we've gotten just completely wrong about how people fly and get killed while doing so."

def readAndDis():
    writeString = ""
    with open('D:/SKOLE/MASTER 2016/testing/Testing database/100URL-target-context.txt', encoding='utf8') as fp:
        for line in fp:
            testLineArr = line.split('|')
            context = testLineArr[2]
            disWord = testLineArr[1]
            # print(context+":"+disWord)
            # context = "The British were the first to introduce armored vehicles, in 1916 -- the term tank was actually a code word intended to fool eavesdropping Germans into thinking they were discussing (inordinately deadly) water tanks. Even then, the Brits relied heavily on horses to move artillery and supplies, drafting more than a million of them to slog through the muddy trenches of Belgium and France."
            # print(pos(tokenize(context)))
            # print("The sentence : ", context, "\n########")
            regex = re.compile('[^a-zA-Z]')
            #First parameter is the replacement, second parameter is your input string
            regex.sub(' ', context)



            context1 = findNouns(context)
            #Print which word from the context that you want to disambiguate
            # print("write your word \n")

            wordPos = pos(tokenize(disWord))
            print(wordPos)
            if wordPos[0][1][0] == 'V':
                targetWordSynsets = wn.synsets(disWord, pos=wn.VERB)
            else:
                targetWordSynsets = wn.synsets(disWord, pos=wn.NOUN)
            
            if targetWordSynsets is None:
                return
            print(targetWordSynsets)
            # targetWordSynsets[0].pos


            #Run the program timer
            start = timeit.timeit()
            synsetHashValues = disambiguationAlgo(targetWordSynsets,context1)
            end = timeit.timeit()

            print("\n###\nTime used in algorithm : " + str(end-start) + " seconds\n###\n")


            print("Based on the context :")
            # print("---".join(context1), "\n")


            writeString += "\n"
            if isinstance(synsetHashValues,dict) :

                for key, value in sorted(synsetHashValues.items(), key=operator.itemgetter(1),reverse=True):
                    syns = key.name()
                    print(key.name()+ " : "+ str(value)+ "\n")
                    writeString += key.name()+" : "+str(value)+"\n"
                writeString += "\n"
            else:
                writeString+=synsetHashValues.name()+"\n"
    return writeString


def writeMethod(writeString):
    f = open('Python_ManualDisambiguation_reporttop3.txt', 'w')
    f.write(writeString)  # python will convert \n to os.linesep
    f.close()  # you can omit in most cases as the destructor will call it

synsetHashValues = {}
writeToFile = " "
writeToFile = readAndDis()
print(writeToFile)
writeMethod(writeToFile)
