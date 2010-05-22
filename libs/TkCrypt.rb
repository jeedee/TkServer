module TkCrypt
  KEY = ['4E', '65', '78', '6F', '6E', '49', '6E', '63', '2E']
  
  # Encrypt takes a string and return a HEX
  def self.encrypt(packet, increment)
    cryptroutine( ( packet.scan(/./).map { |c| c.to_hex.hex } ), increment)
  end
  
  # Decrypt takes an array of HEX and returns an array of hex
  def self.decrypt(packet, increment)
    cryptroutine(packet.map{ |h| h.hex}, increment)
  end
  
  # Encryption routine
  def self.cryptroutine(packet, increment)

    0.upto(packet.length-1) do |i|
      packet[i] = ( packet[i] ^ (KEY[i % 9].hex) )
      packet[i] = (packet[i] ^ (i/9) )
      packet[i] = (packet[i] ^ increment) unless i/9 == increment 
    end

    return packet
  end
end