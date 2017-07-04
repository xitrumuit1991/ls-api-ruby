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
- Install dependencies `bundle install --path vendor/bundle`
- Migrate database `RAILS_ENV=production rake db:migrate`
- Create Passenger config  `Touch Passengerfile.json`
- Add config Passager 
```
{
 environment:'production',
 daemonize :true
}
```
#Setup ruby with rbenv
```
https://gorails.com/deploy/ubuntu/14.04

note : 

rbenv install 2.3.1
rbenv global 2.3.1


```

## Passgener config -> `sudo vi /etc/nginx/passenger.conf` change to
```
passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
passenger_ruby /home/ubuntu/.rbenv/shims/ruby;
```

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

### Config Karken 

#### In file livestar-api/config/setting.yml
```
 [Gitcode](https://github.com/kraken-io/kraken-ruby)


```

### Run And Stop Application 
bundle exec passenger start
bundle exec passenger stop



### Socket Emitter (danger)
### Socket Emitter (danger)
```
	Only require socket.io-emitter version 0.2.0 in Gemfile: gem 'socket.io-emitter', '~> 0.2.0'


```