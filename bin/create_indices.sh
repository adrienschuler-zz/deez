#!/bin/bash

HOST='localhost:9200'
INDEX='tracks'
TYPE='track'

curl -s -XDELETE "$HOST/$INDEX"

curl -s -XPUT "$HOST/$INDEX" -d '
{
    "settings": {
        "index": {
            "dynamic": "strict",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "refresh_interval": -1
        },
        "analysis": {
            "analyzer": {
                "track_name": {
                    "type": "custom",
                    "tokenizer": "standard",
                    "filter": [
                        "trim",
                        "lowercase"
                    ]
                },
                "autocomplete": {
                    "type": "custom",
                    "tokenizer": "standard",
                    "filter": [
                        "trim",
                        "lowercase",
                        "autocomplete_filter"
                    ]
                }
            },
            "filter": {
                "autocomplete_filter": {
                    "type": "edge_ngram",
                    "min_gram": 2,
                    "max_gram": 10
                }
            }
        }
    },
    "mappings": {
        '"$TYPE"': {
            "properties": {
                "name": {
                    "type": "string",
                    "analyzer": "track_name"
                },
                "name_autocomplete":{
                    "type": "string",
                    "analyzer": "autocomplete"
                },
                "popularity": {
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
