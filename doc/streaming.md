## Table of Contents

* [Adaptive Streaming](#adapative-streaming)
* [Credentials](#credentials)

##### Adaptive Streaming

It is the combine of original stream & 360p transcode:

```
http://stream.livestar.vn/livestar-open/<room_id>_aac/playlist.m3u8
http://stream.livestar.vn/livestar-open/<room_id>_360/playlist.m3u8
```


As a result we can use this link to provide stream adaptation based on network status: 

`http://stream.livestar.vn/livestar-open/ngrp:<room_id>_adaptive/playlist.m3u8`

##### Credentials

* Admin

```
Link: http://stream.livestar.vn:8088/enginemanager/login.htm
User: admin
Password: BVPg66Bjr8S3
```

* Livestar-dev

```
rtmp://stream.livestar.vn:80/livestar-dev
user: livestar
pass: j6hUNJMaPXn4
output format: http://stream.livestar.vn:80/livestar-dev/<room_id>_aac/playlist.m3u8
```

* Livestar-production

```
rtmp://stream.livestar.vn:80/livestar-open
user: livestar
pass: livestar123
output format: http://stream.livestar.vn:80/livestar-open/<room_id>_aac/playlist.m3u8
```