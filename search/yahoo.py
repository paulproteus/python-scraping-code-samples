import urllib2
import urllib
import BeautifulSoup

YAHOO_BASE='http://search.yahoo.com/search?p='

def search_for(s):
    fd = urllib2.urlopen(YAHOO_BASE + urllib.quote(s))
    response = fd.read()
    soup = BeautifulSoup.BeautifulSoup(response)
    first_url = soup(attrs={'class': 'url'})[0]
    url_text = ''.join(first_url(text=True))
    return url_text

if __name__ == '__main__':
    print search_for('asheesh')
