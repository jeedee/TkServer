require '../config.rb'

ActiveRecord::Schema.define do
    create_table :users, :primary_key => :id do |table|
        table.column :id, :integer
        table.column :username, :string
        table.column :password, :string
        table.column :username, :string
        table.column :face, :integer
        table.column :hairstyle, :integer
        table.column :face_color, :integer
        table.column :hair_color, :integer
        table.column :gender, :integer
        table.column :totem, :integer
        table.column :speed, :integer, :default => 80
        table.column :facing, :integer, :default => 2
    end
end