import mock
import unittest
import urllib2

def has_eggplant():
    data = urllib2.urlopen('http://mehfilindian.com/LunchMenuTakeOut.htm').read()
    return 'eggplant' in data.lower()

class MyUrlOpen:
    def __init__(self, *args, **kwargs):
        pass

    def read(self):
        return open('saved-menu.html').read()

class CurryTestSlow(unittest.TestCase):
    @mock.patch('urllib2.urlopen')
    def test(self, mock_urlopen):
        mock_urlopen.side_effect = MyUrlOpen
        self.assertTrue(has_eggplant())

if __name__ == '__main__':
    unittest.main()
