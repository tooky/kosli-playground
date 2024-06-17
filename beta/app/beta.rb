# frozen_string_literal: true

require 'sinatra'

# Example monorepo micro-service
class Beta < Sinatra::Base
  get '/' do
    'Beta'
  end

  get '/ready' do
    true
  end
end
