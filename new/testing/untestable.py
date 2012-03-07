import unittest
import urllib2

def has_eggplant():
    data = urllib2.urlopen('http://mehfilindian.com/LunchMenuTakeOut.htm').read()
    return 'eggplant' in data.lower()

class CurryTestSlow(unittest.TestCase):
    def test(self):
        self.assertTrue(has_eggplant())

if __name__ == '__main__':
    unittest.main()
