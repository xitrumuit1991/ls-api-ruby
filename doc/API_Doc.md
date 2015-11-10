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
		id: 123,
		title: "room's title",
		thumb: "http://cdn.domain.com/rooms/room-id/thumb.jpg"
		broadcater: {
			id: 321,
			name: "Rainie Bui",
			heart: 1020,
			exp: 12312,
			level: 10
		},
		...
	}
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
- Resoponse
	+ status: **200**, **400**,  **401**
	+ errors:
		+ status 400: ```{error: "an awnsome fucking error"}```
	+ body (status: 200):
```
	{
		id: 123,
		title: "room's title",
		thumb: "http://cdn.domain.com/rooms/room-id/thumb.jpg"
		broadcater: {
			id: 321,
			name: "Rainie Bui",
			heart: 1020,
			exp: 12312,
			level: 10
		},
		...
	}
```

### Get room detail
- URI: **/room-id**
- Method: **GET**
- Header
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Resoponse
	+ status: **200**, **400**, **404**, **401**
	+ errors:
		+ status 400: ```{error: "an awnsome fucking error"}```
	+ body (status: 200):
```
	{
		id: 123,
		title: "room's title",
		thumb: "http://cdn.domain.com/rooms/room-id/thumb.jpg",
		background: "http://cdn.domain.com/rooms/room-id/background.jpg",
		youtube-video: "http://youtube.com/ABcXyZ",
		stream-link: "http://cache.streaming-server.com/room-id.rtmp",
		schedule: [
			{ date: "08/11/2015", from: "08:30", to: "09:30"},
			{ date: "08/11/2015", time: "16:00", to: "17:00"},
			...
		],
		broadcater: {
			id: 321,
			name: "Rainie Bui",
			avatar: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
			heart: 1020,
			exp: 1231231,
			level: 10,
			facebook-link: "http://fb.me/whatthefuck",
			instagram-link: "...",
			twitter: "...",
			status: "This is updated status",
		}
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
- Resoponse
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

## Broadcasters
- Namespace URL: **/broadcasters**

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
	id: 321,
	name: "Rainie Bui",
	birthday: "09/10/1991",
	horoscope: "Thien Binh",
	avatar: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
	cover: "http://cdn.domain.com/broadcaters/bct-id/cover.jpg",
	heart: 1020,
	exp: 1231231,
	level: 10,
	facebook-link: "http://fb.me/whatthefuck",
	instagram-link: "...",
	twitter: "...",
	status: "This is updated status",
	description: "too long description...",
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
		{id: 456, name: "Nacy babie", vip: "V1", heart: 253},
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
		id: 321,
		name: "Rainie Bui",
		avatar: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
		heart: 1020,
		exp: 12312,
		level: 10,
		status: ""
	},
	...
]
```

## Users
- Namespace URL: **/users**

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
	id: 321,
	name: "Rainie Bui",
	nickname: "Zit"
	birthday: "09/10/1991",
	email: "rainie@gmail.com",
	avatar: "http://cdn.domain.com/user/user-id/avatar.jpg",
	cover: "http://cdn.domain.com/user/user-id/cover.jpg",
	heart: 1020,
	exp: 1231231,
	level: 10,
	facebook-link: "http://fb.me/whatthefuck",
	instagram-link: "...",
	twitter: "...",
	description: "too long description..."
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
	id: 321,
	name: "Rainie Bui",
	nickname: "Zit"
	birthday: "09/10/1991",
	email: "rainie@gmail.com",
	avatar: "http://cdn.domain.com/user/user-id/avatar.jpg",
	cover: "http://cdn.domain.com/user/user-id/cover.jpg",
	heart: 1020,
	exp: 1231231,
	level: 10,
	facebook-link: "http://fb.me/whatthefuck",
	instagram-link: "...",
	twitter: "...",
	description: "too long description..."
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

### Send screen text

### Get action status

### Vote action

### Get gift list

### Buy gift

### Get louge list

### Send heart

### Get curent rank