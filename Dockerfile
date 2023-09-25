FROM nginx:1.25.2-alpine

COPY ./build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]