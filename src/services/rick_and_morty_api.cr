require "uri"

class RickAndMortyAPI
    @@client = HTTP::Client.new(uri: URI.parse("https://rickandmortyapi.com"))
    @@headers = HTTP::Headers{"Content-Type" => "application/json"}

    def self.serialize(travels)
        if travels.is_a?(Travel)
            travels = [travels]
        else
            travels.to_a
        end

        serialized_travels = Array(Travel).new

        travels.each do |travel|
            response = expand(travel)

            if response.success?
                data = JSON.parse(response.body)
                travel.travel_stops = data["data"]["locationsByIds"]
                serialized_travels.insert(-1, travel)                
            else
                message = {"error" => response.status_message}.to_json
                error = {"status_code" => response.status_code, "message" => message}
                puts error
                break
            end
        end

        serialized_travels
    end

    private def self.expand(travel : Travel)
        query = {"query" => "{locationsByIds(ids: #{travel.travel_stops.to_json}) {id name type dimension}}"}.to_json
        response = @@client.post("/graphql", headers: @@headers, body: query)
        @@client.close

        response
    end

    private def self.optimize #TODO 
    end
end