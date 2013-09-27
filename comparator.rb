require_relative 'xfile.rb'
require_relative 'aligned_pairs'

class Comparator
  attr_reader :overall_confidence_score, :ap_outfilename
  attr_accessor :text_expansion_factor, :from_file, :to_file

  def initialize(from_file, to_file)
    puts "\nComparing #{from_file.filename}, #{to_file.filename}"
    @from_file = from_file
    @to_file = to_file
    @overall_confidence_score = 0
    @text_expansion_factor = 1.20  # en to fr - will want to read this in from file?
    @ap_outfilename = "align_#{from_file.filename}_with_#{to_file.filename}.out"
    @ap_array = AlignedPairsArray.new
    compare_structures
    dump_to_file
  end
  
  def compare_pair(from_item, to_item)
    # will definitely want to redo this...this just gives rough values based on standard deviations
    if ( (from_file.is_title? (from_item.array_index)) && (to_file.is_title? (to_item.array_index)) )
      return 0.8
    end
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
    do_puts = false
    
    while (f = @from_file.next_phrase)
      t = @to_file.next_phrase
      break if (t == nil)
      while (f.length == 0)
        f = from_file.next_phrase
      end
      puts "\n#{from_file.pla_index}:  #{f.length} -- #{f.phrase}     #{to_file.pla_index}:  #{t.length} -- #{t.phrase}" if do_puts

      t_index = t.array_index  # save so we can reset if we reach eof
      while ((score = compare_pair(f,t)) == 0.0)
        puts "compare_pair() = #{score}   #{f.array_index}:  #{f.phrase}     #{t.array_index}:  #{t.phrase}" if do_puts
        t = @to_file.next_phrase
        if (t == nil)  # EOF
          to_file.set_phrase_index(t_index)
          break
        end
        next if (t.length == 0)
      end
      next if (t == nil)
      puts "compare_pair() = #{score}   #{f.array_index}:  #{f.phrase}     #{t.array_index}:  #{t.phrase}" if do_puts
      if (from_file.is_title? (f.array_index))   # if this is a title/subtitle, i.e. length<50 and followed by a newline
        @ap_array.add(f.phrase, t.phrase, 'TITLE', 0.8)                
      else
        @ap_array.add(f.phrase, t.phrase, 'TEXT', score)                
      end
    end
    @aligned_pairs
  end

  def inspect
    x = (@ap_array.aligned_pairs_index * 100.0) / (from_file.pla_index * 1.0)
    puts "Aligned #{x.round}% (#{ @ap_array.aligned_pairs_index} / #{from_file.pla_index} phrases) of #{from_file.filename}"
    puts "Confidence score for final aligned pairs:  #{(@ap_array.aligned_pairs_cum_score / @ap_array.aligned_pairs_index * 100).round(2)}"
  end
  
  def dump_to_file
    puts "Writing to #{@ap_outfilename}"
    File.open(@ap_outfilename.to_s, 'w') do |file| 
      file.write("Alignment of #{from_file.filename} with #{to_file.filename}") 
      x = (@ap_array.aligned_pairs_index * 100.0) / (from_file.pla_index * 1.0)
      file.write ("\nAligned #{x.round}% (#{ @ap_array.aligned_pairs_index} / #{from_file.pla_index} phrases) of #{from_file.filename}")
      file.write ("\nConfidence score for final aligned pairs:  #{(@ap_array.aligned_pairs_cum_score / @ap_array.aligned_pairs_index * 100).round(2)}")
      file.write("\n#{@ap_array.inspect}")
    end
  end
end
