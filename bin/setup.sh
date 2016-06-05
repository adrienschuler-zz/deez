#!/bin/bash

./bin/create_index.sh && cat datas/tracks.* | python bin/tracks_indexer.py && ./bin/warmup.sh
