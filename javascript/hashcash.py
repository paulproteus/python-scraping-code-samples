import mechanize
import md5
import datetime
import html5lib
from html5lib import treebuilders
import spidermonkey

def make_soup(s):
    '''Is it soup yet?'''
    parser = html5lib.HTMLParser(tree = treebuilders.getTreeBuilder("beautifulsoup"))
    soup = parser.parse(s)
    return soup

def find_appropriate_script_object(soup):
    # find script source that contains 'function wphc'
    desired_script_source = None
    for tag in soup('script'):
        if tag.contents and 'function wphc' in tag.contents[0]:
            assert desired_script_source is None # Assert there aren't two matches; what would we do then?
            desired_script_source = tag.contents[0]
    assert desired_script_source # assert we actually found it
    return desired_script_source

def extract_wphc_function(desired_script_source):
    # Just select function we want...
    lines = desired_script_source.split('\n')
    function_starts_at = lines.index('function wphc(){')
    lines_with_starting_junk_snipped_off = lines[function_starts_at:]
    function_ends_at = lines.index('}')

    # just function
    just_function_lines = lines_with_starting_junk_snipped_off[:function_ends_at + 1]
    return just_function_lines

def execute_function(just_function_lines):
    # Snip the top to make it an anonymous function
    anonymized_function_lines = ['function () {'] + just_function_lines[1:]
    
    # pass it into SpiderMonkey...
    rt = spidermonkey.Runtime()
    cx = rt.new_context()
    func = cx.execute('\n'.join(anonymized_function_lines))
    value = func()
    return value

def post_comment(url, name, email_address, website, message):
    b = mechanize.Browser()
    b.set_handle_robots(False)
    page_contents = b.open(url).read()
    assert 'Hashcash' in page_contents # The point of this function is to break Hash Cash; ensure it is in use

    soup = make_soup(page_contents)

    # Find the right <script> tag
    desired_script_source = find_appropriate_script_object(soup)

    # Find the actual function we want
    just_function_lines = extract_wphc_function(desired_script_source)

    # Execute it in SpiderMonkey
    value = execute_function(just_function_lines)

    b.select_form(nr=0)
    b['email'] = email_address
    b['author'] = name
    b['comment'] = message
    b['url'] = website

    # mechanize sets the hidden field to be read-only; this disables read-only on all elements in the form
    b.set_all_readonly(False)

    # Set the form field...
    b['wphc_value'] = str(value)

    # and we're ready to present our work to WordPress.
    b.submit()

    # Now go in a web browser and check that the comment actually stuck

def main():
    post_comment("http://scrape-pycon.asheesh.org/hashcash/?p=1", 'Asheesh Laroia', 'Albert.Einstein@mailinator.com', 'http://www.asheesh.org/',
        "Boy, I trust WP HashCash. Plus I will add some random junk: " + 
        md5.md5(datetime.datetime.now().isoformat()).hexdigest())
