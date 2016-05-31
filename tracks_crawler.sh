#!/bin/bash
#
# Generate a sample csv file containing top music tracks from Deezer artists API.
#
# Output format: SngId|TrackName|TrackScore|ArtName|ArtId
#
# Usage: ./tracks_crawler.sh <OFFSET> <ARTISTS_LIMIT> <TRACKS_LIMIT>
#
# TODO:
# - Handle several artists per track
#

# Optional params
OFFSET=$1
ARTISTS_LIMIT=$2
TRACKS_LIMIT=$3

# Defaults
DATE=`date +%Y%m%d%H%M%S`
ENDPOINT="https://api.deezer.com"
OUTPUT_FILE="tracks.$DATE.csv"
: ${OFFSET:=1}
: ${ARTISTS_LIMIT:=100}
: ${TRACKS_LIMIT:=50}

function get_top_tracks {
    curl -s -XGET "$ENDPOINT/artist/$1/top?limit=$TRACKS_LIMIT"
}

function json_to_csv {
    echo $* |
    jq '.data[] | [ .id, .title_short, .rank, .artist.name, .artist.id ]' |
    jq @csv |
    sed 's/"//g' |
    sed 's/\\//g' |
    sed 's/,/|/g'
}

for ARTIST_ID in $(seq $OFFSET $ARTISTS_LIMIT); do
    json_to_csv `get_top_tracks $ARTIST_ID` 2>&1 | tee -a $OUTPUT_FILE
done
