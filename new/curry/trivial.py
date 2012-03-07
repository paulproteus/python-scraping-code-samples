import urllib2

def is_there_eggplant():
    fd = urllib2.urlopen('http://mehfilindian.com/LunchMenuTakeOut.htm')
    return 'eggplant' in fd.read()

if __name__ == '__main__':
    if is_there_eggplant():
        print 'Yes!'

