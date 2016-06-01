#!/bin/bash

HOST='localhost:9200'
DATE=`date +%Y%m%d%H%M%S`

INDEX='tracks'
TYPE='track'

# curl -s -XDELETE "$HOST/$INDEX"
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
                "track_name_analyzer": {
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
                "name": {
                    "type": "string",
                    "analyzer": "track_name_analyzer"
                },
                "score": {
                    "type": "integer"
                },
                "artist": {
                    "properties": {
                        "id": {
                            "type": "integer"
                        },
                        "name": {
                            "type": "string"
                        }
                    }
                }
            }
        }
    }
}'
