# LIVESTAR API
*version 1.0*

## Authorizations
- Namespace URL: **/auth**

### Login
- URI: **/login**
- Method: **POST**
- Header:
	+ Content-Type: application/json
- Request:
```
{
	"email": "peter@gmail.com",
	"password": "******"
}
```
- Response:
	+ status: **200** *(OK)*, **400** *(Bad request)*, **401** *(Unauthorize)*
	+ body: ```{"token": "this-is-jwt-token"}```

### Register
- URI: **/register**
- Method: **POST**
- Header:
	+ Content-Type: application/json
- Request:
```
{
	"email": "peter@gmail.com",
	"password": "*********"
}
```

### Register by Facebook
- URI: **/fb-register**
- Method: **POST**
- Header:
	+ Content-Type: application/json
- Request:
```
{
	"email": "peter@gmail.com",
	"access_token": "this-is-facebook-access-token"
}
```
- Response:
	+ status: **200** *(OK)*, **400** *(Bad request)*, **401** *(Unauthorize)*
	+ body: ```{"token": "this-is-jwt-token"}```

### Register by Google Plus
- URI: **/fb-register**
- Method: **POST**
- Header:
	+ Content-Type: application/json
- Request:
```
{
	"email": "peter@gmail.com",
	"access_token": "this-is-facebook-access-token"
}
```
- Response:
	+ status: **200** *(OK)*, **400** *(Bad request)*, **401** *(Unauthorize)*
	+ body: ```{"token": "this-is-jwt-token"}```

### Logout
- URI: **/logout**
- Method: **GET**
- Header:
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status **200** *(OK)*, **401** *(Unauthorize)*

### Forgot password (reset password)
- URI: **/forgot**
- Method: **POST**
- Header:
	+ Content-Type: application/json
- Request: ```{ "email": "alex@email.com" }```
- Response:
	+ status **200** *(OK)*, **400** *(Bad request)*, **404** *(Not found)*

### Forgot code (update forgot code to reset password)
- URI: **/update-forgot-code**
- Method: **POST**
- Header:
	+ Content-Type: application/json
- Request: ```{ "email": "alex@email.com", "forgot_code" : "HIJKLMNO" }```
- Response:
	+ status **200** *(OK)*, **400** *(Bad request)*, **404** *(User Not found)*

### Reset Password (update forgot code to reset password)
- URI: **/reset-password**
- Method: **POST**
- Header:
	+ Content-Type: application/json
- Request: ```{"forgot_code" : "HIJKLMNO" }```
- Response:
	+ status **200** *(OK)*, **404** *(User Not found)*

### Change password
- URI: **/change**
- Method: **POST**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request:
```
{
	"old_password": "aaaaaaaa",
	"password": "bbbbbbb"
}
```
- Response:
	+ status: **200** *(OK)*, **400** *(Bad request)*, **401** *(Unauthorize)*
	+ body: ```{"token": "this-is-jwt-token"}```

### Verify token
- URI: **/verify-token**
- Method: **POST**
- Header:
	+ Content-Type: application/json
- Request:
```
{
	"email": "peter@gmail.com",
	"token": "this-is-jwt-token"
}
```
- Response:
	+ status: **200**, **400**

## Rooms
- Namespace URL: **/rooms**

### Get on-air rooms
- URI: **/on-air**
- Method: **GET**
- Header
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request
	+ page: page number
- Resoponse
	+ status: **200**, **400**,  **401**
	+ errors:
		+ status 400: ```{error: "an awnsome fucking error"}```
	+ body (status: 200):
```
    {
        'totalPage':4,
        'rooms':[
          {
            "id": 10,
            "title": "Rosanna Paucek",
            "thumb": "http://localhost:3000/uploads/room/thumb/10/thumb_nature.jpeg",
            "broadcaster": {
              "id": 10,
              "name": "Rosanna Paucek",
              "avatar": "http://localhost:3000/api/v1/users/10/avatar",
              "heart": 0,
              "exp": 0,
              "level": 0
            }
          },
          {
            "id": 10,
            "title": "Rosanna Paucek",
            "thumb": "http://localhost:3000/uploads/room/thumb/10/thumb_nature.jpeg",
            "broadcaster": {
              "id": 10,
              "name": "Rosanna Paucek",
              "avatar": "http://localhost:3000/api/v1/users/10/avatar",
              "heart": 0,
              "exp": 0,
              "level": 0
            }
          },
          ...
          ...
        ]
```

### Get coming soon rooms
- URI: **/coming-soon**
- Method: **GET**
- Header
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request
	+ cat: room category id
	+ page: page number
- Response
	+ status: **200**, **400**,  **401**
	+ errors:
		+ status 400: ```{error: "an awnsome fucking error"}```
	+ body (status: 200):
```
	{
	  "totalPage": 1,
      "rooms":[
          {
            "id": 1,
            "title": "new room title",
            "thumb": "http://localhost:3000/uploads/room/thumb/1/thumb_nature.jpeg",
            "date": "25/11",
            "start": "13:46",
            "broadcaster": {
              "id": 1,
              "name": "Ansley Morissette",
              "avatar": "http://localhost:3000/api/v1/users/1/avatar",
              "heart": 0,
              "exp": 0,
              "level": 0
          },
          {
            "id": 1,
            "title": "new room title",
            "thumb": "http://localhost:3000/uploads/room/thumb/1/thumb_nature.jpeg",
            "date": "25/11",
            "start": "13:46",
            "broadcaster": {
              "id": 1,
              "name": "Ansley Morissette",
              "avatar": "http://localhost:3000/api/v1/users/1/avatar",
              "heart": 0,
              "exp": 0,
              "level": 0
          },
          ....
          ....
      ]
    },

```

### Get room detail
- URI: **/room-id**
- Method: **GET**
- Header
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response
	+ status: **200**, **400**, **404**, **401**
	+ errors:
		+ status 400: ```{error: "an awnsome fucking error"}```
	+ body (status: 200):
```
	{
      "id": 1,
      "title": "new room title",
      "slug": "ansley_morissette",
      "thumb": "/uploads/room/thumb/1/thumb_nature.jpeg",
      "thumb_mb": "/uploads/room/thumb/1/thumb_mb_nature.jpeg",
      "background": null,
      "is_privated": false,
      "on_air": false,
      "link_stream": "rtmp://210.245.18.154:80/livemix/android/playlist.m3u8",
      "broadcaster": {
        "broadcaster_id": 1,
        "user_id": 1,
        "avatar": "http://localhost:3000/api/v1/users/1/avatar",
        "name": "Ansley Morissette",
        "heart": 0,
        "exp": 0,
        "percent": 0,
        "level": 0,
        "facebook": null,
        "twitter": null,
        "instagram": null,
        "status": "this is my update status",
        "isFollow": true
      },
      "schedules": [
        {
          "date": "20/11/2015",
          "start": "13:46",
          "end": "15:46"
        },
        ...
        ...
      ]
    }
```

### Update room settings
- URI: **/**
- Method: **PUT**
- Header
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request
```
{
	title: "new room title",
	cat: 2, // New category id
}
```
- Resoponse
	+ status: **200**, **400**, **404**, **401**

### Upload thumb
- URI: **/thumb**
- Method: **POST** / **PUT**
- Header
	+ Content-Type: multipart/form-data
	+ Authorization: Token token="this-is-jwt-token"
- Request:
	+ thumb: image/jpeg
- Resoponse
	+ status: **200**, **400**, **404**, **401**

### Upload backgroud
- URI: **/backgound**
- Method: **POST**
- Header
	+ Content-Type: multipart/form-data
	+ Authorization: Token token="this-is-jwt-token"
- Request:
	+ background: image/jpeg
- Response
	+ status: **200**, **400**, **404**, **401**

### Change backgroud
- URI: **/backgound**
- Method: **PUT**
- Header
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request: ```{ background: "new filename" }```
- Resoponse
	+ status: **200**, **400**, **404**, **401**


### Update show schedule
- URI: **/schedule**
- Method: **POST**
- Header
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request:
```
{
	schedule: [
		{"start":"01/11/2015 00:00:00", "end":"30/11/2015 00:00:00"},
		{"start":"01/12/2015 00:00:00", "end":"30/12/2015 00:00:00"},
		...
	]
}
```
- Resoponse
	+ status: **200**, **400**, **404**, **401**

### Get gifts
- URI: **/gifts**
- Method: **GET**
- Header
    + Content-Type: application/json
    + Authorization: Token token="this-is-jwt-token"
- Response
    + status: **200**
    + body (status: 200):
```
    [
      {
        "id": 1,
        "name": "Donnelly",
        "image": "http://localhost:3000//uploads/room_action/image/1/square_action-0.jpg",
        "price": 1,
        "max_vote": 10,
        "voted": 0,
        "percent": 0,
        "discount": 0
      },
      {
        "id": 2,
        "name": "Stamm",
        "image": "http://localhost:3000//uploads/room_action/image/2/square_action-1.jpg",
        "price": 1,
        "max_vote": 10,
        "voted": 0,
        "percent": 0,
        "discount": 0
      },
    ...
    ...
    ...
]
```

### Get actions
- URI: **/actions**
- Method: **GET**
- Header
    + Content-Type: application/json
    + Authorization: Token token="this-is-jwt-token"
- Response
    + status: **200**
    + body (status: 200):
```
    [
      {
        "id": 1,
        "name": "Dicki",
        "image": "http://localhost:3000//uploads/gift/image/1/square_gift-0.jpg",
        "price": 1,
        "discount": 0
      },
      {
        "id": 2,
        "name": "Johnson",
        "image": "http://localhost:3000//uploads/gift/image/2/square_gift-1.jpg",
        "price": 4,
        "discount": 0
      },
     ...
     ...
     ...
    ]
```

### Get lounges
- URI: **/lounges**
- Method: **GET**
- Header
    + Content-Type: application/json
    + Authorization: Token token="this-is-jwt-token"
- Response
    + status: **200**
    + body (status: 200):
```
    [
      {
        "user": {
          "id": 0,
          "name": ""
        },
        "cost": 0
      },
      ...
      ...
    ]
```

## Broadcasters
- Namespace URL: **/broadcasters**

### Broadcaster Revcived Items,
- URI: **/revcived-items**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**
	+ body:
```
{
	id: 321,
	name: "abc",
	thumb: "http://cdn.domain.com/user/user-id/avatar.jpg",
	quantity: 1000,
	cost: 100,
	total_cost: 100000,
	created_at: "2015-10-06 00:00:00"
}
```

### Get profile
- URI: **/broadcaster-id**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**, **404**, **401**
	+ body:
```
{
	  id: 8,
      name: "Marie Cummerata",
      fullname: "Marie Cummerata",
      username: "marie_cummerata",
      email: "marie.cummerata@hotmail.com",
      birthday: "2009-12-04",
      horoscope: "Bo cap",
      gender: "nam",
      address: "42966 Jude Village",
      phone: "281.837.2686",
      avatar: "http://localhost:3000/api/v1/users/8/avatar",
      cover: "http://localhost:3000/uploads/user/cover/8/banner_Cover_.jpeg",
      facebook: null,
      twitter: null,
      instagram: null,
      heart: 0,
      user_level: 1,
      broadcaster_level: 2,
      percent: 20,
      user_exp: 0,
      bct_exp: 0,
      description: "Illo sed aspernatur. Ad similique qui iusto corrupti molestias. Et sunt veritatis beatae sit possimus tempore aut.",
      status: null,
      photos: [ { id: 123123, link: "http://.../photo_1.jpg" }, ..],
      videos: [
            {
                id: 321654,
                thumb: "http://api.youtube.com/thumb/AbcXyZ",
                link: "http://youtube.com/AbcXyZ"
            },
            ...
      ],
      fans: [
        {
              "id": null,
              "name": "Rosario Oberbrunner",
              "vip": null,
              "username": "rosario.oberbrunner",
              "avatar": "http://localhost:3000/api/v1/users//avatar",
              "heart": 0,
              "money": null,
              "user_exp": 0,
              "level": 0
            },
        ...
        ...
      ]
}
```

### Post status
- URI: **/status**
- Method: **POST**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request: ```{ status: "this is my update status" }```
- Response:
	+ status: **201**, **400**, **401**

### Upload pictures
- URI: **/pictures**
- Method: **POST**
- Header:
	+ Content-Type: multipart/form-data
	+ Authorization: Token token="this-is-jwt-token"
- Request:
	+ pictures (array): image/jpeg
- Response:
	+ status: **401**
	+ body:
```
{
	photos: [ {link: "http://.../photo_1.jpg" }, {link: "http://.../photo_1.jpg" }, ..]
}
```

### Delete pictures
- URI: **/pictures**
- Method: **DELETE**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request:	```{ id :[ 123654, 654123 ] }```
- Response:
	+ status: **200**, **400**, **401**

### Create video
- URI: **/videos**
- Method: **POST**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request: ```[{ video: "http://youtube.com/AbcXyZ" }, ...]```
- Response:
	+ status: **201**, **400**, **401**

### Delete videos
- URI: **/videos**
- Method: **DELETE**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request:	```{ id :[ 123654, 654123 ] }```
- Response:
	+ status: **200**, **400**, **401**

### Follow / Unfollow
- URI: **/broadcaster-id/follow**
- Method: **PUT**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**, **404**, **401**
	+ body: ```{ status: 'Follow' // or "Unfollow" }```

### Get followed broadcasters
- URI: **/followed**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
[
    {
        "id": 18,
        "name": "Wisoky",
        "username": "Wisoky",
        "avatar": "http://localhost:3000/api/v1/users/18/avatar",
        "heart": 88,
        "user_exp": 8889546,
        "level": 12,
        "room_id": 5,
        "onair": true,
        "room_slug":room-2
    },
    {
        "id": 1,
        "name": "Danh Nguyen",
        "username": "vdnguyen",
        "avatar": "http://localhost:3000/api/v1/users/1/avatar",
        "heart": 99489,
        "user_exp": 14996585,
        "level": 19,
        "room_id": 3,
        "onair": false,
        "room_slug":room-3
        "schedule": {
            "date": "02/11",
            "start": "10:00"
        }
    },
    ...
]
```

### Search broadcasters
- URI: **/search?q=keyword**
- Method: **POST**
- Header:
	+ Content-Type: application/json
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
{
    totalPage: 3,
    broadcasters: [
        {
            "id": 18,
            "name": "Wisoky",
            "username": "Wisoky",
            "avatar": "http://localhost:3000/api/v1/users/18/avatar",
            "heart": 88,
            "user_exp": 8889546,
            "level": 12,
            "isFollow": true
            "room": {
              "id" : 1,
              "title": "bct-01",
              "slug" : "btc-01",
              "on_air" : true,
              "thumb" : "http://localhost:3000/api/v1/rooms/18/thumb",
              "thumb_mb": "http://localhost:3000/api/v1/rooms/18/thumb_mb",
            },
            "schedule": null
        },
        {
            "id": 18,
            "name": "Wisoky",
            "username": "Wisoky",
            "avatar": "http://localhost:3000/api/v1/users/18/avatar",
            "heart": 88,
            "user_exp": 8889546,
            "level": 12,
            "isFollow": true
            "room": null,
            "schedule": {
                "date": "02/11",
                "start": "10:00"
            }
        },
        ...
    ]
}
```

## Users
- Namespace URL: **/users**

### Expense records
- URI: **/expense-records**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**
	+ body:
```
{
	id: 321,
	name: "abc",
	thumb: "http://cdn.domain.com/user/user-id/avatar.jpg",
	quantity: 1000,
	cost: 100,
	total_cost: 100000,
	created_at: "2015-10-06 00:00:00"
}
```

### Active user
- URI: **/active**
- Method: **POST**
- Header:
	+ Content-Type: application/json
- Request:
```
{
	"email": "peter@gmail.com",
	"active_code": "AAAAAAA"
}
```
- Response:
	+ status: **200**, **400**


### Active user who registered by facebook, google plus
- URI: **/active-fb-gp**
- Method: **POST**
- Header:
	+ Content-Type: application/json
- Request:
```
{
	"email": "peter@gmail.com",
	"id": "AAAAAAA" //fb_id or gp_id
}
```
- Response:
	+ status: **200** *(OK)*, **400** *(Bad request)*

### Get user's profile
- URI: **/**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**, **404**, **401**
	+ body:
```
{
  "id": 1,
  "name": "Ansley Morissette",
  "username": "ansley.morissette",
  "email": "ansley_morissette@yahoo.com",
  "birthday": "2006-01-20",
  "gender": "nam",
  "address": "167 Montana Pass",
  "phone": "207-790-8731 x06816",
  "is_bct": true,
  "avatar": "http://localhost:3000/api/v1/users/1/avatar",
  "cover": "http://localhost:3000/uploads/user/cover/1/banner_Cover_.jpeg",
  "facebook": null,
  "twitter": null,
  "instagram": null,
  "heart": 0,
  "money": 1000,
  "user_exp": 0,
  "percent": 0,
  "user_level": 0
}
```

### Get user's public profile
- URI: **/:id**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**
	+ body:
```
{
	"id": 5,
      "name": "Ahmad Kris Jr.",
      "username": "jr.ahmad.kris",
      "email": "jr.kris.ahmad@yahoo.com",
      "birthday": "2010-12-20",
      "gender": "nam",
      "address": "6485 Kelsie Roads",
      "phone": "(855) 827-5667 x63308",
      "is_bct": true,
      "avatar": "http://localhost:3000/api/v1/users/5/avatar",
      "cover": "http://localhost:3000/uploads/user/cover/5/banner_Cover_.jpeg",
      "facebook": null,
      "twitter": null,
      "instagram": null,
      "heart": 0,
      "money": 1000,
      "user_exp": 0,
      "percent": 0,
      "user_level": 0,
	  photos: [ { id: 123123, link: "http://.../photo_1.jpg" }, ..],
	  videos: [
		{
			id: 321654,
			thumb: "http://api.youtube.com/thumb/AbcXyZ",
			link: "http://youtube.com/AbcXyZ"
		},
		...
	  ]
}
```

### Update user's profile
- URI: **/**
- Method: **PUT**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request:
```
{
	name: "Rainie Bui",
	nickname: "Zit"
	birthday: "09/10/1991",
	facebook-link: "http://fb.me/whatthefuck",
	instagram-link: "...",
	twitter: "...",
	description: "too long description..."
}
```
- Response:
	+ status: **200**, **400**, **404**, **401**

### Update avatar
- URI: **/avatar**
- Method: **PUT**
- Header:
	+ Content-Type: multipart/form-data
	+ Authorization: Token token="this-is-jwt-token"
- Request:
	+ avatar: image/jpeg
- Response:
	+ status: **201**, **400**, **401**

### Update cover
- URI: **/cover**
- Method: **PUT**
- Header:
	+ Content-Type: multipart/form-data
	+ Authorization: Token token="this-is-jwt-token"
- Request:
	+ cover: image/jpeg
- Response:
	+ status: **201**, **400**, **401**

### Get payment history
- URI: **/payments**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
	[
		{
			id: 123654789,
			created_at: "08/11/2015 20:10",
			amount: 20000,
			description: "this is some description"
		},
		...
	]
```

### Get trade history
- URI: **/trades**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
	[
		{
			id: 123654789,
			name: "Hoa hong",
			image: "http://../image-rose.png",
			created_at: "08/11/2015 20:10",
			cost: 2000,
			quantity: 10
			total: 20000,
		},
		...
	]
```

## Payment
- Namespace URL: **/payments**
### SMS 
*under construction*
- URI: **sms**
- Method: **GET**

### Mobile Card
*under construction*
- URI: **mobile-card**
- Method: **GET**

## System message (mail)
- Namespace URL: **/mails**

### Get user's mail
- URI: **/**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
	[
		{
			id: 123654789,
			from: "System",
			title: "Welcome to LiveStar",
			content: "This is welcome content",
			created_at: "08/11/2015 20:10"
		},
		...
	]
```

### Send system message (for admin only)
*under construction*

## Posters
- Namespace URL: **/slides**

### Get list slide page home
- URI: **/sliders**
- Method: **GET**
- Header:
	+ Content-Type: application/json
- Response:
	+ body:
```
[
	{
		id: 321,
		title: "Danh An Co",
		description: "Danh An Co la la la",
		sub_description: "Danh An Co +18",
		start_time: "15:20",
		link: "http://puresolutions.com.vn/",
		banner: "http://cdn.domain.com/broadcaters/bct-id/abc.jpg"
		thumb: "http://cdn.domain.com/broadcaters/bct-id/thumb_abc.jpg"
	},
	...
]
```

### Get list slide page home
- URI: **/posters**
- Method: **GET**
- Header:
	+ Content-Type: application/json
- Response:
	+ body:
```
[
	{
		id: 321,
		title: "Danh An Co",
		sub_title: "Danh An Co la la la",
		link: "http://puresolutions.com.vn/",
		thumb: "http://cdn.domain.com/broadcaters/bct-id/thumb_abc.jpg"
	},
	...
]
```


## Ranks
- Namespace URL: **/ranks**

### Get room's weekly rank
*under construction*

### Get featured broadcasters
- URI: **/featured-broadcaster**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
[
	{
		id: 321,
		name: "Rainie Bui",
		nickname: "Zit",
		avatar: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
		heart: 1020,
		exp: 1231231,
		level: 10
	},
	...
]
```

### Home Get featured broadcasters
- URI: **/home-featured-broadcaster**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
[
	{
		id: 321,
		name: "Rainie Bui",
		nickname: "Zit",
		avatar: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
		heart: 1020,
		exp: 1231231,
		level: 10
	},
	room:{
			id: 321654,
			name: "room so 1",
			on_air: "true/false",
			thumb: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
			thumb_mb: "http://cdn.domain.com/broadcaters/bct-id/mb_avatar.jpg"
		},
	videos: [
		{
			start: "2015-10-21 03:35:00",
			end: "2015-10-30 18:35:00"
		},
		...
	]
	...
]
```

### Room Get featured broadcasters
- URI: **/room-featured-broadcaster**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
[
	{
		id: 321,
		name: "Rainie Bui",
		nickname: "Zit",
		avatar: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
		heart: 1020,
		exp: 1231231,
		level: 10
	},
	...
]
```

### Get top broadcaster revcived heart
- URI: **/room-type**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ body:
```
[
	{
		id:				123
		title:			"Room ABC"
		slug:			"room-abc"
		description:	"Room AbC Room AbC"
	},
	...
]
```

### Get top broadcaster revcived heart
- URI: **/top-heart-broadcaster**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request:
	+ range: week, month, all (default: week)
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
[
	{
		id: 321,
		name: "Rainie Bui",
		avatar: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
		heart: 1020,
		exp: 1231231,
		level: 10
	},
	...
]
```

### Get top broadcaster level grow-up
- URI: **/top-level-grow-broadcaster**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request:
	+ range: week, month, all (default: week)
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
[
	{
		id: 321,
		name: "Rainie Bui",
		avatar: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
		heart: 1020,
		exp: 1231231,
		level: 10
	},
	...
]
```

### Get top broadcaster recived gift
- URI: **/top-gift-broadcaster**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request:
	+ range: week, month (default: week)
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
[
	{
		id: 321,
		name: "Rainie Bui",
		avatar: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
		total-money: 250000
	},
	...
]
```

### Get top user level grow-up
- URI: **/top-level-grow-user**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request:
	+ range: week, month, all (default: week)
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
[
	{
		id: 123,
		name: "Peter Nguyen",
		avatar: "http://cdn.domain.com/user/user-id/avatar.jpg",
		heart: 1020,
		exp: 1231231,
		level: 10
	},
	...
]
```

### Get top user send gift
- URI: **/top-gift-user**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request:
	+ range: week, month, all (default: week)
- Response:
	+ status: **200**, **400**, **401**
	+ body:
```
[
	{
		id: 123,
		name: "Peter Nguyen",
		avatar: "http://cdn.domain.com/user/user-id/avatar.jpg",
		total-money: 250000
	},
	...
]
```

### Get top user follow broadcaster
- URI: **/:id/top-fans**
- Method: **GET**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ body:
```
[
	{
		id: 123,
		name: "Peter Nguyen",
		username: "Peter Nguyen",
		avatar: "http://cdn.domain.com/user/user-id/avatar.jpg",
		heart: 250,
		money: 20000,
		user_exp: 123456,
		level: 19
	},
	...
]
```

## Live functions
- Namespace URL: **/live**

### Get user list

### Kick user

### Send message
- URI: **/send-message**
- Method: **POST**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request
```
{
	room_id: 123,
	message: 'send message'
}
```
- Response:
	+ status: **401**, **404**, **403**
	+ errors: 
	    + status 401: ```{error: "Unauthorized "}```
	    + status 403: ```{error: "Maybe you miss subscribe room or room not started "}```
	    + status 404: ```{error: "Room not found "}```
	
### Send screen text
- URI: **/send-screentext **
- Method: **POST**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request
```
{
	room_id: 123,
	message: 'send message'
}
```
- Response:
	+ status: **401**, **404**, **403**
	+ errors: 
	    + status 401: ```{error: "Unauthorized "}```
        + status 403: ```{error: "Maybe you miss subscribe room or room not started "}```
        + status 404: ```{error: "Room not found "}```

### Vote action
- URI: **/vote-action**
- Method: **POST**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request
    ```
    {
        room_id: 123,
        action_id: 123
    }
    ```
- Response:
	+ status: **401**, **403**, **404**, **400**
	+ errors: 
	    + status 401: ```{error: "Unauthorized "}```
	    + status 403: ```{error: "Maybe you miss subscribe room or room not started or action has been full"}```
	    + status 404: ```{error: "Action not found"}```
	    + status 400: ```{error: "Bad request"}```
	
### Done action
- URI: **/done-action**
- Method: **POST**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request
    ```
    {
        room_id: 123,
        action_id: 123
    }
    ```
- Response:
	+ status: **401**, **403**, **404**, **400**
	+ errors: 
	    + status 401: ```{error: "Unauthorized "}```
	    + status 403: ```{error: "Maybe you miss subscribe room or room not started or you is'nt broadcaster "}```
	    + status 404: ```{error: "Action not found"}```
	    + status 400: ```{error: "Action not full"}```
	
### Send gifts
- URI: **/send-gifts**
- Method: **POST**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request
    ```
    {
        room_id: 123,
        gift_id: 123,
        quantity: 123
    }
    ```
- Response:
	+ status: **401**, **403**, **404**, **400**
	+ errors: 
	    + status 401: ```{error: "Unauthorized "}```
	    + status 403: ```{error: "Maybe you miss subscribe room or room not started "}```
	    + status 404: ```{error: "gift not found"}```
	    + status 400: ```{error: "Action not full"}```

### Buy VIP lounge
- URI: **/buy-lounge  **
- Method: **POST**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request
    ```
    {
        room_id: 123,
        lounge: 123,
        cost: 123
    }
    ```
- Response:
	+ status: **401**, **404**, **400**
	+ errors: 
	    + status 401: ```{error: "Unauthorized "}```
	    + status 404: ```{error: "Invalid lounge index "}```
	    + status 400: ```{error: "Bad request or maybe you miss subscribe room or room not started or dont have enough money"}```

### Send heart
- URI: **/send-hearts **
- Method: **POST**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request
    ```
    {
        room_id: 123,
        hearts: 123
    }
    ```
- Response:
	+ status: **401**, **403**, **404**, **400**
	+ errors: 
	    + status 401: ```{error: "Unauthorized "}```
	    + status 403: ```{error: "Maybe you miss subscribe room or room not started or dont have enough heart "}```
	    + status 404: ```{error: "Room not found "}```
	    + status 400: ```{error: "Bad request "}```

### Start room
- URI: **/start-room  **
- Method: **POST**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request
    ```
    {
        room_id: 123
    }
    ```
- Response:
	+ status: **401**, **404**
	+ errors: 
	    + status 401: ```{error: "Unauthorized "}```
	    + status 404: ```{error: "Room not found "}```
	    
### End room
- URI: **/end-room  **
- Method: **POST**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Request
    ```
    {
        room_id: 123
    }
    ```
- Response:
	+ status: **401**, **404**
	+ errors: 
	    + status 401: ```{error: "Unauthorized "}```
	    + status 404: ```{error: "Room not found "}```

### Get curent rank

## Vip functions
- Namespace URL: **/vip**

### Buy vip packages
- URI: **/buy-vip**
- Method: **POST**
- Header:
  + Content-Type: application/json
  + Authorization: Token token="this-is-jwt-token"
- Request
```
{
  user_id: 123,
  vip_package_id: 321
}
```
- Response:
  + status: **401**, **200**, **404**
  + errors: 
      + status 401: ```{error: "Bạn chưa đăng nhập!"}```
      + status 404: ```{error: "Vip không tồn tại!"}```