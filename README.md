brew install jq
(must be >= 1.5)

virtualenv -p python3 env && source env/bin/activate
pip install --upgrade pip

pip install elasticsearch==2.3.0

./bin/tracks_crawler.sh 1 1000 50
./bin/create_indices.sh
sort -t$'\|' -k5 -n ./datas/tracks.* | python bin/artists_indexer.py
