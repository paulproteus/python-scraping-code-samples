import just_post
import urlparse
import html5lib
import html5lib.treebuilders
import os

def main():
    fd = just_post.main()
    parser = html5lib.HTMLParser(tree=html5lib.treebuilders.getTreeBuilder('beautifulsoup'))
    parsed = parser.parse(fd)
    relative_wav_link = parsed.find('a', href=lambda s: 'wav' in s)['href']
    absolute_wav_link = urlparse.urljoin(just_post.URL, relative_wav_link)
    os.system('mplayer ' + absolute_wav_link) # FIXME: totally unsafe

if __name__ == '__main__':
    main()

