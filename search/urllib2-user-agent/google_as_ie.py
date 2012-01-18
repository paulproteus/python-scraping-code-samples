import urllib2
import urllib
import BeautifulSoup

GOOGLE_BASE='http://google.com/search?q='

def search_for(s):
    request = urllib2.Request(GOOGLE_BASE + urllib.quote(s))
    request.add_header('User-Agent',
        'Mozilla/4.0 (compatible; MSIE 5.0; Windows 98;)')
    # More IE user-agents at http://www.useragentstring.com/pages/Internet%20Explorer/
    opener = urllib2.build_opener()
    response = opener.open(request).read()
    soup = BeautifulSoup.BeautifulSoup(response)
    first_url = soup('cite')[0]
    url_text = ''.join(first_url(text=True))
    return url_text

if __name__ == '__main__':
    print search_for('asheesh')
