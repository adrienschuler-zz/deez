#!/bin/bash
#
# Generate a sample csv file containing top music tracks from Deezer artists API.
#
# Output format: SngId|TrackName|TrackScore|ArtId|ArtName
#
# Usage: ./tracks_crawler.sh <ARTISTS_LIMIT> <TRACKS_LIMIT>
#
# TODO:
# - Handle several artists per track
#

ENDPOINT="https://api.deezer.com"
OUTPUT_FILE="tracks.sample.csv"
ARTISTS_LIMIT=$1
TRACKS_LIMIT=$2

# Default thresholds
: ${ARTISTS_LIMIT:=100}
: ${TRACKS_LIMIT:=10}

truncate -s0 $OUTPUT_FILE

function get_top_tracks {
    ARTIST_ID=$1
    curl -s -XGET "$ENDPOINT/artist/$ARTIST_ID/top?limit=$TRACKS_LIMIT"
}

function json_to_csv {
    echo $* |
    jq '.data[] | [ .id, .title_short, .rank, .artist.id, .artist.name ]' |
    jq @csv |
    sed 's/"//g' |
    sed 's/\\//g' |
    sed 's/,/|/g'
}

for ARTIST_ID in $(seq 1 $ARTISTS_LIMIT); do
    json_to_csv `get_top_tracks $ARTIST_ID` 2>&1 | tee -a $OUTPUT_FILE
done
