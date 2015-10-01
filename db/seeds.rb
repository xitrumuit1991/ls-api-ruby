puts "Seed sample DB for Admin"
Admin.delete_all
file_to_load  = Rails.root + 'db/seed/admin.yml'
admin   = YAML::load( File.open( file_to_load ) )
admin.each_pair do |key,u|
  s = Admin.find_by_email(u['email'])
  unless s
    c = Admin.create(u)
  end
end

puts "Seed sample DB for UserLevel"
UserLevel.delete_all
50.times do |n|
  UserLevel.create!(level: n,
                    min_exp: n * 10,
                    heart_per_day: n + 5,
                    grade: n )
end

puts "Seed sample DB for BctType"
BctType.delete_all
5.times do |n|
  BctType.create!(title: "Broadcaster type #{n}",
                  slug: "broadcaster-type-#{n}",
                  description: Faker::Lorem.paragraph(2, false, 4) )
end

puts "Seed sample DB for BroadcasterLevel"
BroadcasterLevel.delete_all
50.times do |n|
  BroadcasterLevel.create!(level: n,
                           min_heart: n * 10,
                           grade: n )
end


puts "Seed sample DB for RoomType"
RoomType.delete_all
5.times do |n|
  RoomType.create!(title: "Room type #{n}",
                   slug: "room-type-#{n}",
                   description: Faker::Lorem.paragraph(2, false, 4) )
end

puts "Seed sample DB for User"
User.delete_all
10.times do |n|
  a = "user name #{n}";
  User.create!(email: Faker::Internet.email(a),
               username: "username_#{n}",
               password: '123456',
               name: a,
               birthday: Faker::Time.between(DateTime.now.to_date - 7300, DateTime.now.to_date).to_date,
               gender: ['nam', 'nu'].sample,
               address: Faker::Address.street_address,
               phone: Faker::PhoneNumber.phone_number,
               fb_id: '',
               gp_id: '',
               remote_avatar_url: Faker::Avatar.image,
               remote_cover_url: Faker::Avatar.image,
               money: 1000,
               user_exp: 0,
               active_code: SecureRandom.hex(3).upcase,
               actived: true,
               active_date: DateTime.now,
               is_broadcaster: false,
               no_heart: 0,
               is_banned: false,
               user_level_id: UserLevel.first.id)
end

puts "Seed sample DB for Gift"
Gift.delete_all
18.times do |n|
  Gift.create!(name: Faker::Name.last_name,
               remote_image_url: Faker::Avatar.image("gift-#{n}", "100x100", "jpg"),
               price: Random.rand(1..10),
               discount: 0 )
end

puts "Seed sample DB for Action"
RoomAction.delete_all
18.times do |n|
  RoomAction.create!(name: Faker::Name.last_name,
                 price: 1,
                 remote_image_url: Faker::Avatar.image("action-#{n}", "100x100", "jpg"),
                 max_vote: 10,
                 discount: 0 )
end