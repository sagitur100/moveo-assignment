FROM nginx:latest
RUN echo "yo this is nginx" > /usr/share/nginx/html/index.html
EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]