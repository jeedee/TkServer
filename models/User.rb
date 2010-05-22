# create your AR class
class User < ActiveRecord::Base
  attr_accessor :socket
  
  def initialize
    @socket = nil
  end
end
