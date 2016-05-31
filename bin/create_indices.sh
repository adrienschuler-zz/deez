#!/bin/bash

HOST='localhost:9200'
DATE=`date +%Y%m%d%H%M%S`

INDEX='artists'
TYPE='artist'

curl -s -XDELETE "$HOST/$INDEX"

# curl -s -XPUT "$HOST/$INDEX.$DATE" -d '
curl -s -XPUT "$HOST/$INDEX" -d '
{
    "settings": {
        "index": {
            "dynamic": "strict",
            "number_of_shards": 1,
            "number_of_replicas": 0
        },
        "analysis": {
            "analyzer": {
                "tracks_name_analyzer": {
                    "type": "custom",
                    "tokenizer": "standard",
                    "filter": [
                        "trim",
                        "lowercase"
                    ]
                }
            }
        }
    },
    "mappings": {
        '"$TYPE"': {
            "properties": {
                "artist_name": {
                    "type": "string"
                },
                "tracks": {
                    "type": "object",
                    "properties": {
                        "id": {
                            "type": "integer"
                        },
                        "name": {
                            "type": "string",
                            "analyzer": "tracks_name_analyzer"
                        },
                        "popularity_score": {
                            "type": "integer"
                        }
                    }
                }
            }
        }
    }
}'
