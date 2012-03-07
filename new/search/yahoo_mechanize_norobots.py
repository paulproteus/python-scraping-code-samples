# imports
import mechanize

# Create a Browser
b = mechanize.Browser()

# Disable loading robots.txt
b.set_handle_robots(False)

# Navigate
b.open('http://www.yahoo.com/')

# Choose a form
b.select_form(nr=0)

# Fill it out
b['p'] = 'pycon'

# Stubmit
fd = b.submit()

# ... process the results

