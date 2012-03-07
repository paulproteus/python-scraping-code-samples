# imports
import xml.dom.minidom
import sys

def main(filename):
    # Parse the file
    parsed = xml.dom.minidom.parse(open(filename))
    # Get title element
    title_element = parsed.getElementsByTagName('title')[0]
    # Print just the text underneath it
    print title_element.firstChild.wholeText

if __name__ == '__main__':
    main(filename=sys.argv[1])
