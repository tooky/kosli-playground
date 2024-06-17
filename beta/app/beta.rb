require 'sinatra'

class Beta < Sinatra::Base
  get "/" do
    "Beta"
  end
end