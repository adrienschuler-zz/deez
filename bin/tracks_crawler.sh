#!/bin/bash
#
# Generate a sample csv file containing top music tracks from Deezer artists API.
#
# Output format: SngId|TrackName|TrackScore|ArtName|ArtId
#
# Usage: ./tracks_crawler.sh <OFFSET> <ARTISTS_LIMIT> <TRACKS_LIMIT>
# Example: ./tracks_crawler.sh 1 100000 50
#
# TODO:
# - Handle several artists per track
#

ENDPOINT="https://api.deezer.com"
DATE=`date +%Y%m%d%H%M%S`
OUTPUT_FILE="tracks.$DATE.csv"

OFFSET=$1
ARTISTS_LIMIT=$2
TRACKS_LIMIT=$3

: ${OFFSET:=1}
: ${ARTISTS_LIMIT:=100}
: ${TRACKS_LIMIT:=50}

function get_top_tracks {
    curl -s -XGET "$ENDPOINT/artist/$1/top?limit=$TRACKS_LIMIT"
}

function json_to_csv {
    echo $* |
    jq '.data[] | [ .id, .title_short, .rank, .artist.name, .artist.id ]' |
    jq @tsv |
    sed 's/"//g' |
    sed 's/\\t/|/g'
}

for ARTIST_ID in $(seq $OFFSET $ARTISTS_LIMIT); do
    json_to_csv `get_top_tracks $ARTIST_ID` 2>&1 | tee -a $OUTPUT_FILE
done
