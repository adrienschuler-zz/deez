curl -s -XGET "http://localhost:9200/tracks/_analyze?analyzer=track_name_analyzer&pretty" -d 'Memory Lane (Sittin in da Park)'

curl -s -XGET "http://localhost:9200/tracks/_search" -d'
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "name": "snoop"
          }
        }
      ]
    }
  }
}'
