# LIVESTAR DATABASE MODEL

## user_levels
```
level:integer
min_exp:integer
heart_per_day:integer
grade:integer
```

## bct_types
```
title
slug
description:text
```

## broadcaster_levels
```
level:integer
min_heart:integer
grade:integer
```

## vips
```
name
code
image
weight:integer
no_char:integer
screen_text_time:integer
screen_text_effect
kick_level:integer
clock_kick:integer
clock_ads:boolean
exp_bonus:float
```

## room_types
```
title
slug
description:text
```

## vip_packages
```
vip:references
name
code
no_day
price:integer
discount:float
```

## users
```
email
password_digest
username
name
birthday:date
gender
address
phone
fb_id
gp_id
avatar
cover
money:integer
user_exp:integer
active_code
actived:boolean
active_date:datetime
join_date:datetime
is_broadcaster:boolean
no_heart:integer
is_banned:boolean
user_level:references
```

## broadcasters
```
user:references
bct_type:references
broadcaster_level:references
fullname
fb_link
twitter_link
instagram_link
description:text
broadcaster_exp:integer
recived_heart:integer
```

## user_follow_bct
```
user:references
broadcaster:references
```

## bct_videos
```
broadcaster:references
video
```

## bct_images
```
broadcaster:references
image
```

## user_has_vip_packages
```
user:references
vip_package:references
actived:boolean
active_date:datetime
expiry_date:datetime
```

## gifts
```
name
image
price:integer
discount:float
```

## actions
```
name
image
price:integer
max_vote:integer
discount:float
```

## rooms
```
broadcaster:references
room_type:references
title
slug
thumb
background
is_privated:boolean
```