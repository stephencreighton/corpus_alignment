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

def sentences(text)
  eos = "\001" # temporary end of sentence marker
  text = text.dup

  # remove random newlines
  text.gsub(/\n/,'').length
  # initial split after punctuation - have to preserve trailing whitespace
  # for the ellipsis correction next
  # would be nicer to use look-behind and look-ahead assertions to skip
  # ellipsis marks, but Ruby doesn't support look-behind
  text.gsub!( /([\.?!](?:\"|\'|\)|\]|\})?)(\s+)/ ) { $1 << eos << $2 }

  # correct ellipsis marks and rows of stops
  text.gsub!( /(\.\.\.*)#{eos}/ ) { $1 }

  # correct abbreviations
  # TODO - precompile this regex?
#  text.gsub!( /(#{@@abbreviations.join("|")})\.#{eos}/i ) { $1 << '.' }

  # split on EOS marker, strip gets rid of trailing whitespace
  text.split(eos).map { | sentence | sentence.strip }
end

def create_word_distribution_array
  words = @source_raw.split 
  freqs=Hash.new(0) 
  words.each { |word| freqs[word] += 1 } 
  freqs.sort_by {|x,y| y }.reverse.each {|w, f| puts w+' '+f.to_s} 
end
  
class String
  def convert_base(from, to)
    self.to_i(from).to_s(to)
  end
end
class XFile
  attr_reader :filename, :source_raw, :source_phrases, :phrase_length_array, :pla_index
  # length array items = [offset (characters from start of raw file), item.length, item (the actual phrase/paragraph)]
  def initialize(filename)
    @filename = filename
    @source_raw = File.read(filename)
    puts @source_raw
    @source_raw.gsub!('\n',"")
    @source_raw.gsub!(/(?<!\n)\n(?!\n)/, " ")
    puts "\n\n\n"
    puts @source_raw
#create_word_distribution_array

#    @source_phrases = source_raw.split(/(?<=[?.!])/)    # *** this gives individual phrases
    @source_phrases = source_raw.split(/\n\n/)       # *** this gives paragraphs
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