import time
import sys
sys.path.append('/home/paulproteus/dnlds/selenium-rc/selenium-remote-control-1.0-beta-1/selenium-python-client-driver-1.0-beta-1') # Lame hack, oh well
import selenium

PAGE_LOAD_TIME_MILLISECONDS = 40 * 1000

def make_uspto_browser():
    browser = selenium.selenium('localhost', 4444,
                 '*firefox', 'http://portal.uspto.gov')
    browser.start()
    return browser

def open_uspto_pair(b):
    b.open('http://portal.uspto.gov/external/portal/pair')

def main(b = None):
    if b is None:
        b = make_uspto_browser()
        open_uspto_pair(b)
        print "Please solve the CAPTCHA and submit!"
    # Do useful stuff
    return b

def from_pair_front_page_select_our_case(b, case_number):
    b.click('//input[@title="control number"]')
    # b.click('control_number_radiobutton')
    b.type('number_id', case_number)
    b.click('SubmitPAIR')
    b.wait_for_page_to_load(PAGE_LOAD_TIME_MILLISECONDS)
    try:
        b.click('imag3')
    except:
        time.sleep(10) # Give USPTO some time to rest.
        b.go_back()
        raise RuntimeError("I had to abort in the middle.  Please retry.")
    b.wait_for_page_to_load(PAGE_LOAD_TIME_MILLISECONDS)
    try:
        b.click('//input[@value="RXNIRC"][1]') # No NIRC?
    except:
        time.sleep(2) # Give USPTO some time to rest.
        b.go_back()
        b.wait_for_page_to_load(PAGE_LOAD_TIME_MILLISECONDS) # This click causes a page load
        b.go_back()
        b.wait_for_page_to_load(PAGE_LOAD_TIME_MILLISECONDS) # This click causes a page load
        raise RuntimeError("No NIRC?")
    b.click('startDownload')
    #b.wait_for_page_to_load(30 * 1000) # Download PDF
    time.sleep(6) # Long enough I suppose
    print 'Hopefully, I just got the NIRC for', case_number
    b.click('imag40') # restore state
    time.sleep(0.2)
    b.wait_for_page_to_load(PAGE_LOAD_TIME_MILLISECONDS)
