puts "Admin"
file_to_load  = Rails.root + 'db/seed/admin.yml'
admin   = YAML::load( File.open( file_to_load ) )
admin.each_pair do |key,u|
  s = Admin.find_by_email(u['email'])
  unless s
    c = Admin.create(u)
  end
end