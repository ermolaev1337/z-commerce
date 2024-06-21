FROM node

WORKDIR /app
COPY ./z-commerce-socket/package.json /app/package.json
RUN yarn
COPY ./z-commerce-socket/src /app/src