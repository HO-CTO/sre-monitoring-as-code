FROM node:18-alpine

WORKDIR /app

COPY package.json package.json
COPY package-lock.json package-lock.json

EXPOSE 8081

RUN npm install

COPY . .

ENTRYPOINT [ "node", "index.js" ]