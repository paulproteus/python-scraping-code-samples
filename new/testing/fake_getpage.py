import mock
import twisted.internet.defer
import unittest
import twisted.web.client

class FakeGetPage(object):
    def __init__(self):
        self.url2data = {
            'http://mehfilindian.com/LunchMenuTakeOut.htm':
                open('saved-menu.html').read()}

    def getPage(self, url):
        d = twisted.internet.defer.Deferred()
        d.callback(self.url2data[url])
        return d
fakeGetPageFn = FakeGetPage().getPage

def has_eggplant(s):
    return 'eggplant' in s.lower()

def make_eggplant_checker():
    d = twisted.web.client.getPage('http://mehfilindian.com/LunchMenuTakeOut.htm')
    d.addBoth(has_eggplant)

class CurryTestSlow(unittest.TestCase):
    @mock.patch('twisted.web.client.getPage', fakeGetPageFn)
    def test(self):
        pass

if __name__ == '__main__':
    unittest.main()
