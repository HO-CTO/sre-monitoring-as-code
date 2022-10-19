FROM node:18-alpine

WORKDIR /app

COPY package.json package.json
COPY package-lock.json package-lock.json


RUN npm install

COPY . .

EXPOSE 5173

ENTRYPOINT [ "npm", "run", "dev" ]