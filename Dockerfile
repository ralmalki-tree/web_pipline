# Install Operating system and dependencies
FROM node:lts-alpine
RUN pm -y -g install serve
WORKDIR /app/
COPY ./build/web ./web

EXPOSE 3000
CMD ["serve", "web"]