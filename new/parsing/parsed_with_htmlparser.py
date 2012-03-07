# imports
from HTMLParser import HTMLParser
import sys

# Define our class that processes the file
class MyHTMLParser(HTMLParser):
    document_title = ''
    in_title = False

    def handle_starttag(self, tag, attrs):
        print >> sys.stderr, "Encountered the beginning of a %s tag" % tag
        if tag == 'title':
            print >> sys.stderr, 'Because it was a title tag, change our state that we store further text.'
            self.in_title = True

    def handle_data(self, data):
        if self.in_title:
            self.document_title += data

    def handle_endtag(self, tag):
        print >> sys.stderr, "Encountered the end of a %s tag" % tag
        if tag == 'title':
            print >> sys.stderr, 'Because it was a title tag, change our state to stop caring.'
            self.in_title = False

# Actually use it
def main(filename):
    # Create an instance
    mine = MyHTMLParser()

    # Pass it data
    for line in open(filename):
        mine.feed(line)

    # Close the parser
    mine.close()

    # print the title we extracted
    print '...'
    print ''
    print 'In the end, TITLE value was:'
    print mine.document_title.strip()

if __name__ == '__main__':
    main(sys.argv[1])
