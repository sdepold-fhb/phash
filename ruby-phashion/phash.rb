require "rubygems"
require "sinatra"
require "sinatra/reloader" if development?
require "phashion"
require "erb"
require File.dirname(__FILE__) + "/vendor/mojo_magick/lib/mojo_magick.rb"

IMAGE_UPLOAD_PATH = "./public/uploads"

def compare_images(params)
  path = File.expand_path("#{IMAGE_UPLOAD_PATH}/#{params[:filename]}")
  file_ending = MojoMagick::file_ending("#{path}/source*")
  source_path = "#{path}/source.#{file_ending}"
  options = {:quality => params["quality"] || 100, :percent => params["scale"] || 100}
  options_as_string = options.to_a.map{|o| o.join("")}.join("")
  modified = "#{options_as_string}.#{file_ending}"
  modified_path = "#{path}/#{modified}"
  
  MojoMagick::resize(source_path, modified_path, options) unless File.exists?(modified)

  Phashion::Image::SETTINGS[:dupe_threshold] = params["threshold"].to_i || 15
  puts Phashion::Image::SETTINGS[:dupe_threshold]

  img1 = Phashion::Image.new(source_path)
  img2 = Phashion::Image.new(modified_path)
  
  {:result => img1.duplicate?(img2), :modified_filename => modified}
end

get "/" do
  erb :index
end

get "/analyze/:filename/:file_ending" do
  erb :analyze
end

post "/upload" do
  upload_path = File.expand_path("#{IMAGE_UPLOAD_PATH}/#{Time.now.to_i}")
  file_ending = MojoMagick::file_ending(params[:image][:tempfile].path)
  source = upload_path + "/source.#{file_ending}"

  FileUtils.mkdir_p(upload_path)
  FileUtils.mv(params[:image][:tempfile].path, source)
  
  MojoMagick::resize(source, upload_path + "/thumb.#{file_ending}", :width => 320, :height => 240)
    
  redirect "/analyze/#{File.basename(upload_path)}/#{file_ending}"
end

get "/compare/:filename" do
  comparison = compare_images(params)
  
  [
    "<img width='320' height='240' src='/uploads/#{params[:filename]}/#{comparison[:modified_filename]}' />",
    comparison[:result] ? "Equal" : "Not equal"
  ].join("<br/>")
end