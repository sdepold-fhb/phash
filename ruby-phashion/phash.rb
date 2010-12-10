require "rubygems"
require "sinatra"
require "sinatra/reloader" if development?
require "phashion"
require "erb"
require File.dirname(__FILE__) + "/vendor/mojo_magick/lib/mojo_magick.rb"

IMAGE_UPLOAD_PATH = "./public/uploads"

def compare_images(params)
  path = File.expand_path("#{IMAGE_UPLOAD_PATH}/#{params[:filename]}")
  source = "#{path}/source"
  options = {:quality => params["quality"] || 100, :percent => params["scale"] || 100}
  modified = "#{path}/#{options.to_s}"
  
  MojoMagick::resize(source, modified, options) unless File.exists?(modified)

  Phashion::Image::SETTINGS[:dupe_threshold] = params["threshold"].to_i || 15
  puts Phashion::Image::SETTINGS[:dupe_threshold]

  img1 = Phashion::Image.new(source)
  img2 = Phashion::Image.new(modified)
  
  {:result => img1.duplicate?(img2), :modified_filename => options.to_s}
end

get "/" do
  erb :index
end

get "/analyze/:filename" do
  erb :analyze
end

post "/upload" do
  upload_path = File.expand_path("#{IMAGE_UPLOAD_PATH}/#{Time.now.to_i}")
  source = upload_path + "/source"
  FileUtils.mkdir_p(upload_path)
  FileUtils.mv(params[:image][:tempfile].path, source)
  
  MojoMagick::resize(source, upload_path + "/thumb", :width => 320, :height => 240)
    
  redirect "/analyze/#{File.basename(upload_path)}"
end

get "/compare/:filename" do
  comparison = compare_images(params)
  
  [
    "<img width='320' height='240' src='/uploads/#{params[:filename]}/#{comparison[:modified_filename]}' />",
    comparison[:result] ? "Equal" : "Not equal"
  ].join("<br/>")
end