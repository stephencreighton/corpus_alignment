class LengthArrayItem
  
  def initialize(char_offset_into_raw_file, phrase_length, phrase)
    @offset = char_offset_into_raw_file
    @len = phrase_length
    @phrase = phrase
  end
end

class XFile
  attr_reader :filename, :source_raw, :source_words, :char_count, :source_phrases, :phrase_length_array, :pla_index
  # length array items = [offset (characters from start of raw file), item.length, item (the actual phrase/paragraph)]
  def initialize(filename)
    @filename = filename
    @source_raw = File.read(filename)
    @char_count = @source_raw.length
    @source_words = @source_raw.split
#    @source_phrases = source_raw.split(/(?<=[\n?.!])/)
    @source_phrases = source_raw.split(/(?<=[\n])/)
    
    @phrase_length_array = []
    @pla_index = -1
    build_length_array(@source_phrases, @phrase_length_array)
#    dump_structure
  end

  def build_length_array (source_array, length_array)
    offset = 0
    source_array.each do |item|
      item = item.gsub(/\s+\Z/, "")
      length_array << [offset, item.length, item]
      offset += item.length
    end
    length_array
  end
  
  MAX_TITLE_LENGTH = 50
  def is_title? (index)
    ((@phrase_length_array[index][1] > 0) && (@phrase_length_array[index][1] < MAX_TITLE_LENGTH) \
      && (index+1 < @phrase_length_array.length-1) && (@phrase_length_array[index+1][1] == 0))    
  end
  
  def next_phrase
    @pla_index += 1
    if (@pla_index < @phrase_length_array.length)
      @phrase_length_array[@pla_index]
    else
      nil
    end
  end
  
  def set_phrase_index(value)
    if (value < @phrase_length_array.length)
      @pla_index = value
    else
      nil
    end
  end

  def dump_structure
    puts "\nStructure for #{@filename}:    #{@source_phrases.length}   #{@source_raw.length}\n"
    (0..@source_phrases.length).each do |x|
      puts "#{x}:"
      puts @source_phrases[x]
      puts "\t#{@phrase_length_array[x]}"
    end
  end

  def inspect
    puts "\nMetrics for #{@filename}:"
    puts "Number of characters: #{@source_raw.length}"
    puts "Number of words: #{@source_words.size}"
    puts "Number of phrases:  #{@source_phrases.size}"
    puts "Number of paragraphs:  #{@source_raw.split(/\n\n/).length}"
  end

  def blah
    puts "---------------"
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
    puts"5"
    puts @source_phrases[5]
    puts"-2"
    puts @source_phrases[-2]
    puts "-1"
    puts @source_phrases[-1]
    #    puts "\n@phrase_length_array:  \n"
    #    puts @phrase_length_array[0]
    #    puts @phrase_length_array[1]
    #    puts @phrase_length_array[2]
    #    puts @phrase_length_array[3]
    #    puts @phrase_length_array[4]
    #    puts "\n\n#{@phrase_length_array}\n"  
  end
end