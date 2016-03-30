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
    + 401: ```{ error: "Tài khoản này chưa được kích hoạt !" }```
    + 401: ```{ error: "Email hoặc mật khẩu bạn vừa nhập không chính xác !" }```
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
- Response:
  + status: **201** *(OK)*, **400** *(Bad request)*
    + 201: ```{ success: "Vui lòng kiểm tra mail để kích hoạt tài khoản của bạn !" }```
    + 400: 
    ```
    {
        "error": {
            "email": [
                "Vui lòng nhập email",
                "Vui lòng nhập đúng định dạng Email"
            ],
            "password": [
                "Vui lòng nhập mật khẩu"
            ]
        }
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

### Forgot code (update forgot code to reset password)
- URI: **/update-forgot-code**
- Method: **POST**
- Header:
  + Content-Type: application/json
- Request: ```{ "email": "alex@email.com"}```
- Response:
  + status **200** *(OK)*, **400** *(Bad request)*, **404** *(User Not found)*

### Set new password
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
```
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
    + status 404: ```{error: "an awnsome fucking error"}```
  + body (status: 200):
```
{
    "id": 1,
    "title": "room 1",
    "slug": "room-1",
    "thumb": "http://.../thumb_cute_girl_1.jpg?timestamp=1456279838",
    "thumb_mb": "http://.../thumb_mb_cute_girl_1.jpg?timestamp=1456279838",
    "is_privated": false,
    "on_air": false,
    "link_stream": "http://210.245.125.6:80/livestar/1/playlist.m3u8",
    "background": "http://.../Background_1.jpg",
    "broadcaster": {
        "broadcaster_id": 1,
        "user_id": 5,
        "avatar": "http://api.dev.livestar.vn//api/v1/users/5/avatar?timestamp=1449123703",
        "name": "AngCo(*_^) 1",
        "heart": 526,
        "exp": 3967,
        "percent": 100,
        "level": 49,
        "facebook": "https://www.facebook.com/danhbunanco",
        "twitter": "https://www.facebook.com/danhbunanco",
        "instagram": "https://www.facebook.com/danhbunanco",
        "status": null,
        "isFollow": true
    },
    "schedules": [
        {
            "date": "31/10/2015",
            "start": "16:15",
            "end": "06:47"
        },
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
  + errors: 
    + status 400: ```{error: "Error message"}```
    + status 404: ```{error: "Error message"}```

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
  + errors: 
    + status 400: ```{error: "Error message"}```
    + status 404: ```{error: "Error message"}```
  + body (status: 200):
```
{
  "thumb":"http://.../thumb_firefox.jpg?timestamp=1458211433"
}
```

### Upload backgroud
- URI: **/background**
- Method: **POST**
- Header
  + Content-Type: multipart/form-data
  + Authorization: Token token="this-is-jwt-token"
- Request:
  + background: image/jpeg
- Response
  + status: **200**, **400**, **404**, **401**
  + body (status: 200):
```
{
  "id":22,
  "image":"http://.../square_97fc0ac09d.jpg?timestamp=1458214918"
}
```

### Change background
- URI: **/background**
- Method: **PUT**
- Header
  + Content-Type: application/json
  + Authorization: Token token="this-is-jwt-token"
- Request: ```{ background_id: 12 }```
- Resoponse
  + status: **200**, **400**, **404**, **401**
  + errors :
    + status 400: ```{error: "Error message"}```
    + status 404: ```{error: "Error message"}```

### Delete background
- URI: **/background**
- Method: **DELETE**
- Header
  + Content-Type: application/json
  + Authorization: Token token="this-is-jwt-token"
- Request: ```{ background_id: 13 }```
- Resoponse
  + status: **200**, **400**, **404**, **401**
  + errors :
    + status 400: ```{error: "Error message"}```
    + status 404: ```{error: "Error message"}```


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
  + errors:
    + status 400: ```{error: "Error message"}```
    + status 404: ```{error: "Error message"}```

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
    "id": 20,
    "name": "Kim cương xanh",
    "image": "http://.../gift/image/20/square_Lacmong.png?timestamp=1456195423",
    "price": 121,
    "discount": 0
  },
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
    "id": 18,
    "name": "Múa bale",
    "image": "http://.../room_action/image/18/square_17.png?timestamp=1456195819",
    "price": 1,
    "max_vote": 10,
    "voted": 0,
    "percent": 0,
    "discount": 0
  },
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
]
```

## Broadcasters
- Namespace URL: **/broadcasters**

### My Profile,
- URI: **/**
- Method: **GET**
- Header:
  + Content-Type: application/json
  + Authorization: Token token="this-is-jwt-token"
- Response:
  + status: **200**, **401**
  + body:
```
{
    "id": 7,
    "name": "VietDanh",
    "fullname": "Vo Danh",
    "username": "vodanh",
    "email": "vd@gmail.com",
    "birthday": "1991-12-30",
    "gender": null,
    "address": "7987 Chesley Pines",
    "phone": "1-682-553-6817 x06458",
    "avatar": "http://.../users/7/avatar?timestamp=1458100253",
    "cover": "http://.../users/7/cover?timestamp=1458100253",
    "facebook": "",
    "twitter": "",
    "instagram": "",
    "heart": 6969,
    "user_exp": 224,
    "bct_exp": 6969,
    "description": "Vo Danh",
    "status": "this is my update status",
    "photos": [
        {
            "id": 68,
            "link_square": "http://.../bct_image/image/32/square_05.png",
            "link": "http://.../bct_image/image/32/05.png"
        }
    ],
    "videos": [
        {
            "id": 28,
            "link": "https://www.youtube.com/embed/co4YpHTqmfQ",
            "thumb": "http://img.youtube.com/vi/co4YpHTqmfQ/hqdefault.jpg"
        }
    ]
}
```

### Broadcaster Revcived Items,
- URI: **/revcived-items**
- Method: **GET**
- Header:
  + Content-Type: application/json
  + Authorization: Token token="this-is-jwt-token"
- Response:
  + status: **200**, **400**
  + errors:
   + status 400: ```{error: 'Thông báo lỗi'}```
  + body:
```
[
  {
    id: 321,
    name: "abc",
    thumb: "http://cdn.domain.com/user/user-id/avatar.jpg",
    quantity: 1000,
    cost: 100,
    total_cost: 100000,
    created_at: "2015-10-06 00:00:00"
  },
  ...
]
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
  + errors:
    + status 400: ```{error: "Thông báo lỗi" }```
  + body:
```
[ 
  {link: "http://.../photo_1.jpg" }, 
  {link: "http://.../photo_1.jpg" },
  ...
]
```

### Delete pictures
- URI: **/pictures**
- Method: **DELETE**
- Header:
  + Content-Type: application/json
  + Authorization: Token token="this-is-jwt-token"
- Request:  ```{ id :[ 123654, 654123 ] }```
- Response:
  + status: **200**, **400**, **401**

### Create video
- URI: **/videos**
- Method: **POST**
- Header:
  + Content-Type: multipart/form-data
  + Authorization: Token token="this-is-jwt-token"
- Request:
  + videos (array): image/jpeg
  + videos[0][link]   = string( https://www.youtube.com/watch?v=Q4KkfiLRLdQ )
  + videos[0][image]  = file
  + videos[1][link]   = string( https://www.youtube.com/watch?v=Q4KkfiLRLdQ )
  + videos[1][image]  = file
- Response:
  + status: **200**, **400**, **401**
  + errors:
    + status 400: ```{error: Thông báo lỗi}```
  + body:
```
[
    {
        "id": 14,
        "video": "https://www.youtube.com/embed/Q4KkfiLRLdQ",
        "thumb": "http://.../thumb_12.png"
    },
    {
        "id": 15,
        "video": "https://www.youtube.com/embed/lhRuelm-vFU",
        "thumb": "http://.../thumb_11.png"
    }
]
```

### Delete videos
- URI: **/videos**
- Method: **DELETE**
- Header:
  + Content-Type: application/json
  + Authorization: Token token="this-is-jwt-token"
- Request:  ```{ id :[ 123654, 654123 ] }```
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
  + errors:
    + status 400: ```{ error: 'Thông báo lỗi' }```
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
        "id": 1,
        "name": "AngCo(*_^) 1",
        "username": "username_4",
        "avatar": "http://.../users/5/avatar?timestamp=1449123703",
        "heart": 0,
        "user_exp": 3147,
        "bct_exp": 3967,
        "level": 49,
        "room": {
            "id": 1,
            "title": "room 1",
            "slug": "room-1",
            "on_air": false,
            "thumb": "http://.../thumb/1/thumb_mb_cute_girl_1.jpg?timestamp=1456279838",
            "thumb_mb": "http://.../thumb/1/thumb_cute_girl_1.jpg?timestamp=1456279838"
        },
        "schedule": {
            "date": "17/11",
            "start": "18:15"
        }
    },
    {
        "id": 2,
        "name": "AngCo(*_^) 1",
        "username": "username_4",
        "avatar": "http://.../users/5/avatar?timestamp=1449123703",
        "heart": 0,
        "user_exp": 3147,
        "bct_exp": 3967,
        "level": 49,
        "room": {
            "id": 2,
            "title": "room 1",
            "slug": "room-1",
            "on_air": false,
            "thumb": "http://.../thumb/1/thumb_mb_cute_girl_1.jpg?timestamp=1456279838",
            "thumb_mb": "http://.../thumb/1/thumb_cute_girl_1.jpg?timestamp=1456279838"
        },
        "schedule": null
    },
    ...
]
```

### Search broadcasters
- URI: **/search?q=keyword**
- Method: **GET**
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
        "id": 32,
        "name": "VietDanh",
        "username": "vodanh",
        "avatar": "http://api.dev.livestar.vn//api/v1/users/7/avatar?timestamp=1458100253",
        "heart": 0,
        "user_exp": 224,
        "level": 22,
        "isFollow": true
        "room": {
            "id": 31,
            "title": "Room VDNguyen",
            "slug" : "btc-01",
            "on_air": false,
            "thumb": "http://api.dev.livestar.vn//uploads/room/thumb/31/thumb_mb_cute_girl_2.jpg?timestamp=1456282757",
            "thumb_mb": "http://api.dev.livestar.vn//uploads/room/thumb/31/thumb_cute_girl_2.jpg?timestamp=1456282757"
        },
        "schedule": {
            "date": "01/03",
            "start": "02:00"
        }
    },
    {
        "id": 32,
        "name": "VietDanh",
        "username": "vodanh",
        "avatar": "http://api.dev.livestar.vn//api/v1/users/7/avatar?timestamp=1458100253",
        "heart": 0,
        "user_exp": 224,
        "level": 22,
        "isFollow": true
        "room": null,
        "schedule": null
    },
    ...
  ]
}
```

### Get featured broadcasters
- URI: **/featured**
- Method: **GET**
- Header:
  + Content-Type: application/json
- Response:
  + status: **200**, **400**, **401**
  + body:
```
{
  "totalPage": 2,
  "broadcasters": [
    {
      "id": 133,
      "bct_id": 34,
      "name": "bct_002",
      "username": "bct_002",
      "avatar": "http://api.dev.livestar.vn//api/v1/users/133/avatar?timestamp=1458293884",
      "heart": 0,
      "bct_exp": 0,
      "level": 31,
      "isFollow": true,
      "room": {
        "id": 33,
        "totalUser": 0,
        "title": "Room BCT 002",
        "slug": "room-bct-002",
        "on_air": false,
        "thumb": "http://api.dev.livestar.vn//uploads/room/thumb/33/thumb_cute_girl_4.jpg?timestamp=1449102738",
        "thumb_mb": "http://api.dev.livestar.vn//uploads/room/thumb/33/thumb_mb_cute_girl_4.jpg?timestamp=1449102738"
      }
    },
    {
      "id": 134,
      "bct_id": 35,
      "name": "bct_003",
      "username": "bct_003",
      "avatar": "http://api.dev.livestar.vn//api/v1/users/134/avatar?timestamp=1449451367",
      "heart": 0,
      "bct_exp": 0,
      "level": 25,
      "isFollow": true,
      "room": {
        "id": 35,
        "totalUser": 0,
        "title": "Room BCT 003",
        "slug": "room-bct-003",
        "on_air": true,
        "thumb": "http://api.dev.livestar.vn//uploads/room/thumb/35/thumb_cute_girl_5.jpg?timestamp=1449102745",
        "thumb_mb": "http://api.dev.livestar.vn//uploads/room/thumb/35/thumb_mb_cute_girl_5.jpg?timestamp=1449102745"
      }
    },
    ....
  ]
}
```

### Home Get featured broadcasters
- URI: **/home-featured**
- Method: **GET**
- Header:
  + Content-Type: application/json
- Response:
  + status: **200**, **400**, **401**
  + body:
```
[
  {
        "id": 2,
        "name": "Thị Màu",
        "avatar": "http://api.dev.livestar.vn//api/v1/users/2/avatar?timestamp=1449132581",
        "heart": 2,
        "bct_exp": 953,
        "level": 10,
        "room": {
          "id": 2,
          "title": "Room LiveStar",
          "on_air": true,
          "thumb": "http://api.dev.livestar.vn//uploads/room/thumb/2/thumb_mb_anh-thien-nhien-12-351x185.jpg?timestamp=1451332262",
          "thumb_mb": "http://api.dev.livestar.vn//uploads/room/thumb/2/thumb_anh-thien-nhien-12-351x185.jpg?timestamp=1451332262"
        },
        "schedules": []
      },
      {
        "id": 1,
        "name": "Hot Girl Demo",
        "avatar": "http://api.dev.livestar.vn//api/v1/users/1/avatar?timestamp=1449124014",
        "heart": 22,
        "bct_exp": 956,
        "level": 49,
        "room": {
          "id": 3,
          "title": "Hello World",
          "on_air": true,
          "thumb": "http://api.dev.livestar.vn//uploads/room/thumb/3/thumb_mb_cute_girl_40.jpg?timestamp=1449104500",
          "thumb_mb": "http://api.dev.livestar.vn//uploads/room/thumb/3/thumb_cute_girl_40.jpg?timestamp=1449104500"
        },
        "schedules": [
          {
            "date": "09/03",
            "start": "23:30"
          },
          {
            "date": "09/03",
            "start": "23:30"
          }
        ]
      },
  ...
]
```

### Room Get featured broadcasters
- URI: **/room-featured**
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
        "id": 141,
        "bct_id": 42,
        "name": "Liem12312321",
        "username": "bct_010",
        "avatar": "http://api.dev.livestar.vn//api/v1/users/141/avatar?timestamp=1458096683",
        "heart": 0,
        "bct_exp": 0,
        "level": 21,
        "isFollow": false,
        "room": {
          "id": 42,
          "title": "Developer2",
          "on_air": true,
          "totalUser": 0,
          "slug": "room-bct-010",
          "thumb": "http://api.dev.livestar.vn//uploads/room/thumb/42/thumb_mb_1631435.jpg?timestamp=1451338004",
          "thumb_mb": "http://api.dev.livestar.vn//uploads/room/thumb/42/thumb_1631435.jpg?timestamp=1451338004",
          "schedule": {
            "start": "09/03"
          }
        }
      },
      {
        "id": 5,
        "bct_id": 1,
        "name": "AngCo(*_^) 1",
        "username": "username_4",
        "avatar": "http://api.dev.livestar.vn//api/v1/users/5/avatar?timestamp=1449123703",
        "heart": 526,
        "bct_exp": 3767,
        "level": 49,
        "isFollow": false,
        "room": {
          "id": 1,
          "title": "room 1",
          "on_air": false,
          "totalUser": null,
          "slug": "room-11",
          "thumb": "http://api.dev.livestar.vn//uploads/room/thumb/1/thumb_mb_1631435.jpg?timestamp=1451276934",
          "thumb_mb": "http://api.dev.livestar.vn//uploads/room/thumb/1/thumb_1631435.jpg?timestamp=1451276934",
          "schedule": {
            "start": "09/03"
          }
        }
      },
  ...
]
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
[
  {
    id: 321,
    name: "abc",
    thumb: "http://cdn.domain.com/user/user-id/avatar.jpg",
    quantity: 1000,
    cost: 100,
    total_cost: 100000,
    created_at: "2015-10-06 00:00:00"
  }
]
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
  + status: **200**, **400**, **404**
  + errors:
    + status 400: ```{error: "Thong bao loi "}```
    + status 404: ```{error: "Không tìm thấy user "}```

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
  "id": 7,
  "name": "VanA",
  "username": "vana",
  "email": "vana@gmail.com",
  "birthday": "30-12-1991",
  "gender": male,
  "address": "7987 Chesley Pines",
  "phone": "1-682-553-6817 x06458",
  "is_bct": true,
  "avatar": "http://.../avatar?timestamp=1458100253",
  "cover": "http://.../cover?timestamp=1458100253",
  "facebook": "",
  "twitter": "",
  "instagram": "",
  "heart": 0,
  "money": 50000,
  "user_exp": 224,
  "percent": 40,
  "user_level": 22,
  "active_code": "F20773",
  "room": {
      "slug": "room-vana"
  }
}
```

### Get user's public profile
- URI: **/:username**
- Method: **GET**
- Header:
  + Content-Type: application/json
  + Authorization: Token token="this-is-jwt-token"
- Response:
  + status: **200**, **400**
  + errors:
    + status 400: ```{error: "Thông báo lỗi "}```
  + body:
```
{
    "id": 2,
    "name": "Thị Màu",
    "username": "username_1",
    "email": "bct2@gmail.com",
    "birthday": "2015-11-30",
    "horoscope": "Nhân Mã",
    "gender": null,
    "address": "5585 Rolfson Greens",
    "phone": "1-415-641-3976 x700",
    "is_bct": true,
    "avatar": "http://.../avatar?timestamp=1449132581",
    "cover": "http://.../cover?timestamp=1449132581",
    "facebook": "facebook.com/ncvphuong/",
    "twitter": "",
    "instagram": "",
    "heart": 0,
    "money": 10000,
    "user_exp": 222,
    "percent": 20,
    "user_level": 22,
    "description": "",
    "photos": [
        {
            "id": 50,
            "link": "http://.../banner2.jpg",
            "link_square": "http://.../square_banner2.jpg"
        }
    ],
    "videos": [
        {
            "id": 28,
            "link": "https://www.youtube.com/embed/co4YpHTqmfQ",
            "thumb": "http://localhost:3000"
        }
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
  birthday: "09/10/1991",
  facebook: "...",
  twitter: "...",
  instagram: "...",
}
```
- Response:
  + status: **200**, **400**
  + errors:
    + status 400: ```{error: "Thông báo lỗi "}```

### Update avatar
- URI: **/avatar**
- Method: **POST**
- Header:
  + Content-Type: multipart/form-data
  + Authorization: Token token="this-is-jwt-token"
- Request:
  + avatar: image/jpeg
- Response:
  + status: **201**, **400**, **401**
  + errors:
    + status 400: ```{error: "Thông báo lỗi "}```
    + status 401: ```{error: "Thông báo lỗi chưa đăng nhập "}```

### Update cover
- URI: **/cover**
- Method: **POST**
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
  + errors:
      + status 400: ```{error: "Thông báo lỗi "}```
      + status 401: ```{error: "Thông báo lỗi chưa đăng nhập "}```
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
      "name": "VIP_P 1",
      "actived": true,
      "active_date": "2016-03-16T00:00:00.000+07:00",
      "expiry_date": "2017-01-12T00:00:00.000+07:00"
    },
    {
      "name": "VIP_P 2",
      "actived": true,
      "active_date": "2016-03-16T00:00:00.000+07:00",
      "expiry_date": "2017-01-12T00:00:00.000+07:00"
    }
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
    id:       123
    title:      "Room ABC"
    slug:     "room-abc"
    description:  "Room AbC Room AbC"
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
  + errors:
    + status 400: {error: "Thông báo lỗi"}
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
  + errors:
      + status 400: ```{error: "Thông báo lỗi"}```
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
  + errors:
          + status 400: ```{error: "Thông báo lỗi"}```
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
  + errors:
        + status 400: ```{error: "Thông báo lỗi"}```
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
  + errors:
          + status 400: ```{error: "Thông báo lỗi"}```
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
  + status: **400**, **401**, **404**, **200**
  + errors: 
      + status 200: ```{message: "Vui lòng gửi tin nhắn sau 3 s! "}```
      + status 400: ```{error: "Nội dung chat không được vượt quá số kí tư cho phép hoặc vui lòng nhập tin nhắn trước khi gửi "}```
      + status 401: ```{error: "Unauthorized "}```
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
  + status: **401**, **200**, **403**
  + errors: 
      + status 401: ```{error: "Bạn chưa đăng nhập!"}```
      + status 403: ```{error: "Thông báo lỗi"}```
