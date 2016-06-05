# Search Engine position - preliminary test

## Requirements

#### jq
[jq](https://stedolan.github.io/jq/) (must be >= 1.5)

```shell
brew install jq
```

#### python3
```shell
virtualenv -p python3 env
source env/bin/activate
```

#### python packages
```shell
pip install --upgrade pip
pip install elasticsearch==2.3.0
```

#### Fetch some Deezer tracks
```shell
./bin/tracks_crawler.sh
```

#### Generate random users along with artists profile vectors
```shell
cut -f5 -d'|' datas/tracks.* | sort -n | uniq | ./bin/generate_users.py
```

#### Setup local Elasticsearch indices
```shell
./bin/create_index.sh
```

#### Index tracks from our local dataset
```shell
cat ./datas/tracks.* | python bin/tracks_indexer.py
```

#### Warmup index
```shell
sort -rnk3 -t'|' datas/tracks.* | head -n 1000 | cut -f2 -d'|' | sort | uniq | python bin/warmup.py
```
