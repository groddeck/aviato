# app/services/re_act.rb
class ReAct
  def initialize(conversation)
    @conversation = conversation
  end

  def ask
    # assess goal
    goal = assess(@conversation.messages.map{|message| {role: message.user, content: message.content} })
    puts goal
    # apply tools to solve
    response = completion([{role: "assistant", content: goal}], true)
    puts response

    ## Check for data showable in widgets
    # Flights
    widget_data = completion([
      {
      role: "user", 
      content: "For any flight options in the given content, transform it into a list of well-formed JSON objects like this: {flights: [{departure_iataCode, departure_dateTime, arrival_iataCode, arrival_dateTime, price, carrierCode}, ...]} - use an empty array if no flight data, ie: {flights: []}.  The content: #{response}"
      }
    ], false)
    flight_info = repair_json(widget_data)

    # Weather data
    widget_data = completion([
      {
      role: "user", 
      content: "Transform any weather report data for a location in the following content into structured JSON like this: {weather: {temperature_2m: number, wind_speed_10m: number, relative_humidity_2m: number, condition: description}} - if no weather data is present return {weather: null} - The content: #{response}"
      }
    ], false)
    weather_info = repair_json(widget_data)

    widget_hash = {}
    widget_hash["get_flight_info"] = flight_info if flight_info["flights"].present?
    widget_hash["get_weather"] = weather_info if weather_info["weather"].present?
    widget_string = widget_hash.to_json
    add_message("system", response, widget_string)
  end

  def repair_json(json)
    cleaned = client.chat(
      parameters: {
        model: "gpt-4-turbo",
        messages: [
          {role: "system", content: "you are JSON data cleaner. Given input JSON content, clean any stray verbiage and fix any JSON syntax errors, returning only well-formed JSON"},
          {role: "user", content: json}
        ],
        response_format: { "type": "json_object" }
      }
    )
    raw_text = cleaned.dig("choices", 0, "message", "content")
    flight_info = JSON.parse(raw_text)
  rescue => e
    puts e.message
    {}
  end

  def assess(messages)
    prompt = "Given the conversation history, summarize the goal including information known, or needed, and steps you will need to take to complete the goal."
    response = completion(messages + [{role: "user", content: prompt}], false)
  end

  def add_message(role, content, widget_data=nil)
    @conversation.messages.create(user: role, content: content, widget_data: widget_data)
  end

  def completion(messages, use_tools)
    parameters = {
      model: "gpt-4",
      messages: [
        {role: 'system', content: 'Complete the user-requested task or perform a tool call to get the information needed to complete the task'}
      ] + messages,
    }
    # If we need a plain response without accidentally triggering tools calls, we can specify use_tools=false
    # If we request to use_tools, the result could specify delegate function calls, which we invoke, or it may 
    # not find any of the tools suitable, and so return a simple text answer.
    parameters[:tools] = tools if use_tools

    response = client.chat(parameters: parameters)
    response_message = response.dig("choices", 0, "message")
    message_content = response_message['content']
    tool_calls = response_message["tool_calls"]

    if tool_calls
      # Tool calls given in the response indicate a need to invoke functions with data, which should programatically 
      # provide further data the agent needs to complete the task.
      tool_calls.each do |tool_call|
        action_result = perform_action(tool_call["function"]["name"], JSON.parse(tool_call["function"]["arguments"]).with_indifferent_access)
        hr = completion(
          [
            {
              role: "user", 
              content: "Convert this result from an api call into a human readable description of the information therein. For #{tool_call['function']['name']} was: #{action_result.to_json}"
            }
          ], false)

        messages += [{role: 'assistant', content: "Observation: #{hr}"}]
      end
      # new_goal = assess(messages)
      completion(messages + [{role: "user", content: "Given the latest data, attempt to give the final result of the task. Phrase it as an answer directly to the user for display in the UI."}], true)
    else
      message_content
    end
  end

  private

  def access_token
    ENV.fetch('OPENAI_KEY')
  end

  def client
    @client ||= OpenAI::Client.new(access_token: access_token)
  end

  def perform_action(action, params)
    case action
    when "get_flight_info"
      get_flight_info(params)
    when "get_geo"
      get_geo(params)
    when "get_weather"
      get_weather(params)
    when"evaluate_expression"
      evaluate_expression(params)
    else
      "Action not recognized"
    end
  rescue => e
    puts e.message
    "Sorry, data necessary from an external tool to complete this request was unavailable."
  end

  def tools
    [
        {
            "type": "function",
            "function": {
                "name": "get_flight_info",
                "description": "Get the current flight information for a given route",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "from": {
                            "type": "string",
                            "description": "Departure airport code (IATA)"
                        },
                        "to": {
                            "type": "string",
                            "description": "Arrival airport code (IATA)"
                        },
                        "date": {
                            "type": "string",
                            "description": "Flight date (YYYY-MM-DD)"
                        }
                    },
                    "required": ["from", "to", "date"]
                }
            }
        },
        {
            "type": "function",
            "function": {
                "name": "get_geo",
                "description": "Get the latitude and longitude for a given location",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "location": {
                            "type": "string",
                            "description": "Name of the location"
                        }
                    },
                    "required": ["location"]
                }
            }
        },
        {
            "type": "function",
            "function": {
                "name": "get_weather",
                "description": "Get the current weather in a given location specified by latitude and longitude",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "latitude": {
                            "type": "string",
                            "description": "The latitude of the location",
                        },
                        "longitude": {
                            "type": "string",
                            "description": "The longitude of the location",
                        },
                        "unit": {
                            "type": "string", 
                            "enum": ["celsius", "fahrenheit"]},
                    },
                    "required": ["latitude", "longitude"],
                },
            },   
        },
      {
        "type": "function",
        "function": {
          "name": "evaluate_expression",
          "description": "Evaluate a mathematical expression",
          "parameters": {
            "type": "object",
            "properties": {
              "expression": {
                "type": "string",
                "description": "The mathematical expression to evaluate, as a syntactically correct ruby programming language expression"
              }
            },
            "required": ["expression"]
          }
        }
      }
    ]
  end

  def get_flight_info(params)
    departure = params[:from]
    arrival = params[:to]
    date = params[:date]

    client_id = ENV.fetch('AMADEUS_ID')
    client_secret = ENV.fetch('AMADEUS_SECRET')

    url = "https://test.api.amadeus.com/v1/security/oauth2/token"
    res = `curl '#{url}' -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=client_credentials&client_id=#{client_id}&client_secret=#{client_secret}"`
    json = JSON.parse(res)
    access_token = json['access_token']

    url = "https://test.api.amadeus.com/v2/shopping/flight-offers?originLocationCode=#{departure}&destinationLocationCode=#{arrival}&departureDate=#{date}&adults=1&currencyCode=USD"
    res = `curl '#{url}' -H 'Authorization: Bearer #{access_token}'`
    JSON.parse(res)['data'].map{|flight| flight.slice("itineraries", "price")}[..9]
  end

  def get_geo(params)
    location = params[:location]
    puts ">>> location: #{location}"

    url = "https://nominatim.openstreetmap.org/search?q=#{CGI.escape(location)}&format=json"
    puts ">>> url: #{url}"
    res = `curl '#{url}'`
    puts ">>> res:"
    puts res
    json = JSON.parse(res)
    "The coordinates for #{location} are #{json.first["lat"]} latitude and #{json.first["lon"]} longitude"
  rescue
    puts ">>> error"
    "I couldn't get the geo coordinates for #{location}"
  end

  def get_weather(params)
    lat = params[:latitude]
    lon = params[:longitude]
    url = "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&current=temperature_2m,weather_code,wind_speed_10m,relative_humidity_2m&temperature_unit=fahrenheit&wind_speed_unit=mph"
    response = HTTParty.get(url)
    if response.success?
      puts ">>> success"
      response.parsed_response
    else
      puts ">>> failure"
      puts response
      "I couldn't get the weather for the specified location"
    end
  end

  def evaluate_expression(params)
    expression = params["expression"]

    begin
      result = eval(expression)
      "The result of the expression '#{expression}' is #{result}"
    rescue StandardError => e
      "Error evaluating expression: #{e.message}"
    end
  end

end
