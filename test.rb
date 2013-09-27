#!/usr/bin/ruby
require_relative 'comparator'

fromfile = XFile.new ARGV[0]
#fromfile.inspect
#File.open(fromfile.filename + '.out', 'w') { |file| file.write(fromfile.source_phrases) }

tofile = XFile.new ARGV[1]
#tofile.inspect
#File.open(tofile.filename + '.out', 'w') { |file| file.write(tofile.source_raw) }

comp = Comparator.new(fromfile, tofile)
comp.inspect
