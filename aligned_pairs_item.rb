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