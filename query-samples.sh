curl -s -XGET "http://localhost:9200/tracks/_analyze?analyzer=track_name_analyzer&pretty" -d 'Le Sud Le Fait Mieux - 2007 (feat. Billy Bats & Soprano) [DJ Djel remix]'
curl -s -XGET "http://localhost:9200/tracks/_analyze?analyzer=autocomplete&pretty" -d 'Le Sud Le Fait Mieux - 2007 (feat. Billy Bats & Soprano) [DJ Djel remix]'

curl -XGET "http://localhost:9200/tracks/_validate/query?explain" -d'
{
    "query": {
        "match": {
            "name_autocomplete": "feat"
        }
    }
}'

curl -XPOST "http://localhost:9200/tracks/_search?pretty" -d'
{
  "query": {
    "match": {
      "name_autocomplete": "feat"
    }
  }
}'

curl -XPOST "http://localhost:9200/tracks/_search?pretty" -d'
{
  "query": {
    "function_score": {
      "query": {
        "match": {
          "name_autocomplete": "feat"
        }
      },
      "functions": [
        {
          "script_score": {
            "script": "apv = input.get(doc[\"artist.id\"].value.toString()); return apv == null ? _score : _score * (apv + 1)",
            "params": {
              "input": {
                "60": 0.98,
                "10": 0.23
              }
            }
          }
        },
        {
          "script_score": {
            "script": "return _score * log(doc[\"popularity\"].value + 1)"
          }
        }
      ],
      "boost_mode": "replace"
    }
  }
}
