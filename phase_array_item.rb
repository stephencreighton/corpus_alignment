class PhraseArrayItem
  attr_reader :array_index, :length, :phrase
  def initialize(array_index, char_offset_into_raw_file, phrase_length, phrase)
    @array_index = array_index
    @offset = char_offset_into_raw_file
    @length = phrase_length
    @phrase = phrase
  end
end

