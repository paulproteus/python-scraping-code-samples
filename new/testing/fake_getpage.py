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

def record_found_eggplant():
    pass

def has_eggplant(s):
    if 'eggplant' in s.lower():
        record_found_eggplant()

def make_eggplant_checker():
    d = twisted.web.client.getPage('http://mehfilindian.com/LunchMenuTakeOut.htm')
    d.addBoth(has_eggplant)

class CurryTestTwist(unittest.TestCase):
    @mock.patch('record_found_eggplant')
    @mock.patch('twisted.web.client.getPage', fakeGetPageFn)
    def test(self, mock_record_found_eggplant):
        make_eggplant_checker()
        self.assertTrue(mock_record_found_eggplant.called)


if __name__ == '__main__':
    unittest.main()
