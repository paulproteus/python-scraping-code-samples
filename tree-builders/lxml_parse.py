from lxml.html import parse
import urllib2

def make_tree():
    fd = urllib2.urlopen('http://mehfilindian.com/LunchMenuTakeOut.htm')
    doc = parse(fd).getroot()
    return doc
