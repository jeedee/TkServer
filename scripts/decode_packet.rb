Dir[File.dirname(__FILE__) + '/../libs/*.rb'].each {|file| require file }
require 'pp'

# Someone appears on the map

#p [0, 9, 0, 5, 2, 0, 16, 47, 78, 0, 1, 0, 0, 0, 80, 0, 206, 33, 0, 0, 0, 0, 0, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 8, 115, 104, 114, 105, 109, 112, 98, 111, 0].bytes_to_hex
raw_packet = "AA 00 0E 05 03 4D B3 18 30 6D 4A 6D 62 2D 4C 67 7A"

packet = TkPacket.parse(raw_packet)
p packet.decrypted_data.each{|c| p c}

pp packet