# frozen_string_literal: true


require "simplecov"
SimpleCov.start do
  enable_coverage :branch
  add_filter "/vendor/"
end


ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'json'
require_relative 'vowelCount' 

class VowelCountAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end


  def test_valid_input_counts_vowels
    get '/vowelCount', stringInput: 'HelloWorld'
    assert_equal 200, last_response.status

    body = JSON.parse(last_response.body)
    assert_equal 3, body['vowelCount'] # e, o, o
  end


  def test_case_insensitive_vowels
    get '/vowelCount', stringInput: 'AeIoU'
    assert_equal 200, last_response.status

    body = JSON.parse(last_response.body)
    assert_equal 5, body['vowelCount']
  end


  def test_missing_string_input_param
    get '/vowelCount'
    assert_equal 400, last_response.status

    body = JSON.parse(last_response.body)
    assert_equal 'Missing parameter: stringInput', body['error']
  end


  def test_empty_string_rejected
    get '/vowelCount', stringInput: '    '
    assert_equal 400, last_response.status

    body = JSON.parse(last_response.body)
    assert_equal 'stringInput cannot be empty', body['error']
  end

  def test_numeric_param_treated_as_string
    get '/vowelCount', stringInput: 12345
    assert_equal 200, last_response.status

    body = JSON.parse(last_response.body)
    assert_equal 0, body['vowelCount']
  end


  def test_max_length_boundary_allowed
    max_len = app.settings.max_string_length
    input   = 'a' * max_len

    get '/vowelCount', stringInput: input
    assert_equal 200, last_response.status

    body = JSON.parse(last_response.body)
    # all 'a' so vowel count == length
    assert_equal max_len, body['vowelCount']
  end


  def test_too_long_string_rejected
    max_len = app.settings.max_string_length
    input   = 'a' * (max_len + 1)

    get '/vowelCount', stringInput: input
    assert_equal 413, last_response.status

    body = JSON.parse(last_response.body)
    expected_msg = "stringInput too long (max #{max_len} characters)"
    assert_equal expected_msg, body['error']
  end


  def test_string_with_no_vowels
    get '/vowelCount', stringInput: 'bcdfg'
    assert_equal 200, last_response.status

    body = JSON.parse(last_response.body)
    assert_equal 0, body['vowelCount']
  end
end
