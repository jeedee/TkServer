module TkLogin
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
      when '02' then packet_verify_available  
      when '03' then packet_login
      when '04' then packet_new_account_info
      else p "Packet #{packet.id} is unkown"
    end
    
  end
  
  def send_message(message)
    messagebox = TkPacket.new({ :id => '02', :increment => '02'})
    message = "\xf" + message.length.chr + message + "\000"
    messagebox.set_data(message)
    send_data (messagebox.create!)
  end
  
  # Handle Packets
  
  def packet_new_account_info
    @user.face = @packet.decrypted_data.slice(1)
    @user.hairstyle = @packet.decrypted_data.slice(2)
    @user.face_color = @packet.decrypted_data.slice(3)
    @user.hair_color = @packet.decrypted_data.slice(4)
    @user.gender = @packet.decrypted_data.slice(5)
    @user.totem = @packet.decrypted_data.slice(7)   
    @user.save
    
    # Send the "Your account has been created" packet
    message = "Your are now ready to play, #{@user.username}. please do not give your password to anyone OR ELSE."
    messagebox = TkPacket.new({ :id => '02', :increment => '02'})
    message = "\000" + message.length.chr + message + "\000"
    messagebox.set_data(message)
    send_data (messagebox.create!)
    
  end
  
  # User verifies if the user is available for a new account
  def packet_verify_available
    decrypted = TkCrypt.decrypt(@packet.data, @packet.increment)

    # Parse user
    length_of_user = decrypted.slice(0)
    length_of_password = decrypted.slice((length_of_user)+1)
   
    username = decrypted.slice(1, length_of_user).hex_to_string
    password = decrypted.slice((length_of_user)+2, length_of_password).hex_to_string
    
    if username.length > 11
      send_message("This username is too long.")
      return
    end
    # if account available
    if User.find_by_username(username).nil?
      @user = User.create(:username => username, :password => password)
      send_data("\xAA\00\06\02\01\x4F\x64\x79\x6E")
    else
      send_message("This username is already taken, please pick a different one.")
    end

  end
  
  # User tries to log in
  def packet_login
    
    decrypted = TkCrypt.decrypt(@packet.data, @packet.increment)
    length_of_user = decrypted.slice(0)
    length_of_password = decrypted.slice((length_of_user)+1)
   
    username = decrypted.slice(1, length_of_user).hex_to_string
    password = decrypted.slice((length_of_user)+2, length_of_password).hex_to_string
    
    if User.find(:first, :conditions => {:username => username, :password => password}).nil?
      send_message("Your username or password is invalid, please try again.")
    else
      # Need to make this cleaner. For now, will use the game_host IP but will force port 2035. Sorry! Lazy! :)
      username = username.unpack("U*")
      game_ip = $GAME_HOST.split(".")
      
      send_data("\xAA\x00\x05\x02\x00\x4E\x65\x78")
      login_packet = [170, 0, 0, 3, game_ip[3].to_i, game_ip[2].to_i, game_ip[1].to_i, game_ip[0].to_i] + $GAME_PORT.to_16be + [23, 0, 9, 78, 101, 120, 111, 110, 73, 110, 99, 46]
      login_packet.push(username.length)
      login_packet = login_packet + username
      login_packet = login_packet + [0, 1, 18, 17, 0]
      login_packet[2] = login_packet.length - 3
      send_data(login_packet.map{|b| b = b.chr})
    end
    
  end
  
end
