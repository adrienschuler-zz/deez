#!/usr/bin/env python
#
# Index crawled tracks from Deezer artist API to Elasticsearch.
#
# Expected input format: SngId|TrackName|TrackScore|ArtName|ArtId
#
# Usage: cat ./datas/tracks.* | python bin/tracks_indexer.py
#

import fileinput

from elasticsearch import Elasticsearch
from elasticsearch.helpers import streaming_bulk

def index():
    for line in fileinput.input():
        line = line.strip(' \t\n\r')
        track_id, track_name, track_score, artist_name, artist_id = line.split('|')

        yield {
            "_index": "tracks",
            "_type": "track",
            "_op_type": "index",
            "_id": track_id,
            "_source": {
                "name": track_name,
                "name_autocomplete": track_name,
                "popularity": int(track_score),
                "artist": {
                    "id": int(artist_id),
                    "name": artist_name
                }
            }
        }

es = Elasticsearch()
for ok, result in streaming_bulk(es, index(), chunk_size=50):
    print(result)

es.indices.refresh(index="tracks")
