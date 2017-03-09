# Livestar API

## Requirements
- Ruby v2.3.1
- MySQL
- Redis
- Nginx & Passenger

## Installation
- Clone project to `livestar-api`
- Change directory `cd livestar-api`
- Create database config file `cp config/databased_default.yml config/database.yml`
- Update database config file `vim config/database.yml`
- Update settings file `vim config/settings.yml`
- Update enviroment setting `settings/production.yml`
- Install dependencies `bundle install`
- Migrate database `RAILS_ENV=production rake db:migrate`

## Nginx config
```
server {
        listen 80;

        server_name api.livestar.vn;
        passenger_enabled on;
        rails_env    production;
        root         /home/deploy/livestar-api/public;
        client_max_body_size 5M;
        passenger_max_request_queue_size 1000;

        location ~ ^/uploads/ {
            access_log off;
            expires max;
            gzip_static on;
            add_header Cache-Control public;
            add_header ETag "";
        }

        # redirect server error pages to the static page /50x.html
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
}

```