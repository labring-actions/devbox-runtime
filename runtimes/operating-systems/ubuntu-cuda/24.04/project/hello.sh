#!/bin/bash

body="Hello, World!"

while :; do
    {
        printf 'HTTP/1.1 200 OK\r\n'
        printf 'Content-Length: %d\r\n' "${#body}"
        printf '\r\n'
        printf '%s' "$body"
    } | nc -l -p 8080 -q 1
done
