
FROM node:latest AS node
WORKDIR /app
COPY . . 
RUN npm install
RUN npm run build --prod 


FROM nginx:alpine 
COPY --from=node /app/dist/angular-project /usr/share/nginx/html
