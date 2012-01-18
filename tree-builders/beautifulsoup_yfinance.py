import BeautifulSoup
import urllib2
import re

def get_last_trade(ticker):
    url = 'http://finance.yahoo.com/q?s=' + ticker
    fd = urllib2.urlopen(url)
    soup = BeautifulSoup.BeautifulSoup(fd)

    # The old way to do it
    nice_table = soup(id='table1')[0]
    first_row = nice_table('tr')[0]
    #print first_row
    first_col = first_row('td')[0]
    result = first_col.find(text=True)

    # a little smoother
    also = soup.find(id='table1').find('tr').find('td').find(text=True)
    assert also == result

    # Same smoothness, simpler API calls
    also = soup.find(id='table1').tr.td.find(text=True)
    assert also == result

    # What if the labels move around on the page?
    last_trade_text = soup.find(text='Last Trade:')
    my_tr = last_trade_text.parent
    also = my_tr.findNextSibling('td').find(text=True)
    assert also == result

    # but the IDs seem to encode some information...
    my_span = soup.find('span', id='yfs_l10_' + ticker.lower())
    also = my_span.find(text=True)
    assert also == result

    return result

print get_last_trade('AAPL')
