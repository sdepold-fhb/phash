require "phash.rb"

file1="/Users/prototype/Pictures/Wallpapers/11002003953.jpg"
file2="/Users/prototype/Pictures/Wallpapers/11002013080.jpg"

p_hash = PHash.new(file1, file2)
#p_hash = PHash.new(file1, file2, {:proxy => "proxy.fh-brandenburg.de:3128"})

puts p_hash.compare(PHash::ALGORITHMS[0]).inspect
puts p_hash.compare(PHash::ALGORITHMS[1]).inspect
puts p_hash.compare(PHash::ALGORITHMS[2]).inspect