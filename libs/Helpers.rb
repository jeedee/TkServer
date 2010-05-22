class String  
  def to_hex
    # removed .unpack('U')
    self[0].to_s(16)
  end
end

class Array
  def hex_to_string
    self.map { |c| c.to_s(16).hex.chr }.join
  end
  
  def dump_string
    self.map{|b| b = b.chr}
  end
  
  def bytes_to_hex
    self.map{|b| b = b.to_s(16).rjust(2, '0')}.join(" ")
  end
end

class Fixnum
  def to_16be
    array = Array.new
    [self & 0xFFFF].pack("n").each_byte{ |b| array << b}
    array
  end
  
  def to_32be
    array = Array.new
    [self & 0xFFFFFFFF].pack("N").each_byte{ |b| array << b}
    array
  end
  
end