## This module monkey patches the socket module
## (on which just about everything relies) for use
## with Tor.

TOR_IP='127.0.0.1'
TOR_PORT=9050

import socks
import socket

def is_tor_enabled():
        if not hasattr(socks, 'torified'):
                return 0
        return socket.torified

def enable_tor():
        socket.torified = 1
        socks.setdefaultproxy(socks.PROXY_TYPE_SOCKS5, TOR_IP, TOR_PORT)
        socket._real_socket = socket.socket
        socket.socket = socks.socksocket
        assert is_tor_enabled()

def disable_tor():
        socket.torified = 0
        if hasattr(socket, '_real_socket'):
                socket.socket = socket._real_socket
        assert not is_tor_enabled()



# Set default proxy to Tor
socks.setdefaultproxy(socks.PROXY_TYPE_SOCKS5, 'localhost', 9050)

