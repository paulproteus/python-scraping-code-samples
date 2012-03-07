import BeautifulSoup
import requests
import re

def get_last_trade(ticker):
    url = 'http://finance.yahoo.com/q?s=' + ticker
    r = requests.get(url, headers={'User-Agent': 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; Win64; x64; SV1)'})
    soup = BeautifulSoup.BeautifulSoup(r.content)

    # The old way to do it
    nice_table = soup(id='table1')[0]
    first_row = nice_table('tr')[0]
    first_col = first_row('td')[0]
    result = first_col.find(text=True)

    # a little smoother
    also = soup.find(id='table1').find('tr').find('td').find(text=True)
    assert also == result

    # Same smoothness, simpler API calls
    also = soup.find(id='table1').tr.td.find(text=True)
    assert also == result

    return result

print get_last_trade('AAPL')
