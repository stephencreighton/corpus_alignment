#!/usr/bin/ruby
require_relative 'comparator'

fromfile = XFile.new ARGV[0]
#fromfile.inspect
#File.open(fromfile.filename + '.out', 'w') { |file| file.write(fromfile.source_phrases) }

tofile = XFile.new ARGV[1]
#tofile.inspect
#File.open(tofile.filename + '.out', 'w') { |file| file.write(tofile.source_raw) }

comp = Comparator.new(fromfile, tofile)
x = (comp.aligned_pairs_from_char_count * 100.0) / (fromfile.char_count * 1.0)
puts "Aligned #{x.round}% (#{ comp.aligned_pairs_from_char_count} / #{fromfile.char_count}) (of #{fromfile.filename})"
#puts "Confidence Score = #{comp.generate_confidence_score}"
