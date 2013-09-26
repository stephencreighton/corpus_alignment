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

    (0..from_file.phrase_length_array.length).each do |x|
#      puts "#{x}:  #{@from_file.phrase_length_array[x]}   #{@to_file.phrase_length_array[x]}  "
      open("aligned_pairs.out", 'a') { |f| f.puts  "#{x}:  #{@from_file.phrase_length_array[x]}   #{@to_file.phrase_length_array[x]}" }
    end
#    (0..@aligned_pairs.length-1).each do |x|
#      a = @aligned_pairs[x]
#      puts "#{x}:  #{a[0]}:   #{@from_file.phrase_length_array[a[0]]}     #{a[1]}:  #{@to_file.phrase_length_array[a[1]]}"
#      open("aligned_pairs.out", 'a') { |f| f.puts "#{x}:  #{a[0]}:   #{@from_file.phrase_length_array[a[0]]}     #{a[1]}:  #{@to_file.phrase_length_array[a[1]]}"    }
#    end

  end
  
  
  def compare_pair(from_item, to_item)
    # length array items = [offset (characters from start of raw file), item.length, item (the actual phrase/paragraph)]

#    puts "\t-- #{from_item}   #{to_item}   #{from_item[1] * (1-((@text_expansion_factor-1)*2))}    #{from_item[1] * (1-(@text_expansion_factor-1))}       #{from_item[1]*@text_expansion_factor}   #{from_item[1] * (1+((@text_expansion_factor-1)*6))}"

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
    do_puts = true
    last_known_match_index = 0
    from_index = 0
    to_index = 0
#    (0..@from_file.phrase_length_array.length).each do |from_index|       ###is there a more elegant, rubyish way to do this?
    while ( (from_index < @from_file.phrase_length_array.length) && (to_index < @to_file.phrase_length_array.length) )
      f = @from_file.phrase_length_array[from_index]
      t = @to_file.phrase_length_array[to_index]
      puts "\n#{from_index}:  #{f}     #{to_index}:  #{t}" if do_puts
# length array items = [offset (characters from start of raw file), item.length, item (the actual phrase/paragraph)]
      
       # remove blank lines iff they're BOTH blank
      if ((f[1] == 0) && (t[1] == 0) )
        from_index += 1
        to_index += 1
        puts "removing both blank lines" if do_puts
        next
      end
      
      # if this is a title/subtitle, i.e. length<50 and followed by a newline
      ### clean up next line
      if ((f.length < 50) && (t.length < 50) && (from_index+1 < from_file.phrase_length_array.length) && (from_file.phrase_length_array[from_index+1][1] == 0) && (to_index+1 < to_file.phrase_length_array.length) && (to_file.phrase_length_array[to_index+1][1] == 0))
        #@aligned_pairs << [from_index, to_index, 'TITLE']
        @aligned_pairs << [f[2], t[2], 'TITLE', 0.8]
        puts "@aligned_pairs:  #{f[2]} -- #{t[2]}, 'TITLE', 0.8" if do_puts
        from_index += 1
        to_index += 1
        next
      end
      
      # if gross mismatch, set last_known_good marker here and continue to next to_index, searching for a logical match
      while ((result = compare_pair(f,t)) == 0.0)
        puts "compare_pair() = #{result}" if do_puts
        if (f[1] == 0) 
          puts "skipping from from_index=#{from_index} to #{from_index + 1}" if do_puts
          from_index += 1
          if (from_index >= @from_file.phrase_length_array.length)
            puts "---breaking out of inside loop" if do_puts
            break
          else 
            t = @from_file.phrase_length_array[from_index]
          end
        elsif (t[1] == 0)
          puts "skipping from to_index=#{to_index} to #{to_index + 1}" if do_puts
          to_index += 1
          if (to_index >= @to_file.phrase_length_array.length)
            puts "---breaking out of inside loop" if do_puts
            break
          else 
            t = @to_file.phrase_length_array[to_index]          
          end
        else 
          puts "skipping from from_index=#{from_index} to #{from_index + 1}" if do_puts
          from_index += 1
          if (from_index >= @from_file.phrase_length_array.length)
            puts "---breaking out of inside loop" if do_puts
            break
          else 
            t = @from_file.phrase_length_array[from_index]
          end
          puts "skipping from to_index=#{to_index} to #{to_index + 1}" if do_puts
          to_index += 1
          if (to_index >= @to_file.phrase_length_array.length)
            puts "---breaking out of inside loop" if do_puts
            break
          else 
            t = @to_file.phrase_length_array[to_index]          
          end          
        end
      end
      puts "#{from_index}:  #{f}     #{to_index}:  #{t}" if do_puts
        
      @aligned_pairs << [f[2], t[2], 'TEXT', result]
      puts "@aligned_pairs:  #{f[2]} -- #{t[2]}, 'TEXT', #{result}" if do_puts
      from_index += 1
      to_index += 1
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
