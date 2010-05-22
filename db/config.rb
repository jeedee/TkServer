require 'rubygems'
require 'active_record'
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database  => "#{File.dirname(__FILE__)}/database.db"
)