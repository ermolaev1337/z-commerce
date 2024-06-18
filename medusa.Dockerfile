FROM node

COPY ./z-commerce-medusa/package.json /app/package.json
WORKDIR /app
RUN yarn

RUN yarn global add @medusajs/medusa-cli
COPY ./z-commerce-medusa /app

COPY ./uploads /app/uploads
