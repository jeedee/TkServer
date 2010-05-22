module TkGame
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    #class method
  end
  
  def parse_packet(packet)
    
    # Make it accessible to everyone
    @packet = packet
    case packet.id
      when '10' then welcome_packet
      when '13' then hit
      when '32' then move
      else handle_unknown
    end
    
  end
  
  def handle_unknown
    print "------------------------\n"
    p "ID: #{@packet.id}"
    p @packet.decrypted_data
    @packet.decrypted_data.each{|d| print "#{d.to_s(16).rjust(2, '0')} "}
    print "\n------------------------\n"
  end
  
  def send_message(message)
    messagebox = TkPacket.new({ :id => '02', :increment => '02'})
    message = "\xf" + message.length.chr + message + "\000"
    messagebox.set_data(message)
    send_data (messagebox.create!)
  end
  
  # Handle Packets
  def welcome_packet
    data = @packet.data
    
    user_length = data.slice(10).hex.to_i
    user_name = data.slice(11, user_length).map{|c| c.hex.chr}.to_s
    
    user = User.find_by_username(user_name)
    user.socket = self
    self.user = user
    
    # Add to the list of users
    $USERS.merge!({user.username.downcase => user})
    
    
   relative_coords = TkPacket.new({:id => '04', :increment => '02'})
   relative_coords.set_data([0, 1, 0, 3, 0, 2, 0, 3])
   send_data(relative_coords.create!)
    
    # Create the user on screen
    create_user = TkPacket.new({:id => '33', :increment => '02'})
    
    packet_data = [0, 1, 0, 3, user.facing, 0, 213, 99, 92, 0, 0, 0, 0, 0, user.speed, 0]
    packet_data = packet_data + [user.face, user.hairstyle, user.hair_color, user.face_color, 0] 
    
    # Body
    packet_data = packet_data + 29.to_16be + [0]

    # Weapon, weapon color ; 
    packet_data = packet_data + 0.to_16be + [0]
    
    # Shield, shield color
    packet_data = packet_data + 0.to_16be + [0]

    # TODO ?, ??
    packet_data = packet_data + 29.to_16be + [0]
    
    # Face accessory, face acc. color
    packet_data = packet_data + 0.to_16be + [0]
    
    # Head accessory, head acc. color ?
    packet_data = packet_data + 0.to_16be + [0]
    
    # Beard, beard color 
    packet_data = packet_data + 0.to_16be + [0]
    
    packet_data = packet_data + [255, 255, 255, 255, 255, 0, 0, 0, 0, 0]
    packet_data << user_name.length
    packet_data = packet_data + (user_name.bytes.to_a + [0])
    create_user.set_data(packet_data)
    send_data(create_user.create!)
    
    new_user = TkPacket.new({:id => '33', :increment => '02'})
    data = [0, 9, 0, 5, 2, 0, 16, 47, 78, 0, 1, 0, 0, 0, 80, 0, 206, 33, 0, 0, 0, 0, 0, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 8, 115, 104, 114, 105, 109, 112, 98, 111, 0]
    new_user.set_data(data)
    send_data(new_user.create!)
    
  end
  
  def hit
   #p "Trying to remove"
   #remove_user = TkPacket.new({:id => '0C', :increment => '02'})
   #remove_user.set_data([0,16,47,78,0])
   #send_data(remove_user.create!)
    
    move_user = TkPacket.new({:id => '0C', :increment => '02'})
    move_user.set_data([0,16,47,78] + 9.to_16be + 5.to_16be + [03,00])
    send_data(move_user.create!)
  end
  
  def move
    p "Move"
    move_user = TkPacket.new({:id => '0C', :increment => '02'})
    move_user.set_data([0,213,99,92] + 1.to_16be + 3.to_16be + [02,00])
    send_data(move_user.create!)
  end
  
end
