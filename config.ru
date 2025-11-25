# config.ru
# Rack configuration file to run the Sinatra app

require_relative "./src/vowelCount"

run Sinatra::Application