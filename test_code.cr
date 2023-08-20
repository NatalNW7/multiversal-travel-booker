require "json"

travels_expanded = %([{
    "id": 1,
    "travel_stops":[
        {
          "id": 2,
          "name": "Abadango",
          "dimension": "unknown",
          "residents": [
            { "episode": [1]}
          ]
        },
        {
          "id": 7,
          "name": "Immortality Field Resort",
          "dimension": "unknown",
          "residents": [
            { "episode": [1,2,3,4,5] },
            { "episode": [1] },
            { "episode": [1] }
          ]
        },
        {
          "id": 9,
          "name": "Purge Planet",
          "dimension": "Replacement Dimension",
          "residents": [
            { "episode": [1] },
            { "episode": [1] },
            { "episode": [1] },
            { "episode": [1] }
          ]
        },
        {
          "id": 11,
          "name": "Bepis 9",
          "dimension": "unknown",
          "residents": [
            { "episode": [1,2,3,4] }
          ]
        },
        {
          "id": 19,
          "name": "Gromflom Prime",
          "dimension": "Replacement Dimension",
          "residents": []
        }
    ]
}])

travels = %([{
    "id": 1,
    "travel_stops": [2,7,9,11,19]
}])


travels = Array(JSON::Any).from_json(travels)
travels_expanded = Array(JSON::Any).from_json(travels_expanded)

ids = Array(Int32).from_json(travels[0]["travel_stops"].to_s)
travel_stops = Array(JSON::Any).from_json(travels_expanded[0]["travel_stops"].to_json)

dimension_popularity = Hash(String, Int32).new
locals_popularity = Hash(Int32, Int32).new

ids.each do |id|
  travel_stops.each do |travel_stop|
    if travel_stop["id"] == id
      residents = Array(JSON::Any).from_json(travel_stop["residents"].to_json)
      # puts travel_stop["id"]
      # puts travel_stop["dimension"]
      if dimension_popularity.has_key?(travel_stop["dimension"].to_s)
        dimension_popularity[travel_stop["dimension"].to_s] += 1
      else
        dimension_popularity[travel_stop["dimension"].to_s] = 1
      end

      if residents.size > 0
        residents.each do |episodeos|
          episode = Hash(String, Int32).from_json(episodeos.to_json)
          episode.each do |ep|
            
          end
        end
      else
        locals_popularity[id] = travel_stop["residents"].size
      end
    end
  end
end

puts dimension_popularity

