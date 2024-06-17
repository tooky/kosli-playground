# frozen_string_literal: true

require 'sinatra'

# Example monorepo micro-service
class Alpha < Sinatra::Base
  get '/' do
    'Alpha'
  end

  get '/ready' do
    true
  end
end
