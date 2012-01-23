import urllib2
fd = urllib2.urlopen('http://mehfilindian.com/LunchMenuTakeOut.htm')
print 'eggplant' in fd.read().lower()
