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

def loop_input():
    for line in fileinput.input():
        line = line.strip(' \t\n\r')
        track_id, track_name, track_score, artist_name, artist_id = line.split('|')

        yield {
            "_index": "tracks",
            "_type": "track",
            "_op_type": "index",
            "_id": int(track_id),
            "_source": {
                "name": track_name,
                "score": int(track_score),
                "artist": {
                    "id": int(artist_id),
                    "name": artist_name
                }
            }
        }

es = Elasticsearch()
for ok, result in streaming_bulk(es, loop_input(), chunk_size=50):
    print(result)
