require "rubygems"
require "sinatra"
require "sinatra/reloader" if development?
require "phashion"
require "haml"

get "/" do
  haml :index
end