json.idols @listUsers do |item|
  json.id			          item.id
  json.avatar	          "#{Settings.base_url}#{item.avatar.url}"
  json.avatar_w60h60    "#{Settings.base_url}#{item.avatar.url}"
  json.email            item.email
  json.name             item.name
  json.vip              item.vip
end