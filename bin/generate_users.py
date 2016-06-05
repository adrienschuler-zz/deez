#!/usr/bin/env python
#
# Generate random users along with some artist profile vectors based on input tracks.
#
# Output format: UserId|ArtId:APV|ArtId:APV|ArtId:APV|[...]
#
# Usage: cut -f5 -d'|' datas/tracks.* | sort -n | uniq | ./bin/generate_users.py
#

import random
import fileinput

artists = []
for line in fileinput.input():
    artists.append(line.strip(' \t\n\r'))

for id in range(1, 100):
    apvs = ''
    for artist in artists:
        if random.choice([True, False]):
            apvs += "|%s:%.2f" % (artist, random.random())
    print('%s%s' % (id, apvs))
