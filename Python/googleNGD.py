from apiclient.discovery import build
from math import log
# parser = argparse.ArgumentParser(description='Get Google Count.')
# parser.add_argument('word', help='word to count')
# args = parser.parse_args()

def google(query):

  service = build("customsearch", "v1",
    developerKey="AIzaSyAr343nSW4XMHHYpuM-ojySirUJqdSxBhI")

  res = service.cse().list(
    cx='005460207305187069316:hlh-mjpgjjm',
    q=query,
    ).execute()

  totRes = res['searchInformation']['totalResults']
  
  print(totRes)
  return totRes

  #normalized google distance. the closer to zero the terms measure is the more similar is the semantic meaning is.
def computeNGD(x,y):
    if x == y:
      return 0
    x_ = log(float(google(x)))
    y_ = log(float(google(y)))
    f_xy = log(float(google(x +" "+ y)))
    N = 50 * 1e9   # total number of indexed pages
    return (max(x_, y_) - f_xy) / (log(N) - min(x_, y_))

print("dog vs cat = " + str(computeNGD("dog","cat")))
print("dog vs car = "  + str(computeNGD("dog","car")))
print("car vs house = " + str(computeNGD("car","house")))