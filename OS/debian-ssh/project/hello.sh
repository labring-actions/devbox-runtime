#!/bin/bash

MODE="${1:-${ENV:-development}}"

echo "Hello, Sealos user. welcome to Debian!"
echo "You’re now in ${MODE} mode. Have a smooth journey and happy coding."

while :; do
    BODY="Hello, World! (mode: ${MODE})"
    LEN=${#BODY}
    { echo -ne "HTTP/1.1 200 OK\r\nContent-Length: ${LEN}\r\nContent-Type: text/plain; charset=utf-8\r\n\r\n${BODY}"; } | nc -l -p 8080 -q 1
done
