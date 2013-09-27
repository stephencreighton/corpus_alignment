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
puts "Aligned #{x.round}% (#{ comp.aligned_pairs_from_char_count} / #{fromfile.char_count} characters) (of #{fromfile.filename})"
puts "Confidence score for final aligned pairs:  #{(comp.aligned_pairs_cum_score / comp.aligned_pairs_index * 100).round(2)}"
#puts "Confidence Score = #{comp.generate_confidence_score}"
