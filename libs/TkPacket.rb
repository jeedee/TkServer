class TkPacket
  DELIMITER = 170
  attr_accessor :delimiter, :length, :id, :data, :decrypted_data
  
  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
  
  def self.parse_char(packet)
    attributes = Hash.new
    packet.unpack("H*").each do |packet|
      return parse(packet)
    end
  end
  
  # Parse a string of hex with no spaces
  def self.parse(b)
    b.gsub!(' ', '')

    attributes = Hash.new
    
    attributes[:delimiter] = b[0,2]
    attributes[:length] = (b[2,2].to_i(16) + b[4,2].to_i(16))
    attributes[:id] = b[6,2]
    attributes[:increment] = b[8,2]

    # Data
    data = Array.new
    data_raw = b[10..b.length]

    # Parse HEX data to place in an array
    data_raw.scan(/../).each do |h|
      data << h
    end
  
    attributes[:data] = data

    return self.new(attributes)
  end
  
  def create!
    packet = Array.new
    packet << DELIMITER
    packet = packet + self.length
    packet << self.id.hex
    packet << self.increment
    packet = packet + @data

    return packet.map{|b| b.chr}
  end
  
  # Data accessor for automatically encrypting and setting the length
  def set_data(data)
    data = data.pack('c*') if data.class == Array
    raise "No increment has been set. It is necessary to encrypt the data" if @increment.nil?
    
    # Set the length
    self.length = data.length+2
    
    # Save the decrypted message
    @decrypted_data = @data
    
    # Set the message
    @data = TkCrypt::encrypt(data, self.increment)
  end
    
  def id
    @id
  end
  
  def increment
    @increment.hex
  end
  
  def length
    @length.to_i if @length.class == 'String'
    
    # Return as an array of bytes
    return ("%04X" % @length).scan(/../).map{|c| c.hex}
  end
  
  def dump
    pp self
  end
  
  def dump_as_string
    self.map{|b| b = b.chr}
  end
  
  def dump_as_byte
    self.map{|b| b = b.hex}
  end
  
  def decrypted_data
    @decrypted_data ||= TkCrypt.decrypt(@data, self.increment)
  end

end
