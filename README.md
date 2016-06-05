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

## Tokens

```shell
curl -s -XGET "http://localhost:9200/tracks/_analyze?analyzer=autocomplete&pretty" -d 'Le Sud Le Fait Mieux - 2007 (feat. Billy Bats & Soprano) [DJ Djel remix]' | grep token
  "tokens" : [ {
    "token" : "le",
    "token" : "su",
    "token" : "sud",
    "token" : "le",
    "token" : "fa",
    "token" : "fai",
    "token" : "fait",
    "token" : "mi",
    "token" : "mie",
    "token" : "mieu",
    "token" : "mieux",
    "token" : "20",
    "token" : "200",
    "token" : "2007",
    "token" : "fe",
    "token" : "fea",
    "token" : "feat",
    "token" : "bi",
    "token" : "bil",
    "token" : "bill",
    "token" : "billy",
    "token" : "ba",
    "token" : "bat",
    "token" : "bats",
    "token" : "so",
    "token" : "sop",
    "token" : "sopr",
    "token" : "sopra",
    "token" : "sopran",
    "token" : "soprano",
    "token" : "dj",
    "token" : "dj",
    "token" : "dje",
    "token" : "djel",
    "token" : "re",
    "token" : "rem",
    "token" : "remi",
    "token" : "remix",
```

## Searching

```shell
curl -XPOST "http://localhost:9200/tracks/_search?pretty" -d'
{
  "size": 5,
  "fields": [
    "name",
    "popularity",
    "artist.id",
    "artist.name"
  ],
  "query": {
    "function_score": {
      "query": {
        "match": {
          "name_autocomplete": "lucky"
        }
      },
      "functions": [
        {
          # First, we boost tracks depending on the user artist profile vectors
          "script_score": {
            "script": "apv = input.get(doc[\"artist.id\"].value.toString()); return apv == null ? _score : _score * exp(apv)",
            "params": {
              "input": {
                "27": 0.1,
                "59": 0.7
              }
            }
          }
        },
        {
          # Then we boost tracks based on their popularity score
          "script_score": {
            "script": "return _score * log(doc[\"popularity\"].value + 1)"
          }
        }
      ],
      "boost_mode": "replace"
    }
  }
}'
```

```json
{
  "took": 2,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "failed": 0
  },
  "hits": {
    "total": 24,
    "max_score": 1141.2983,
    "hits": [
      {
        "_index": "tracks",
        "_type": "track",
        "_id": "18205206",
        "_score": 1141.2983,
        "fields": {
          "name": [
            "Lucky (In My Life)"
          ],
          "artist.name": [
            "Eiffel 65"
          ],
          "popularity": [
            290285
          ],
          "artist.id": [
            59
          ]
        }
      },
      {
        "_index": "tracks",
        "_type": "track",
        "_id": "66609426",
        "_score": 1071.1042,
        "fields": {
          "name": [
            "Get Lucky"
          ],
          "artist.name": [
            "Daft Punk"
          ],
          "popularity": [
            952131
          ],
          "artist.id": [
            27
          ]
        }
      },
      {
        "_index": "tracks",
        "_type": "track",
        "_id": "67238735",
        "_score": 1066.7772,
        "fields": {
          "name": [
            "Get Lucky"
          ],
          "artist.name": [
            "Daft Punk"
          ],
          "popularity": [
            900626
          ],
          "artist.id": [
            27
          ]
        }
      },
      {
        "_index": "tracks",
        "_type": "track",
        "_id": "115028110",
        "_score": 407.04376,
        "fields": {
          "name": [
            "Lucie"
          ],
          "artist.name": [
            "Daniel Balavoine"
          ],
          "popularity": [
            538072
          ],
          "artist.id": [
            26
          ]
        }
      },
      {
        "_index": "tracks",
        "_type": "track",
        "_id": "124389290",
        "_score": 152.48505,
        "fields": {
          "name": [
            "Lucifer's Angel"
          ],
          "artist.name": [
            "The Rasmus"
          ],
          "popularity": [
            313307
          ],
          "artist.id": [
            84
          ]
        }
      }
    ]
  }
}
```
