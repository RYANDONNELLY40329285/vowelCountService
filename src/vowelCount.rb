# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'rack/protection'


use Rack::Protection

configure do
  set :port, 4567
  set :bind, '0.0.0.0'

  # safety: avoid someone sending a 10MB string
  set :max_string_length, 10_000
end

before do
  # All responses from this app are JSON
  content_type :json
end

helpers do
  # Count vowels (case-insensitive)
  def vowel_count(str)
    str.scan(/[aeiou]/i).size
  end

  # Centralised fetching + validation of `stringInput`
  def fetch_and_validate_input
    raw = params['stringInput']


    halt 400, { error: 'Missing parameter: stringInput' }.to_json if raw.nil?

    input = raw.to_s.strip

    halt 400, { error: 'stringInput cannot be empty' }.to_json if input.empty?

  
    if input.length > settings.max_string_length
      halt 413, { error: "stringInput too long (max #{settings.max_string_length} characters)" }.to_json
    end

    input
  end
end

# GET /vowelCount?stringInput=HelloWorld
get '/vowelCount' do
  input = fetch_and_validate_input
  count = vowel_count(input)

  { vowelCount: count }.to_json
end

get '/health' do
  status 200
  { status: 'ok' }.to_json
end