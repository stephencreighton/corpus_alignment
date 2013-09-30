require_relative 'phase_array_item.rb'

class XFile
  MAX_TITLE_LENGTH = 50
  attr_reader :filename, :source_raw, :source_phrases, :phrase_length_array, :pla_index
  # length array items = [offset (characters from start of raw file), item.length, item (the actual phrase/paragraph)]
  def initialize(filename)
    @filename = filename
    @source_raw = File.read(filename)
    @source_raw.gsub!(/(?<!\n)\n(?!\n)/, " ") # strip out hard LFs at end of lines
    
    #create_word_distribution_array

#    @source_phrases = source_raw.split(/(?<=[?.!])/)    # *** use individual phrases
    @source_phrases = source_raw.split(/\n\n/)       # *** use  paragraphs
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
  
  def pla_out_of_bounds(index)
    index >= @phrase_length_array.length
  end
  
  def next_phrase
    @pla_index += 1
    @phrase_length_array[@pla_index] unless pla_out_of_bounds(@pla_index)
  end
  
  def set_phrase_index(value)
    @pla_index = value unless pla_out_of_bounds(@pla_index)
  end

  def is_title? (index)
    ((@phrase_length_array[index].length > 0) && (@phrase_length_array[index].length < MAX_TITLE_LENGTH) \
      && (index+1 < @phrase_length_array.length-1) && (@phrase_length_array[index+1].length == 0))\
      unless pla_out_of_bounds(@pla_index)
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