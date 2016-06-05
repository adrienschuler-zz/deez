#!/usr/bin/env python
#
# Warmup Elasticsearch tracks index.
#
# Usage: cut -f2 -d'|' datas/tracks.* | python warmup.py
#
# Example (search for 1k top popular tracks):
# sort -rnk3 -t'|' datas/tracks.* | head -n 1000 | cut -f2 -d'|' | sort | uniq | python bin/warmup.py
#

import re
import fileinput

from elasticsearch import Elasticsearch

es = Elasticsearch()

for keywords in fileinput.input():
    keywords = keywords.strip(' \t\n\r')
    keywords = re.sub('[^A-Za-z0-9 ]+', '', keywords).lower()

    print(keywords)

    pos = 1
    for char in keywords:
        print(keywords[:pos])
        pos += 1

        query = {
          "query": {
            "match": {
              "name_autocomplete": keywords[:pos]
            }
          }
        }

        print(es.search(index="tracks", body=query))
