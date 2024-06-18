FROM node

COPY ./z-commerce/package.json /app/package.json
WORKDIR /app
RUN yarn

RUN yarn global add @medusajs/medusa-cli
COPY ./z-commerce /app
