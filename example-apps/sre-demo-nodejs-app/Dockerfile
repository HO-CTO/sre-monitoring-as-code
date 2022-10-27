FROM node:18-alpine

WORKDIR /app

COPY package.json package.json
COPY package-lock.json package-lock.json

EXPOSE 4001

RUN npm install

COPY . .

ENTRYPOINT [ "node", "index.js" ]