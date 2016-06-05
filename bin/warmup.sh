#!/bin/bash

sort -rnk3 -t'|' datas/tracks.* | head -n 100 | cut -f2 -d'|' | sort | uniq | python bin/warmup.py
