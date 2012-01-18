import mechanize

# The URL to this service
URL = 'http://www.cepstral.com/cgi-bin/demos/weather'


def main():
    # Create a Browser instance
    b = mechanize.Browser()
    # Load the page
    b.open(URL)
    # Select the form
    b.select_form(nr=0)
    # Fill out the form
    b['city'] = 'San Francisco'
    b['state'] = 'CA'
    # Verify that the voice hidden field has a value in it
    assert b['voice']
    # Submit!
    return b.submit()
