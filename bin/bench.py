#!/usr/bin/env python
#
# Run popular queries and compare artists ranking depending on user artist profile vectors.
#
# Usage: sort -rnk3 -t'|' datas/tracks.* | head -n 1000 | cut -f2 -d'|' | sort | uniq | python bin/bench.py
#

import re
import json
import fileinput

from elasticsearch import Elasticsearch


def display_response(response):
    pos = 0
    for doc in response['hits']['hits']:
        print(
            '%d _id=%s _score=%d name=%s popularity=%d artist.name=%s artist.id=%d' %
            (pos, doc['_id'], doc['_score'], doc['fields']['name'][0], doc['fields']['popularity'][0], doc['fields']['artist.name'][0], doc['fields']['artist.id'][0])
        )
        pos += 1

user_apvs = {}
queries = set()
es = Elasticsearch()

# extract first two words of each tracks
for keywords in fileinput.input():
    keywords = keywords.strip(' \t\n\r')
    keywords = re.sub('[^A-Za-z0-9\' ]+', '', keywords).lower()
    keywords = keywords.split(' ')[:2]
    queries.add(' '.join(keywords))

queries = sorted(queries)

# gather all user apv
with open('datas/users.csv') as f:
    for line in f:
        user_apv = line.strip(' \t\n\r').split('|')
        user_apvs[int(user_apv[0])] = list(map(lambda x: { x.split(':')[0]: float(x.split(':')[1]) }, user_apv[1:]))

# for earch query, run it through each users
# one with user apv, and one without in order to compare artists ranking
for query in queries:
    raw_query = {
        "size": 20,
        "fields": [
            "name",
            "popularity",
            "artist.id",
            "artist.name"
        ],
        "query": {
            "match": {
              "name_autocomplete": query
            }
        }
    }

    raw_response = es.search(index="tracks", body=raw_query)

    for user in user_apvs:
        flag = False
        input = {}
        artists = {}
        for user_apv in user_apvs[user]:
            input.update(user_apv)

        # if the query answer contain at least one artist which is on the user apv, run it and display both raw and apv query in order to compare rankings
        for response in raw_response['hits']['hits']:
            artist = str(response['fields']['artist.id'][0])

            if artist in input:
                artists.update({ artist: input[artist] })

            if not flag:
                apv_query = {
                    "size": 20,
                    "fields": [
                        "name",
                        "popularity",
                        "artist.id",
                        "artist.name"
                    ],
                    "query": {
                        "function_score": {
                            "query": {
                                "match": {
                                    "name_autocomplete": query
                                }
                            },
                            "functions": [{
                                "script_score": {
                                    "script": "apv = input.get(doc[\"artist.id\"].value.toString()); return apv == null ? _score : _score * exp(apv)",
                                    "params": {
                                        "input": input
                                    }
                                }
                            }, {
                                "script_score": {
                                    "script": "return _score * log(doc[\"popularity\"].value + 1)"
                                }
                            }],
                            "boost_mode": "replace"
                        }
                    }
                }
                flag = True

        if flag:
            apv_response = es.search(index="tracks", body=apv_query)
            print('\nquery=%s user=%d apv=%s\n' % (query, user, artists))
            display_response(raw_response)
            print('')
            display_response(apv_response)
