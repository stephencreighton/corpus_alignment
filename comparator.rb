require_relative 'xfile.rb'

class Comparator
  attr_reader :aligned_pairs, :overall_confidence_score  # aligned_pairs item = [index in the from phrase array, index in the to phrase array,
                                                         # 'TITLE' | 'TEXT']
  attr_accessor :text_expansion_factor, :from_file, :to_file

  def initialize(from_file, to_file)
    puts "\nComparing #{from_file.filename}, #{to_file.filename}"
    @from_file = from_file
    @to_file = to_file
    @overall_confidence_score = 0
    @aligned_pairs = []
    @text_expansion_factor = 1.20  # en to fr - will want to read this in from file?
    compare_structures
    File.open('aligned_pairs.out', 'w') { |file| file.write(@aligned_pairs) }
  end
  
  def compare_pair(from_item, to_item)
    puts "\t-- #{from_item}   #{to_item}   #{from_item[1] * (1-((@text_expansion_factor-1)*2))}    #{from_item[1] * (1-(@text_expansion_factor-1))}       #{from_item[1]*@text_expansion_factor}   #{from_item[1] * (1+((@text_expansion_factor-1)*6))}"
    # will definitely want to redo this...this just gives rough values based on standard deviations
    if ( (to_item[1] >= (from_item[1] * (1-(@text_expansion_factor-1)))) && (to_item[1] <= (from_item[1] * @text_expansion_factor)) )
      1.0
    elsif ( (to_item[1] >= (from_item[1] * (1-((@text_expansion_factor-1)*2)))) && (to_item[1] <= (from_item[1] * (1+((@text_expansion_factor-1)*2)))) )
      0.5
    elsif ( (to_item[1] >= (from_item[1] * (1-((@text_expansion_factor-1)*2)))) && (to_item[1] <= (from_item[1] * (1+((@text_expansion_factor-1)*6)))) )
      0.25
    else
      0.0
    end
    
  end
  
  def compare_structures
    last_known_match_index = 0
    from_index = 0
    to_index = 0
#    (0..@from_file.phrase_length_array.length).each do |from_index|
    while ( (from_index < @from_file.phrase_length_array.length) && (to_index < @to_file.phrase_length_array.length) )
      f = @from_file.phrase_length_array[from_index]
      t = @to_file.phrase_length_array[to_index]
      puts "\n#{from_index}:  #{f}   #{t}"
      
      # if gross mismatch, set last_known_good marker here and continue to next to_index, searching for a logical match
      while ((result = compare_pair(f,t)) == 0.0)
        if (f[1] == 0) 
          puts "skipping from from_index=#{from_index} to #{from_index + 1}"
          from_index += 1
          if (from_index >= @from_file.phrase_length_array.length)
            puts "---breaking out of inside loop"
            break
          else 
            t = @from_file.phrase_length_array[from_index]
          end
        else
          puts "skipping from to_index=#{to_index} to #{to_index + 1}"
          to_index += 1
          if (to_index >= @to_file.phrase_length_array.length)
            puts "---breaking out of inside loop"
            break
          else 
            t = @to_file.phrase_length_array[to_index]          
          end
        end
      end
        
      # if this is a title/subtitle, i.e. length<50 and followed by a newline
      if ((f.length < 50) && (t.length < 50) && (from_file.phrase_length_array[from_index+1][1] == 0) && (to_file.phrase_length_array[to_index+1][1] == 0))
        @aligned_pairs << [from_index, to_index, 'TITLE']
        puts "@aligned_pairs:  #{from_index}, #{to_index}, 'TITLE'"
      elsif (result > 0.5)
        @aligned_pairs << [from_index, to_index, 'TEXT']
      end
      from_index += 1
      to_index += 1
    end
    @aligned_pairs
  end

  def generate_confidence_score
    @to_file.word_count / (@from_file.word_count * @text_expansion_factor)
  end
end
