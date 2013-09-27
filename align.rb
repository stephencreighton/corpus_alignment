#!/usr/bin/ruby
require_relative 'comparator'

# expected params:  from_filename, to_filename [,--metrics]
puts "#{ARGV[2]}"
fromfile = XFile.new ARGV[0]
if (ARGV[2] == "--metrics")
  fromfile.inspect
end

tofile = XFile.new ARGV[1]
if (ARGV[2] == "--metrics")
  tofile.inspect
end

comp = Comparator.new(fromfile, tofile)
comp.inspect
