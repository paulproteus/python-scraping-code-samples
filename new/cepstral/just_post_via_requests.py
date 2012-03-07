import requests

URL='http://cepstral.com/cgi-bin/demos/weather'

def main():
    # Here is the data that FireBug said we sent
    postdict = {'city' : 'San Francisco',
                'demotype' : 'actual',
                'state' : 'CA',
                'voice' : 'David',
                'submit':'Synthesize the weather'}

    # Send it...
    fd = requests.post(URL, data=postdict)
    return fd.text

if __name__ == '__main__':
    print main()
