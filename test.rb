#!/usr/bin/ruby


class XFile
  attr_reader :filename, :raw_source, :array_source, :char_count, :word_count
#  Metrics = Struct.new (:char_count, :word_count) 

  def initialize(filename)
    @filename = filename
    @raw_source = File.read(filename)  
    @char_count = @raw_source.length
    @array_source = @raw_source.split
    @word_count = @array_source.size
  end

  def inspect
    puts "\nMetrics for #@filename:"
    puts "Number of words: #@word_count"
    puts "Number of characters: #@char_count"
  end

end


class Comparator
  def initialize(file1, file2)
    puts "Comparing #{file1.filename}, #{file2.filename}"
    
  end
end


fromfile = XFile.new ARGV[0]
fromfile.inspect
File.open(fromfile.filename + '.out', 'w') { |file| file.write(fromfile.raw_source) }


tofile = XFile.new ARGV[1]
tofile.inspect
File.open(tofile.filename + '.out', 'w') { |file| file.write(tofile.raw_source) }

comp = Comparator.new(fromfile, tofile)