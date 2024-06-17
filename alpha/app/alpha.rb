require 'sinatra'

class Alpha < Sinatra::Base
  get "/" do
    "Alpha"
  end
end