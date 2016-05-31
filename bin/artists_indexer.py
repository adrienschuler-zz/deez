#!/usr/bin/env python
#
#
#

import json
import fileinput

from elasticsearch import Elasticsearch

es = Elasticsearch()

def index(key, doc):
    try:
        print(key, doc)
        response = es.index(index='artists', doc_type='artist', body=doc, id=key)
        print(response)
    except Exception as e:
        print(e)

last_id = None
tracks = []

for line in fileinput.input():
    line = line.strip(' \t\n\r')
    track_id, track_name, track_score, artist_name, artist_id = line.split('|')

    if last_id == None:
        last_id = artist_id

    if last_id != artist_id:
        doc = {
            "name": artist_name,
            "tracks": tracks
        }
        index(last_id, doc)
        tracks = []
        last_id = None

    tracks.append({
        "id": int(track_id),
        "name": track_name,
        "popularity_score": int(track_score)
    })
