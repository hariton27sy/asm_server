import socket

s = socket.socket()
s.bind(('0.0.0.0', 8080))
s.listen(500)

while True:
    c, a = s.accept()
    print(f'Connect from {a}')
    c.send(b'Hello, world!\r\n')
    c.close()