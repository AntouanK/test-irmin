FROM node:current-alpine3.12

WORKDIR /home/docker/front-end

COPY ./front-end/package.json .
COPY ./front-end/package-lock.json .

RUN npm i

COPY ./front-end/rollup.config.js ./
COPY ./front-end/scripts ./scripts
COPY ./front-end/public ./public
COPY ./front-end/src ./src

ENV HOST=0.0.0.0

CMD npm run dev
