json.array! @user.user_has_vip_packages do |p|
  json.name           p.vip_package.name
  json.actived        p.actived
  json.active_date    p.active_date
  json.expiry_date    p.expiry_date
end
