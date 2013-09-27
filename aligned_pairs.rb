class AlignedPairsArrayItem
  attr_reader :array_index, :from_phrase, :to_phrase, :type, :score  # where type = 'TITLE' | 'TEXT'

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

class AlignedPairsArray
  attr_reader :aligned_pairs, :aligned_pairs_index, :aligned_pairs_from_char_count, :aligned_pairs_cum_score, :overall_confidence_score

  def initialize
    @aligned_pairs = []
    @aligned_pairs_index = 0
    @aligned_pairs_from_char_count = 0
    @aligned_pairs_cum_score = 0    
  end  

  def add(from_phrase, to_phrase, type, score)
    do_puts = false
    @aligned_pairs << AlignedPairsArrayItem.new(@aligned_pairs_index, from_phrase, to_phrase, type, score)
    puts "@aligned_pairs[#{@aligned_pairs_index}]:  #{from_phrase} -- #{to_phrase}, #{type}, #{score}"  if do_puts
    @aligned_pairs_cum_score += score
    @aligned_pairs_from_char_count += from_phrase.length
    @aligned_pairs_index += 1
  end

  def inspect
    s = ""
    (0..@aligned_pairs_index-1).each do |x|
      a = @aligned_pairs[x]
      s << "\n[#{x}]:  #{a.from_phrase} --> #{a.to_phrase}, #{a.type}, #{a.score}" 
    end
    s
  end
end
