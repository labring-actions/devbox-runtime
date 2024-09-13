#!/bin/bash

while :; do
    { echo -ne "HTTP/1.1 200 OK\r\nContent-Length: $(echo -n "Hello, World!")\r\n\r\nHello, World!"; } | nc -l -p 8080 -q 1
done
