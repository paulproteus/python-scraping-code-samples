import BeautifulSoup
import urllib2

def make_tree():
    fd = urllib2.urlopen('http://mehfilindian.com/LunchMenuTakeOut.htm')
    soup = BeautifulSoup.BeautifulSoup(fd)
    return soup
