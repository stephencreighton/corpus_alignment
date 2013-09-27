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
  attr_reader :filename, :source_raw, :source_phrases, :phrase_length_array, :pla_index
  # length array items = [offset (characters from start of raw file), item.length, item (the actual phrase/paragraph)]
  def initialize(filename)
    @filename = filename
    @source_raw = File.read(filename)

#    @source_phrases = source_raw.split(/(?<=[\n?.!])/)    # *** this gives individual phrases
    @source_phrases = source_raw.split(/(?<=[\n])/)       # *** this gives paragraphs - appears to work better than small phrases
    
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
    if (@pla_index >= @phrase_length_array.length)
      nil
    else
      @phrase_length_array[@pla_index]
    end
  end
  
  def set_phrase_index(value)
    if (value >= @phrase_length_array.length)
      nil
    else
      @pla_index = value
    end
  end

  def is_title? (index)
    if ((index+1) >= @phrase_length_array.length)
      return nil
    end
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
    puts "Number of words: #{@source_raw.split.size}"
    puts "Number of phrases:  #{@source_phrases.size}"
    puts "Number of paragraphs:  #{@source_raw.split(/\n\n/).length}"
  end
end