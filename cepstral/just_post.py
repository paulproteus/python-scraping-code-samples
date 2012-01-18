import urllib2
import urllib
import BeautifulSoup

# The URL to this service
URL = 'http://www.cepstral.com/cgi-bin/demos/weather'


def main():
    # Here is the data that FireBug said we sent
    postdict = {'city' : 'San Francisco',
                'demotype' : 'actual',
                'state' : 'CA',
                'voice' : 'David',
                'submit':'Synthesize the weather'}

    # Encode it into HTTP form, blah de blah blah
    postme = urllib.urlencode(postdict)

    # Send it...
    fd = urllib2.urlopen(URL, postme)
    return fd

