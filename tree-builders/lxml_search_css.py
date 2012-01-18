import lxml_parse

def search():
    tree = lxml_parse.make_tree()
    # find all 'a' elements
    links = tree.cssselect('a')
    # equivalently:
    assert links == tree.xpath('//a')

    # Grab just the first
    assert links[0] == tree.xpath('(//a)[1]')[0]
    # xpath uses 1-based indexing and seems to always return a list

    # Grab all the text under that tag
    print links[0].xpath('descendant::text()')

    # This is an lxml extension to XPath
    online_links = tree.xpath('//a[contains(@href, "menu.htm")]')
    print [k.xpath('descendant::text()') for k in online_links]
    # turns out there are two such links; I did not really notice that
    # when doing this with BeautifulSoup

if __name__ == '__main__':
    search()
