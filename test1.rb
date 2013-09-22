
@from_raw = File.read(ARGV[0]) 
@to_raw = File.read(ARGV[1])



File.open('out1.txt', 'w') { |file| file.write(@from_raw) }
File.open('out2.txt', 'w') { |file| file.write(@to_raw) }