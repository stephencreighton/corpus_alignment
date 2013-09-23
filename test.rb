#!/usr/bin/ruby


class XFile
  attr_reader :filename, :source_raw, :source_words, :char_count, :word_count, :source_phrases

  def initialize(filename)
    @filename = filename
    @source_raw = File.read(filename)  
    @char_count = @source_raw.length
    @source_words = @source_raw.split
    @word_count = @source_words.size
    @source_phrases = source_raw.split(/((?<=[a-z0-9)][.?!;:])|(?<=[a-z0-9][.?!;:]"))\s+(?="?[a-zA-Z])/)
  end

  def inspect
    puts "\nMetrics for #@filename:"
    puts "Number of characters: #@char_count"
    puts "Number of words: #@word_count"
    puts "Number of phrases:  #{@source_phrases.size}"
    puts "Number of paragraphs:  #{@source_raw.split(/\n\n/).length}"
  end

end


class Comparator
  attr_reader :confidence_score
  attr_accessor :text_expansion_factor, :file1, :file2

  def initialize(file1, file2)
    puts "\nComparing #{file1.filename}, #{file2.filename}"    
    @file1 = file1
    @file2 = file2
    @confidence_score = 0
    @text_expansion_factor = 1.20  # en to fr
  end

  def generate_confidence_score
    @file2.word_count / (@file1.word_count * @text_expansion_factor) 
  end
end


fromfile = XFile.new ARGV[0]
fromfile.inspect
File.open(fromfile.filename + '.out', 'w') { |file| file.write(fromfile.source_raw) }


tofile = XFile.new ARGV[1]
tofile.inspect
File.open(tofile.filename + '.out', 'w') { |file| file.write(tofile.source_raw) }

comp = Comparator.new(fromfile, tofile)
puts "Confidence Score = #{comp.generate_confidence_score}"
