require_relative 'xfile.rb'

class AlignedPairsArrayItem
  # aligned_pairs item = [from text, to text, 'TITLE' | 'TEXT', score]
  attr_reader :array_index, :from_phrase, :to_phrase, :type, :score
  def initialize(array_index, from_phrase, to_phrase, type, score)
    @array_index = array_index
    @from_phrase = from_phrase
    @to_phrase = to_phrase
    @type = type
    @score = score
  end
  
  def inspect
    "#{@array_index}:  #{@from_phrase} -- #{@to_phrase} -- #{@type} -- #{@score}"
  end
end

class Comparator
  attr_reader :aligned_pairs, :aligned_pairs_index, :aligned_pairs_from_char_count, :aligned_pairs_cum_score, :overall_confidence_score  
  attr_accessor :text_expansion_factor, :from_file, :to_file

  def initialize(from_file, to_file)
    puts "\nComparing #{from_file.filename}, #{to_file.filename}"
    @from_file = from_file
    @to_file = to_file
    @overall_confidence_score = 0
    @aligned_pairs = []
    @aligned_pairs_index = 0
    @aligned_pairs_from_char_count = 0
    @aligned_pairs_cum_score = 0
    @text_expansion_factor = 1.20  # en to fr - will want to read this in from file?
    compare_structures
    dump_aligned_pairs
  end
  
  def dump_aligned_pairs
    File.open("aligned_pairs.out", 'w') do |file| 
      file.write("Aligning #{from_file.filename} with #{to_file.filename}\n") 
      (0..@aligned_pairs.length-1).each do |x|
        file.write("\n#{@aligned_pairs[x].inspect}")
      end
    end
  end
  
  def compare_pair(from_item, to_item)
    # length array items = [offset (characters from start of raw file), item.length, item (the actual phrase/paragraph)]

#    puts "\t-- #{from_item}   #{to_item}   #{from_item[1] * (1-((@text_expansion_factor-1)*2))}    #{from_item[1] * (1-(@text_expansion_factor-1))}       #{from_item[1]*@text_expansion_factor}   #{from_item[1] * (1+((@text_expansion_factor-1)*6))}"

    # will definitely want to redo this...this just gives rough values based on standard deviations
#    puts "\tcp: #{from_item.phrase} --- #{to_item.phrase}"
    if ( (from_file.is_title? (from_item.array_index)) && (to_file.is_title? (to_item.array_index)) )
      return 0.8
    end
#    puts "\tcp: #{from_item.length} --- #{to_item.length}"
    if ( (to_item.length >= (from_item.length * (1-(@text_expansion_factor-1)))) \
      && (to_item.length <= (from_item.length * @text_expansion_factor)) )
      1.0
    elsif ( (to_item.length >= (from_item.length * (1-((@text_expansion_factor-1)*2)))) \
      && (to_item.length <= (from_item.length * (1+((@text_expansion_factor-1)*2)))) )
      0.5
    elsif ( (to_item.length >= (from_item.length * (1-((@text_expansion_factor-1)*2)))) \
      && (to_item.length <= (from_item.length * (1+((@text_expansion_factor-1)*6)))) )
      0.25
    else
      0.0
    end
    
  end
  
  def compare_structures
    do_puts = true
    last_known_match_index = 0
    from_index = 0
    to_index = 0
    
    while (f = @from_file.next_phrase)
      t = @to_file.next_phrase
      break if (t == nil)
      while (f.length == 0)
        f = from_file.next_phrase
      end
      puts "\n#{from_file.pla_index}:  #{f.length} -- #{f.phrase}     #{to_file.pla_index}:  #{t.length} -- #{t.phrase}" if do_puts

      t_index = t.array_index  # save so we can reset if we reach eof
      while ((comp_result = compare_pair(f,t)) == 0.0)
        puts "compare_pair() = #{comp_result}   #{f.array_index}:  #{f.phrase}     #{t.array_index}:  #{t.phrase}" if do_puts
        t = @to_file.next_phrase
        next if (t.length == 0)
        if (t == nil)  # EOF
          to_file.set_phrase_index(t_index)
          break
        end
      end
      next if (t == nil)
      puts "compare_pair() = #{comp_result}   #{f.array_index}:  #{f.phrase}     #{t.array_index}:  #{t.phrase}" if do_puts

      @aligned_pairs_from_char_count += f.phrase.length
      if (from_file.is_title? (f.array_index))   # if this is a title/subtitle, i.e. length<50 and followed by a newline
        @aligned_pairs << AlignedPairsArrayItem.new(@aligned_pairs_index, f.phrase, t.phrase, 'TITLE', comp_result)        
        puts "@aligned_pairs[#{@aligned_pairs_index}]:  #{f.phrase} -- #{t.phrase}, 'TITLE', 0.8" if do_puts
        @aligned_pairs_index += 1
        @aligned_pairs_cum_score += 0.8
      else
        @aligned_pairs << AlignedPairsArrayItem.new(@aligned_pairs_index, f.phrase, t.phrase, 'TEXT', comp_result)        
        puts "@aligned_pairs[#{@aligned_pairs_index}]:  #{f.phrase} -- #{t.phrase}, 'TEXT', #{comp_result}" if do_puts          
        @aligned_pairs_index += 1
        @aligned_pairs_cum_score += comp_result
      end
          end
    @aligned_pairs
  end

  def generate_confidence_score
    @to_file.word_count / (@from_file.word_count * @text_expansion_factor)
  end

  def dump(array, filename)
    (0..array.length).each do |x|
      puts "#{x}:  #{array[x]}"
      open(filename, 'a') { |f| f.puts "#{x}:  #{array[x]}" }
      #      File.open(filename, 'w') { |file| file.write(array[x]) }
    end
  end
end
