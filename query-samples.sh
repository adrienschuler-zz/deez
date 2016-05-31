curl -s -XGET "http://localhost:9200/artists/_analyze?analyzer=tracks_name_analyzer&pretty" -d 'Memory Lane (Sittin in da Park)'

curl -s -XGET "http://localhost:9200/artists/_search" -d'
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "tracks.name": "snoop"
          }
        }
      ]
    }
  }
}'
