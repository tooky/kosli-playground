# frozen_string_literal: true

require 'sinatra'
require_relative 'prober'

# Example monorepo micro-service
class Alpha < Sinatra::Base
  get '/' do
    'Arancini'
  end

  get '/ready' do
    Prober.new.ready?
  end
end
