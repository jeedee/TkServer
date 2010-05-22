require 'rubygems'
require 'pp'
require 'eventmachine'
require 'base64'

# Database setup
require 'active_record'
require 'db/config.rb'
Dir[File.dirname(__FILE__) + '/db/models/*.rb'].each {|file| require file }

# Require libs & helpers
Dir[File.dirname(__FILE__) + '/libs/*.rb'].each {|file| require file }

$LOGIN_HOST = '192.168.1.2'
$LOGIN_PORT = 2000

$GAME_HOST = '192.168.1.2'
$GAME_PORT = 2035
class TkLoginServer < EventMachine::Connection
  include TkLogin
  
  def initialize
    
  end
  
  def post_init
    puts "A user connected"
 
    # Send the welcome packet
    send_data "\xAA\x00\x13\x7E\x1B\x43\x4F\x4E\x4E\x45\x43\x54\x45\x44\x20\x53\x45\x52\x56\x45\x52\x0A"
  end

  def receive_data data
    parse_packet TkPacket.parse_char(data)
  end
 
end

 EventMachine::run {
   EventMachine::start_server $LOGIN_HOST, $LOGIN_PORT, TkLoginServer
   puts 'Running TKServer [Login]'
 }