# **LIVESTAR API Ver 1.0**
``HOST: http://domain.com/api/v1``

## **Authorizations**
``Base URL: /auth``

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
	"name": "name_here",
	"username": "username_here",
	"birthday": "08/10/1999",
	"gender": "male",
	"address": "address_here",
	"email": "peter@gmail.com",
	"phone": "09090909090",
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
	"birthday": "08/10/1999",
	"gender": "male",
	"address": "address_here",
	"email": "peter@gmail.com",
	"phone": "09090909090",
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
	"birthday": "08/10/1999",
	"gender": "male",
	"address": "address_here",
	"email": "peter@gmail.com",
	"phone": "09090909090",
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
- Request:
```{ "email": "alex@email.com" }```
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


## **User**
``Base URL: /users``

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
	+ status: **200** *(OK)*, **400** *(Bad request)*


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
	+ status: **200**, **400**,  **401**
	+ body:  for status 200 only
```
{
	"name": "Grant",
    "username": "Grant",
    "email": "grant@douglaauer.name",
    "birthday": "2014-01-23",
    "gender": "nu",
    "address": "306 Carroll Causeway",
    "phone": "471.717.3910",
    "avatar": null,
    "cover": "Eos cumque et odio earum inventore fugit dolores.",
    "money": 9737154,
    "user_exp": 1636621
}
```
### Update profile
- URI: **/**
- Method: **PUT**
- Header:
	+ Content-Type: application/json
	+ Authorization: Token token="this-is-jwt-token"
- Response:
	+ status: **200**, **400**,  **401**
	+ body:  for status 200 only
```
{
	"name": "Grant",
    "username": "Grant",
    "email": "grant@douglaauer.name",
    "birthday": "2014-01-23",
    "gender": "nu",
    "address": "306 Carroll Causeway",
    "phone": "471.717.3910",
    "cover": "Eos cumque et odio earum inventore fugit dolores."
}
```

### Update avatar
- URI: **/avatar**
- Method: **PUT** *(for update)*
- Header:
	+ Content-Type: **multipart/form-data**
	+ Authorization: Token token="this-is-jwt-token"
- Request: ```avatar:file```
- Response:
	+ status **201** *(OK)*, **401** *(Unauthorize)*, **400** *(Bad request)*,  **404** *(Not found)*

### Update cover
- URI: **/cover**
- Method: **PUT** *(for update)*
- Header:
	+ Content-Type: **multipart/form-data**
	+ Authorization: Token token="this-is-jwt-token"
- Request: ```avatar:file```
- Response:
	+ status **201** *(OK)*, **401** *(Unauthorize)*, **400** *(Bad request)*,  **404** *(Not found)*


## **Room**
``Base URL: /rooms``

### Get room details
- URI: **/**
- Method: **GET**
- Request:
```
{
	"room_id": "AAAAAAA"
}
```
- Response:
	+ status: **200**, **400**,  **401**
	+ body:  for status 200 only
```
{
    "title": "Dynamic Metrics Supervisor",
    "slug": "non",
    "thumb": null,
    "background": null,
    "is_privated": true,
    "broadcaster": {
        "id": 5,
        "fullname": "Ms. Ada Funk"
    },
    "room": {
        "id": 11,
        "title": "Principal Metrics Analyst",
        "slug": "cupiditate",
        "description": "Ea facere."
    }
}
```