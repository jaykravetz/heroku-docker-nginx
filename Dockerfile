FROM nginx

# ENV LAST_UPDATED 20161021

COPY sample-html /usr/share/nginx/html
COPY config/default.conf.template /etc/nginx/conf.d/default.conf.template

# Expose ports.
EXPOSE 80

# Out-of-the-box, Nginx doesn't support using environment variables inside most configuration blocks. But envsubst may be used as a workaround if you need to generate your nginx configuration dynamically before nginx starts.
CMD /bin/bash -c "envsubst < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
