FROM node

COPY ./z-commerce-storefront/package.json /app/package.json
WORKDIR /app
RUN yarn

COPY ./z-commerce-storefront /app

COPY ./storefront.env /app/.env
RUN yarn build # REQUIRES THE MEDUSA BACKEND RUNNING FOR PAGES
