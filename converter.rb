require 'fileutils'
require 'digest/sha1'
require './lib/parser'

parser = Parser.new
lin_files = Dir['./lin/*.lin']

i = 0

lin_files.each do |file|
  puts "parsing #{file}"

  contents = File.read(file)
  original_hash = Digest::SHA1.hexdigest(contents)
  boards = parser.parse(file, contents)
  boards.each_with_index do |board, index|
    contents = board.to_json
    hash = Digest::SHA1.hexdigest("#{original_hash}/#{index}")
    parts = hash.scan(/(..)(..)(..)(.*)/)[0]
    path = File.join("boards", parts[0], parts[1], parts[2], "#{parts[3]}.json")
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') do |f|
      f << contents
    end
    puts "i: #{i}"
    i += 1
  end
  exit if i >= 100
end