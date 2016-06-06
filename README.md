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

## Bench
```shell
sort -rnk3 -t'|' datas/tracks.* | head -n 1000 | cut -f2 -d'|' | sort | uniq | python bin/bench.py

query=get right user=28 apv={'2': 0.23, '83': 0.15, '72': 0.96, '93': 0.77, '34': 0.81, '1': 0.04}

0 _id=596589 _score=8 name=Get Right popularity=781440 artist.name=Jennifer Lopez artist.id=45
1 _id=69779542 _score=3 name=Right Here, Right Now popularity=701911 artist.name=Fatboy Slim artist.id=76
2 _id=69743459 _score=3 name=Right Here, Right Now popularity=622792 artist.name=Fatboy Slim artist.id=76
3 _id=1161014 _score=3 name=Right Now popularity=312174 artist.name=The Pussycat Dolls artist.id=83
4 _id=69924605 _score=2 name=The Right Profile popularity=397028 artist.name=The Clash artist.id=2
5 _id=67238739 _score=2 name=Doin' it Right popularity=682393 artist.name=Daft Punk artist.id=27
6 _id=1174603 _score=2 name=Sho' You Right popularity=417328 artist.name=Barry White artist.id=34
7 _id=2203428 _score=2 name=Right Now (Na Na Na) popularity=739132 artist.name=Akon artist.id=38
8 _id=116348622 _score=1 name=Eleanor Rigby popularity=596183 artist.name=The Beatles artist.id=1
9 _id=3614513 _score=1 name=Right Now (feat. Black Thought Of The Roots & Styles Of Beyond) popularity=428692 artist.name=Fort Minor artist.id=72
10 _id=121125382 _score=1 name=Getting Warmer popularity=399237 artist.name=Gwen Stefani artist.id=16
11 _id=66609426 _score=1 name=Get Lucky popularity=952131 artist.name=Daft Punk artist.id=27
12 _id=67238735 _score=1 name=Get Lucky popularity=900626 artist.name=Daft Punk artist.id=27
13 _id=70896488 _score=1 name=Get Down popularity=588296 artist.name=Nas artist.id=73
14 _id=2309090 _score=1 name=Get Back popularity=495441 artist.name=Ludacris artist.id=78
15 _id=662103 _score=1 name=Get Busy popularity=825193 artist.name=Sean Paul artist.id=88
16 _id=1143492 _score=1 name=N 2 Gether Now popularity=553907 artist.name=Limp Bizkit artist.id=93
17 _id=749087 _score=1 name=Geto Highlites popularity=282463 artist.name=Coolio artist.id=99
18 _id=7677778 _score=0 name=(I Can't Get No) Satisfaction popularity=755599 artist.name=The Rolling Stones artist.id=11
19 _id=2677041 _score=0 name=(I Can't Get No) Satisfaction popularity=682507 artist.name=The Rolling Stones artist.id=11

0 _id=596589 _score=1061 name=Get Right popularity=781440 artist.name=Jennifer Lopez artist.id=45
1 _id=1174603 _score=196 name=Sho' You Right popularity=417328 artist.name=Barry White artist.id=34
2 _id=69779542 _score=181 name=Right Here, Right Now popularity=701911 artist.name=Fatboy Slim artist.id=76
3 _id=69743459 _score=180 name=Right Here, Right Now popularity=622792 artist.name=Fatboy Slim artist.id=76
4 _id=1161014 _score=155 name=Right Now popularity=312174 artist.name=The Pussycat Dolls artist.id=83
5 _id=69924605 _score=109 name=The Right Profile popularity=397028 artist.name=The Clash artist.id=2
6 _id=67238739 _score=90 name=Doin' it Right popularity=682393 artist.name=Daft Punk artist.id=27
7 _id=2203428 _score=69 name=Right Now (Na Na Na) popularity=739132 artist.name=Akon artist.id=38
8 _id=3614513 _score=57 name=Right Now (feat. Black Thought Of The Roots & Styles Of Beyond) popularity=428692 artist.name=Fort Minor artist.id=72
9 _id=1143492 _score=39 name=N 2 Gether Now popularity=553907 artist.name=Limp Bizkit artist.id=93
10 _id=116348622 _score=29 name=Eleanor Rigby popularity=596183 artist.name=The Beatles artist.id=1
11 _id=3614521 _score=29 name=Get Me Gone popularity=314310 artist.name=Fort Minor artist.id=72
12 _id=884758 _score=27 name=Not Gonna Get Us popularity=535268 artist.name=t.A.T.u. artist.id=37
13 _id=66609426 _score=18 name=Get Lucky popularity=952131 artist.name=Daft Punk artist.id=27
14 _id=67238735 _score=18 name=Get Lucky popularity=900626 artist.name=Daft Punk artist.id=27
15 _id=662103 _score=18 name=Get Busy popularity=825193 artist.name=Sean Paul artist.id=88
16 _id=70896488 _score=18 name=Get Down popularity=588296 artist.name=Nas artist.id=73
17 _id=2309090 _score=18 name=Get Back popularity=495441 artist.name=Ludacris artist.id=78
18 _id=121125382 _score=17 name=Getting Warmer popularity=399237 artist.name=Gwen Stefani artist.id=16
19 _id=749087 _score=17 name=Geto Highlites popularity=282463 artist.name=Coolio artist.id=99
```
