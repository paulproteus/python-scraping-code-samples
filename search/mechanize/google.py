# imports
import mechanize

# Create a Browser
b = mechanize.Browser()

# Disable loading robots.txt
b.set_handle_robots(False)

b.addheaders = [('User-agent',
                 'Mozilla/4.0 (compatible; MSIE 5.0; Windows 98;)')]

# Navigate
b.open('http://www.google.com/')

# Choose a form
b.select_form(nr=0)

# Fill it out
b['q'] = 'pycon'

# Stubmit
fd = b.submit()

# ... process the results

print fd.read()
