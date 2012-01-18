import beautifulsoup_parse

def search():
    tree = beautifulsoup_parse.make_tree()
    # find all 'a' elements
    links = tree('a')
    # equivalently:
    assert links == tree.findAll('a')

    # Grab just the first
    assert links[0] == tree.a

    # Grab all the text under that tag
    print tree.a.findAll(text=True)

    # Find the link that points to menu.htm
    online_link = tree.find('a', {'href': lambda target: 'menu' in target})
    print online_link.findAll(text=True)

if __name__ == '__main__':
    search()
