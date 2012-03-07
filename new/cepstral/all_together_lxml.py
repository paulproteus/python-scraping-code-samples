import just_post_via_mechanize
import lxml.html
import urlparse

def get_wav_link():
    fp = just_post_via_mechanize.main()
    doc = lxml.html.parse(fp).getroot()
    link_targets = [link.attrib.get('href', '') for link in doc.cssselect('a')]
    return [target for target in link_targets if 'wav' in target][0]
    return thing

def main():
    return urlparse.urljoin('http://cepstral.com/cgi-bin/demos/weather', get_wav_link())

if __name__ == '__main__':
    print main()
