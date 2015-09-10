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
	"password": "*********",
	"cover": "cover_here"
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
	"cover": "cover_here",
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
	"cover": "cover_here",
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


### Active user who regitered by facebook, google plus
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
