import requests
import urllib
import lxml.html

YAHOO_BASE='http://search.yahoo.com/search?p='

def search_for(s):
    page_text = requests.get(YAHOO_BASE + urllib.quote(s)).text
    parsed = lxml.html.fromstring(page_text)
    urls = parsed.cssselect('.url')
    first_url = urls[0]
    return first_url.text_content()

if __name__ == '__main__':
    print search_for('asheesh')
