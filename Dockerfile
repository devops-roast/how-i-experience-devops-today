FROM ubuntu:latest

RUN apt-get update && apt-get install -y nodejs npm curl vim

WORKDIR /app

COPY ./app/package.json /app
COPY ./app/index.js /app

RUN npm install

USER root

CMD ["npm", "start"]
