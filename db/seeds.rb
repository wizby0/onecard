# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

pockercard_list = [["spade", "1"], ["diamond", "j"], ["heart", "q"], ["clover", "k"]]

pockercard_list.each_with_index do |pockercard_list,index|
  pockercard = Pockercard.new
  pockercard.shape = "#{pockercard_list[0]}"
  pockercard.number = "#{pockercard_list[1]}"
  
  pockercard.save!
end