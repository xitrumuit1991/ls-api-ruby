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
    "totalPage":4,
    "rooms":[
      {
        "id": 2,
        "title": "Room LiveStar",
        "slug": "room-2",
        "totalUser": 0,
        "thumb": "http://.../thumb_cute_girl_12.jpg?timestamp=1449103220",
        "thumb_mb": "http://.../thumb_mb_cute_girl_12.jpg?timestamp=1449103220",
        "broadcaster": {
            "id": 2,
            "bct_id": 2,
            "name": "Thị Màu",
            "avatar": "http://.../avatar?timestamp=1449132581",
            "heart": 2,
            "exp": 953,
            "level": 10,
            "isFollow": false
        }
      },
      ...
    ]
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
- Response
	+ status: **200**, **400**,  **401**
	+ errors:
		+ status 400: ```{error: "an awnsome fucking error"}```
	+ body (status: 200):
``````
{
  "totalPage": 1,
  "rooms":[
      {
          "id": 46,
          "title": "Trâm Anh (Teddy Baby)",
          "slug": "huynh-ngoc-tram-anh",
          "thumb": "http://.../thumb?timestamp=1458189010",
          "thumb_mb": "http://.../thumb_mb?timestamp=1458189010",
          "date": "17/03",
          "start": "10:00",
          "broadcaster": {
              "id": 220,
              "bct_id": 49,
              "name": "Trâm Anh",
              "avatar": "http://api.livestar.vn/api/v1/users/220/avatar",
              "heart": 283,
              "exp": 5586988,
              "level": 9,
              "isFollow": true
          }
      },
      ....
  ]
}
``````
