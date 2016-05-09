json.array! @trade do |p|
  json.name           p.vip_package.vip.name
  json.actived        p.actived
  json.active_date    p.active_date.strftime('%d-%m-%Y')
  json.expiry_date    p.expiry_date.strftime('%d-%m-%Y')
end