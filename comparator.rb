require_relative 'xfile.rb'

class Comparator
  attr_reader :aligned_pairs, :overall_confidence_score
  attr_accessor :text_expansion_factor, :file1, :file2

  def initialize(file1, file2)
    puts "\nComparing #{file1.filename}, #{file2.filename}"
    @file1 = file1
    @file2 = file2
    @overall_confidence_score = 0
    @aligned_pairs = []
    @text_expansion_factor = 1.20  # en to fr - will want to read this in from file?
    compare_structures
  end

  def compare_structures
#    @file1.phrase_length_array.each do |i in 0..@file1.phrase_length_array.length|
    (0..@file1.phrase_length_array.length).each do |i|
#      if @file1.phrase_length_array
      puts "\n#{i}:  #{@file1.phrase_length_array[i]}   #{@file2.phrase_length_array[i]}"
    end
  end
  
  def generate_confidence_score
    @file2.word_count / (@file1.word_count * @text_expansion_factor)
  end
end
