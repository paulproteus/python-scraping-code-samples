import unittest
import urllib2

def get_page_data():
    return urllib2.urlopen('http://mehfilindian.com/LunchMenuTakeOut.htm').read()

def has_eggplant(page_data):
    return 'eggplant' in page_data.lower()

class CurryTestSlow(unittest.TestCase):
    def test(self):
        page_data = open('saved-menu.html').read()
        self.assertTrue(has_eggplant(page_data))

if __name__ == '__main__':
    unittest.main()
