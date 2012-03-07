import twisted.internet.defer
from twisted.internet import reactor
import twisted.web.client

def record_found_eggplant():
    print "Sweet! There is eggplant."

def has_eggplant(s):
    if 'eggplant' in s.lower():
        record_found_eggplant()

def make_eggplant_checker():
    d = twisted.web.client.getPage('http://mehfilindian.com/LunchMenuTakeOut.htm')
    d.addBoth(has_eggplant)
    d.addBoth(lambda _: reactor.stop())

if __name__ == '__main__':
    make_eggplant_checker()
    reactor.run()
