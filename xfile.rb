MAX_TITLE_LENGTH = 50

class PhraseArrayItem
  attr_reader :array_index, :length, :phrase
  def initialize(array_index, char_offset_into_raw_file, phrase_length, phrase)
    @array_index = array_index
    @offset = char_offset_into_raw_file
    @length = phrase_length
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
    @pla_index = 0
    source_array.each do |item|
      item = item.gsub(/\s+\Z/, "")
      length_array << PhraseArrayItem.new(@pla_index, offset, item.length, item)
      @pla_index += 1
      offset += item.length
    end
    @pla_index = -1  # reset for search
    length_array
  end
  
  def next_phrase
    @pla_index += 1
    if (@pla_index < @phrase_length_array.length)
      @phrase_length_array[@pla_index]
    else
      nil
    end
  end
  
  def see_phrase_at(index)
    @phrase_length_array[index]
  end
  
  def set_phrase_index(value)
    if (value < @phrase_length_array.length)
      @pla_index = value
    else
      nil
    end
  end

  def is_title? (index)
    if ((index+1) >= @phrase_length_array.length)
#puts "\t#{@filename} is_title: eof"      
      return nil
    end
#puts ("\t#{@filename} is_title: #{@phrase_length_array[index].length}   #{@phrase_length_array[index].phrase}   next: #{@phrase_length_array[index+1].phrase}")
    ((@phrase_length_array[index].length > 0) && (@phrase_length_array[index].length < MAX_TITLE_LENGTH) \
      && (index+1 < @phrase_length_array.length-1) && (@phrase_length_array[index+1].length == 0))    
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