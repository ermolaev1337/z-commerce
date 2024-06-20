FROM node

COPY ./z-commerce-storefront/package.json /app/package.json
WORKDIR /app
RUN npm i

COPY ./z-commerce-storefront /app