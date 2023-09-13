class TravelController
  BASE = "/travel_plans"

  before_all BASE do |context|
    context.response.content_type = "application/json"
  end

  before_all BASE + "/:id" do |context|
    context.response.content_type = "application/json"
  end

  get "/" do |context|
    context.redirect BASE
  end

  get BASE do |context|
    optimize = context.params.query["optimize"]?
    expand = context.params.query["expand"]?
    travels = Travel.all
    travels = expand == "true" || optimize == "true" ? RickAndMortyAPI.serialize(travels, expand, optimize) : travels

    travels.to_json
  end

  get BASE + "/:id" do |context|
    optimize = context.params.query["optimize"]?
    expand = context.params.query["expand"]?
    id = context.params.url["id"].to_i
    travel = Travel.find(id)

    if travel
      travel = expand == "true" || optimize == "true" ? RickAndMortyAPI.serialize(travel, expand, optimize) : travel  
      
      halt context, 200, travel.to_json
    else
      message = {"error" => "Travel record not found"}.to_json
      halt context, 404, message
    end
  end

  post BASE do |context|
    travel_stops = context.params.json["travel_stops"].as(Array)
    travel = Travel.new({travel_stops: travel_stops.to_json})

    if travel.save
      halt context, 201, travel.to_json
    else
      message = {"error" => "Failed to create a new Travel"}.to_json
      halt context, 500, message
    end
  end

  put BASE + "/:id" do |context|
    id = context.params.url["id"].to_i
    travel_stops = context.params.json["travel_stops"].as(Array)
    travel = Travel.find(id)
    
    if travel
      travel.set_attributes({travel_stops: travel_stops.to_json})
      if travel.save
        halt context, 200, travel.to_json
      else
        message = {"error" => "Failed to update Travel record"}.to_json
        halt context, 500, message
      end
    else
      message = {"error" => "Travel record not found"}.to_json
      halt context, 404, message
    end
  end

  delete BASE + "/:id" do |context|
    id = context.params.url["id"].to_i
    Travel.destroy(id)
    travel = Travel.find(id)

    if travel
      travel.to_json
    else
      halt context, 204
    end
  end
end
