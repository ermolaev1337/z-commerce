FROM node

COPY ./z-commerce-storefront/package.json /app/package.json
WORKDIR /app
RUN yarn

COPY ./z-commerce-storefront /app
