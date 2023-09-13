require "uri"

class RickAndMortyAPI
    @@client = HTTP::Client.new(uri: URI.parse("https://rickandmortyapi.com"))
    @@headers = HTTP::Headers{"Content-Type" => "application/json"}

    def self.serialize(travels, expand, optimize)
        if travels.is_a?(Travel)
            travels = [travels]
        else
            travels.to_a
        end

        expanded_travels = Array(Travel).new

        travels.each do |travel|
            query = {"query" => "{locationsByIds(ids: #{travel.travel_stops.to_json}) {id name type dimension}}"}.to_json
            
            if optimize == "true"
                query = {"query" => "{locationsByIds(ids: #{travel.travel_stops.to_json}) {id name type dimension residents { episode { episode } }}}"}.to_json
            end
            response = expand(travel, query)

            if response.success?
                data = JSON.parse(response.body)
                travel.travel_stops = data["data"]["locationsByIds"]
                expanded_travels.insert(-1, travel)                
            else
                message = {"error" => response.status_message}.to_json
                error = {"status_code" => response.status_code, "message" => message}
                puts error
                break
            end
        end

        optimize == "true" ? optimize(expanded_travels, expand) : expanded_travels[0]
    end

    private def self.expand(travel : Travel, query)
        response = @@client.post("/graphql", headers: @@headers, body: query)
        @@client.close

        response
    end

    private def self.optimize(travels, expand) #TODO
        dimension_popularity = Hash(String, Int32).new
        local_popularity = Hash(Int32, Int32).new
        optmized_travels = Array(Travel).new
        index = 0

        travels.each do |travel|
            travel_stops = Array(Hash(String, JSON::Any)).from_json(travel.travel_stops.to_json)

            travel_stops.each do |travel_stop|
                if dimension_popularity.has_key?(travel_stop["dimension"].to_s)
                  dimension_popularity[travel_stop["dimension"].to_s] += 1
                else
                  dimension_popularity[travel_stop["dimension"].to_s] = 1
                end
              
                residents = Array(Hash(String, Array(JSON::Any))).from_json(travel_stop["residents"].to_json)
                if residents.empty?
                  local_popularity[travel_stop["id"].to_s.to_i] = 0
                else
                  residents.each do |resident|
                    if local_popularity.has_key?(travel_stop["id"].to_s.to_i)
                      local_popularity[travel_stop["id"].to_s.to_i] += resident["episode"].size
                    else
                      local_popularity[travel_stop["id"].to_s.to_i] = resident["episode"].size
                    end
                  end
                end
            end

            while index < travel_stops.size
                travel_stops[index]["local_popularity"] = JSON.parse(local_popularity[travel_stops[index]["id"].to_s.to_i].to_s)
                travel_stops[index]["dimension_popularity"] = JSON.parse(dimension_popularity[travel_stops[index]["dimension"]].to_s)
                index += 1
            end
    
            sorted_by_local_popularity = travel_stops.sort_by { |hash| hash["local_popularity"].to_s.to_i }
            sorted_by_dimension_popularity = sorted_by_local_popularity.sort_by { |hash| hash["dimension_popularity"].to_s.to_i }

            if expand == "true"
                travel.travel_stops = sorted_by_dimension_popularity.to_json
                optmized_travels.insert(-1, travel)
            else
                ids = Array(Int32).new
                sorted_by_dimension_popularity.each do |travel_stop|
                    ids << travel_stop["id"].to_s.to_i
                end
                travel.travel_stops = ids.to_json
                optmized_travels.insert(-1, travel)
            end

        end

        optmized_travels[0]
    end
end