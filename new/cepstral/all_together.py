import just_post_via_mechanize
import urlparse
import stupid_string_parse
import os

def get_relative_wav_link():
    fp = just_post_via_mechanize.main()
    as_string = fp.read()
    wav_link = stupid_string_parse.parse(as_string)
    return wav_link

def get_absolute_wav_link():
    return urlparse.urljoin('http://cepstral.com/cgi-bin/demos/weather', get_relative_wav_link())

def play_it():
    url = get_absolute_wav_link()
    os.system("mplayer " + url) # UNSAFE

if __name__ == '__main__':
    play_it()
