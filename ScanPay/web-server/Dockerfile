FROM python:3-alpine

WORKDIR /usr/src/app
COPY ./web-server/requirements.txt ./
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    libffi-dev \
    musl-dev \
    openssl-dev \
    && pip3 install --no-cache-dir -r requirements.txt \
    && apk del .build-deps
COPY ./web-server .

ENTRYPOINT  [ "python","-m", "web"]
