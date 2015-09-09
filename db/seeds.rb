puts "Seed sample DB for Admin"
file_to_load  = Rails.root + 'db/seed/admin.yml'
admin   = YAML::load( File.open( file_to_load ) )
admin.each_pair do |key,u|
  s = Admin.find_by_email(u['email'])
  unless s
    c = Admin.create(u)
  end
end

puts "Seed sample DB for UserLevel"
20.times do |n|
  UserLevel.create!(level: n,
                    min_exp: Random.rand(1000000),
                    heart_per_day: n + 5,
                    grade: n )
end

puts "Seed sample DB for BctType"
20.times do |n|
  BctType.create!(title: Faker::Name.title,
                  slug: Faker::Lorem.sentence,
                  description: Faker::Lorem.paragraph(2, false, 4) )
end

puts "Seed sample DB for BroadcasterLevel"
20.times do |n|
  BroadcasterLevel.create!(level: n,
                           min_heart: Random.rand(1000000),
                           grade: n + Random.rand(100) )
end

puts "Seed sample DB for Vip"
20.times do |n|
  a = Faker::Name.name
  Vip.create!(name: a,
              code: a.downcase,
              image: Faker::Avatar.image,
              weight: Random.rand(100),
              no_char: Random.rand(1000),
              screen_text_time: Random.rand(100),
              screen_text_effect: Faker::Lorem.word,
              kick_level: Random.rand(10),
              clock_kick: Random.rand(10),
              clock_ads: [true, false].sample,
              exp_bonus: Random.rand(0.1...100.9) )
end

puts "Seed sample DB for RoomType"
20.times do |n|
  RoomType.create!(title: Faker::Name.title,
                   slug: Faker::Lorem.word,
                   description: Faker::Lorem.paragraph(2, false, 4) )
end

puts "Seed sample DB for VipPackage"
20.times do |n|
  a = Faker::Lorem.word
  VipPackage.create!(vip_id: rand(1...Vip.count),
                     name: a,
                     code: a.downcase,
                     no_day: Faker::Lorem.word,
                     price: Random.rand(1000000),
                     discount: Random.rand(0.1...100.9) )
end

puts "Seed sample DB for User"
20.times do |n|
  a = Faker::Name.last_name
  User.create!(email: Faker::Internet.email(a),
               username: a,
               password: '123456',
               name: a,
               birthday: Faker::Time.between(DateTime.now.to_date - 7300, DateTime.now.to_date).to_date,
               gender: ['nam', 'nu'].sample,
               address: Faker::Address.street_address,
               phone: Faker::PhoneNumber.phone_number,
               fb_id: '',
               gp_id: '',
               avatar: Faker::Avatar.image,
               cover: Faker::Lorem.sentence,
               money: Random.rand(10000000),
               user_exp: Random.rand(10000000),
               active_code: Faker::Address.zip_code,
               actived: [true, false].sample,
               active_date: Faker::Time.between(DateTime.now - 260000, DateTime.now),
               is_broadcaster: true,
               no_heart: Random.rand(100),
               is_banned: [true, false].sample,
               user_level_id: rand(1...UserLevel.count) )
end

puts "Seed sample DB for Broadcaster"
20.times do |n|
  Broadcaster.create!(user_id: rand(1...User.count),
                      bct_type_id: rand(1...BctType.count),
                      broadcaster_level_id: rand(1...BroadcasterLevel.count),
                      fullname: Faker::Name.name,
                      fb_link: '',
                      twitter_link: '',
                      instagram_link: '',
                      description: Faker::Lorem.paragraph(2, false, 4),
                      broadcaster_exp: Random.rand(10000000),
                      recived_heart: Random.rand(10000000) )
end

puts "Seed sample DB for UserFollowBct"
20.times do |n|
  UserFollowBct.create!(user_id: rand(1...User.count),
                        broadcaster_id: rand(1...Broadcaster.count) )
end

puts "Seed sample DB for UserHasVipPackage"
20.times do |n|
  UserHasVipPackage.create!(user_id: rand(1...User.count),
                            actived: [true, false].sample,
                            active_date: Faker::Time.between(DateTime.now - 260000, DateTime.now),
                            expiry_date: Faker::Time.between(DateTime.now , DateTime.now + 20000),
                            vip_package_id: rand(1...VipPackage.count) )
end

puts "Seed sample DB for Gift"
20.times do |n|
  Gift.create!(name: Faker::Name.last_name,
               price: Random.rand(1000000),
               discount: Random.rand(0.1...100.9) )
end

puts "Seed sample DB for Action"
20.times do |n|
  Action.create!(name: Faker::Name.last_name,
                 price: Random.rand(1000000),
                 max_vote: Random.rand(1000000),
                 discount: Random.rand(0.1...100.9) )
end

puts "Seed sample DB for Room"
20.times do |n|
  Room.create!(broadcaster_id: rand(1...Broadcaster.count),
               room_type_id: rand(1...RoomType.count),
               title: Faker::Name.title,
               is_privated: [true, false].sample,
               slug: Faker::Lorem.word )
end