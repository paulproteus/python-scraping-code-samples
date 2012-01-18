# Built-in tree generator
import html5lib
import urllib2
def make_native_tree():
    fd = urllib2.urlopen('http://mehfilindian.com/LunchMenuTakeOut.htm')
    parser = html5lib.HTMLParser()
    document = parser.parse(f)
    return document

# If you want a specific tree format

# minidom
import html5lib
from html5lib import treebuilders
import urllib2
def make_dom():
    fd = urllib2.urlopen('http://mehfilindian.com/LunchMenuTakeOut.htm')
    parser = html5lib.HTMLParser(tree=treebuilders.getTreeBuilder("dom"))
    minidom_document = parser.parse(fd)
    return minidom_document

# BeautifulSoup
import html5lib
from html5lib import treebuilders
import urllib2

def make_soup():
    fd = urllib2.urlopen('http://mehfilindian.com/LunchMenuTakeOut.htm')
    parser = html5lib.HTMLParser(tree=treebuilders.getTreeBuilder("beautifulsoup"))
    minidom_document = parser.parse(fd)
    return minidom_document

# More info: http://code.google.com/p/html5lib/wiki/UserDocumentation
make_tree = make_dom
