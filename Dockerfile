FROM golang:1.14-alpine3.11 AS build

RUN set -ex \
        && apk add --no-cache --virtual .build-deps git \
        && go get -u github.com/andreimarcu/linx-server \
	&& cd /go/src/github.com/andreimarcu/linx-server && go build \
	&& cd linx-cleanup && go build \
	&& cd ../linx-genkey && go build \
        && apk del .build-deps

FROM alpine:3.11

COPY --from=build /go/bin/linx-server /usr/local/bin/linx-server
COPY --from=build /go/src/github.com/andreimarcu/linx-server/linx-genkey/linx-genkey /usr/local/bin/linx-genkey
COPY --from=build /go/src/github.com/andreimarcu/linx-server/linx-cleanup/linx-cleanup /usr/local/bin/linx-cleanup

ENV GOPATH /go
ENV SSL_CERT_FILE /etc/ssl/cert.pem

COPY static /go/src/github.com/andreimarcu/linx-server/static/
COPY templates /go/src/github.com/andreimarcu/linx-server/templates/

RUN mkdir -p /data/files && mkdir -p /data/meta && chown -R 65534:65534 /data

VOLUME ["/data/files", "/data/meta"]

USER nobody
ENTRYPOINT ["/usr/local/bin/linx-server", "-bind=0.0.0.0:8080", "-filespath=/data/files/", "-metapath=/data/meta/"]
