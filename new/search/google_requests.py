import requests
import urllib
import lxml.html

GOOGLE_BASE='http://google.com/search?q='

def search_for(s):
    page_text = requests.get(GOOGLE_BASE + urllib.quote(s)).text
    parsed = lxml.html.fromstring(page_text)
    urls = parsed.cssselect('cite')
    first_url = urls[0]
    return first_url.text_content()

if __name__ == '__main__':
    print search_for('asheesh')
