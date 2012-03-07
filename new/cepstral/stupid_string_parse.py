def parse(s):
    pieces = s.split('"')
    for piece in pieces:
        if 'wav' in piece:
            return piece

