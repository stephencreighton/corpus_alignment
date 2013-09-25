class XFile
  attr_reader :filename, :source_raw, :source_words, :char_count, :word_count, :source_phrases, :phrase_length_array

  def initialize(filename)
    @filename = filename
    @source_raw = File.read(filename)
    @char_count = @source_raw.length
    @source_words = @source_raw.split
    @word_count = @source_words.size
#    @source_phrases = @source_raw.split(/\n\n/).each { |x| x.split(/((?<=[a-z0-9)][.?!;:])|(?<=[a-z0-9][.?!;:]"))\s+(?="?[a-zA-Z])/)} 
#    zzz = @source_raw.split(/\n\n/)
#    zzz.each do |x| 
#      @source_phrases << x.split(/((?<=[a-z0-9)][.?!;:])|(?<=[a-z0-9][.?!;:]"))\s+(?="?[a-zA-Z])/)
#    end
#    @source_phrases = source_raw.split(/.;:?/)     
#    @source_phrases = source_raw.split(/((?<=[a-z0-9)][.?!;:])|(?<=[a-z0-9][.?!;:]"))\s+(?="?[a-zA-Z])/)
    @source_phrases = source_raw.split(/(?<=[\n?.!])/)
    @phrase_length_array = []
    build_phrases_structure
    dump_phrases_structure
  end

  def build_phrases_structure
    offset = 0
    @source_phrases.each do |phrase|
      @phrase_length_array << [offset, phrase.length]
      offset += phrase.length
    end
    
  end

  def dump_phrases_structure
    puts "\n@source_phrases:  \n"
    puts"0"
    puts @source_phrases[0]
    puts"1"
    puts @source_phrases[1]
    puts"2"
    puts @source_phrases[2]
    puts"3"
    puts @source_phrases[3]
    puts"4"
    puts @source_phrases[4]
    puts "\n@phrase_length_array:  \n"
    puts @phrase_length_array[0]
    puts @phrase_length_array[1]
    puts @phrase_length_array[2]
    puts @phrase_length_array[3]
    puts @phrase_length_array[4]
    puts "\n\n#{@phrase_length_array}\n"
  end

  def inspect
    puts "\nMetrics for #@filename:"
    puts "Number of characters: #@char_count"
    puts "Number of words: #@word_count"
    puts "Number of phrases:  #{@source_phrases.size}"
    puts "Number of paragraphs:  #{@source_raw.split(/\n\n/).length}"
  end

end