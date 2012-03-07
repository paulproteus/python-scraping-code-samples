import just_post_via_mechanize
import urlparse
import stupid_string_parse

def get_wav_link():
    fp = just_post_via_mechanize.main()
    as_string = fp.read()
    wav_link = stupid_string_parse.parse(as_string)
    return wav_link

def main():
    return urlparse.urljoin('http://cepstral.com/cgi-bin/demos/weather', get_wav_link())

if __name__ == '__main__':
    print main()
