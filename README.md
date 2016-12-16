# Heroku Nginx Docker Container

https://sleepy-journey-52785.herokuapp.com/

## Documentation

- Heroku and Docker: https://devcenter.heroku.com/articles/container-registry-and-runtime
- Nginx docker container (source): https://hub.docker.com/_/nginx/

## Testing

Something along these lines:

curl -I -H "X-Forwarded-For: 10.136.102.79, 173.178.155.74" http://localhost:3001

The last IP in the X-Forwarded-For will be used as client IP. On Heroku, Heroku guarantees the last IP in this header to be the real client IP.
