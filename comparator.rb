require_relative 'xfile.rb'

class Comparator
  attr_reader :aligned_pairs, :overall_confidence_score
  attr_accessor :text_expansion_factor, :from_file, :to_file

  def initialize(from_file, to_file)
    puts "\nComparing #{from_file.filename}, #{to_file.filename}"
    @from_file = from_file
    @to_file = to_file
    @overall_confidence_score = 0
    @aligned_pairs = []
    @text_expansion_factor = 1.20  # en to fr - will want to read this in from file?
    compare_structures
  end

  def compare_structures
    (0..@from_file.phrase_length_array.length).each do |i|
#      if @from_file.phrase_length_array
      puts "\n#{i}:  #{@from_file.phrase_length_array[i]}   #{@to_file.phrase_length_array[i]}"
      x = compare_pair(from_file.phrase_length_array[i], to_file.phrase_length_array[i])
      puts "\t#{x}"
    end
  end

  def compare_pair(from_item, to_item)
#    delta = to_item[1] / from_item[1].to_f
    puts "\t-- #{from_item}   #{to_item}   #{from_item[1] * (1-((@text_expansion_factor-1)*6))}    #{from_item[1] * (1-(@text_expansion_factor-1))}
       #{from_item[1]*@text_expansion_factor}   #{from_item[1] * (1+((@text_expansion_factor-1)*6))}"
    # will definitely want to redo this...this just gives rough values based on standard deviations
    if ( (to_item[1] > (from_item[1] * (1-(@text_expansion_factor-1)))) && (to_item[1] < (from_item[1] * @text_expansion_factor)) )
      1.0
    elsif ( (to_item[1] > (from_item[1] * (1-((@text_expansion_factor-1)*2)))) && (to_item[1] < (from_item[1] * (1+((@text_expansion_factor-1)*2)))) )
      0.5
    elsif ( (to_item[1] > (from_item[1] * (1-((@text_expansion_factor-1)*6)))) && (to_item[1] < (from_item[1] * (1+((@text_expansion_factor-1)*6)))) )
      0.25
    else
      0.0
    end
 end
    
  def generate_confidence_score
    @to_file.word_count / (@from_file.word_count * @text_expansion_factor)
  end
end
