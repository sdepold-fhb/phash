require 'rubygems'
require 'nokogiri' #install with > gem install nokogiri

class PHash
  ENDPOINT = "http://phash.org/cgi-bin/phash-demo-new.cgi"
  ALGORITHMS = %w(radish pixtube mh)
  RESULT_FILE = "phash_tmp.html"
  
  def initialize(file1, file2, options={})
    @file1 = file1
    @file2 = file2
    @options = options
  end
  
  def compare(algorithm)
    `#{generate_curl_command(algorithm)} > #{RESULT_FILE}`
    
    result = evaluate_result(algorithm)
    File.delete(RESULT_FILE)
    
    result
  end
  
  private
  
  def generate_curl_command(algorithm)
    params = []

    params << ["-x", @options[:proxy]] if @options[:proxy]
    params << ["--header", "Accept: application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5"]
    params << ["-F", "algorithm=#{algorithm}"]
    params << ["-F", "file1=@#{@file1}"]
    params << ["-F", "file2=@#{@file2}"]

    joined_params = params.map{|k, v| [k, '"' + v + '"'].join(" ")}.join(" ")

    "curl #{joined_params} -0 #{ENDPOINT}"
  end
  
  def evaluate_result(algorithm)
    value_regexps = {
      ALGORITHMS[0] => /PCC.=.(.*)\.T/,
      ALGORITHMS[1] => /distance.=.(.*)\.T/,
      ALGORITHMS[2] => /distance.=.(.*)\.T/
    }
    
    #read the file and replace all <br> with <br/>
    result = File.read(RESULT_FILE).gsub("<br>", "<br/>")
    doc = Nokogiri::HTML(result)

    phash_result_paragraph = doc.css('#promo > div > p').last.content
    value = [phash_result_paragraph.match(value_regexps[algorithm]), $1].last.to_f
    is_similiar = [phash_result_paragraph.match(/are.(.*?).?similar/), $1].last != 'not'

    { :value => value, :is_similiar => is_similiar }
  end
end