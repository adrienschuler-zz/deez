#!/bin/bash

./bin/create_indices.sh && cat datas/tracks.* | python bin/tracks_indexer.py && ./bin/warmup.sh
