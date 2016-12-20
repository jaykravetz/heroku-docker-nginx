# Heroku Nginx Docker Container

https://sleepy-journey-52785.herokuapp.com/

## Documentation

- Heroku and Docker: https://devcenter.heroku.com/articles/container-registry-and-runtime
- Nginx docker container (source): https://hub.docker.com/_/nginx/

## configuration

```
heroku config:set APP1_URL=https://pure-everglades-37512.herokuapp.com:443
```

## Testing

Something along these lines:

curl -I -H "X-Forwarded-For: 10.136.102.79, 173.178.155.74" http://localhost:3001

The last IP in the X-Forwarded-For will be used as client IP. On Heroku, Heroku guarantees the last IP in this header to be the real client IP.

### Load testing

Do 200 request, 10 at a time.

Direct location:

```
ab -n 200 -c 10 -k -H "Accept-Encoding: gzip, deflate" https://pure-everglades-37512.herokuapp.com/
```

Proxied location:

```
ab -n 200 -c 10 -k -H "Accept-Encoding: gzip, deflate" https://sleepy-journey-52785.herokuapp.com/
```
