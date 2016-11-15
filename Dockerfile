FROM nginx
COPY sample-html /usr/share/nginx/html
# ENV LAST_UPDATED 20161021

# Expose ports.
EXPOSE 80