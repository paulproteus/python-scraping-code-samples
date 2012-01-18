import urllib2
import urllib
import BeautifulSoup

GOOGLE_BASE='http://google.com/search?q='

def search_for(s):
    fd = urllib2.urlopen(GOOGLE_BASE + urllib.quote(s))
    response = fd.read()
    soup = BeautifulSoup.BeautifulSoup(response)
    first_url = soup('cite')[0]
    url_text = ''.join(first_url(text=True))
    return url_text

if __name__ == '__main__':
    print search_for('asheesh')
