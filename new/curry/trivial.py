import mechanize

def is_there_eggplant():
    b = mechanize.Browser()
    fd = b.open('http://mehfilindian.com/LunchMenuTakeOut.htm')
    return 'eggplant' in fd.read()

if __name__ == '__main__':
    if is_there_eggplant():
        print 'Yes!'

