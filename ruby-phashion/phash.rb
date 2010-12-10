require "rubygems"
require "sinatra"
require "sinatra/reloader" if development?
require "phashion"
require "erb"
require "RMagick"
include Magick

get "/" do
  erb :index
end

post "/upload" do
  upload_path = File.expand_path("./uploads/image_#{Time.now.to_i}")
  FileUtils.mv(params[:image][:tempfile].path, upload_path)
  redirect "/analyze/#{File.basename(upload_path)}"
end

get "/analyze/:filename" do
  path = File.expand_path("./uploads/#{params[:filename]}")
  mime_type = ImageList.new(path).mime_type
  send_file path, :type => mime_type
end