# FROM golang:1.16.13-alpine AS build-env
# RUN  apk add --no-cache git make ca-certificates
# LABEL maintaner="@amimof (github.com/amimof)"
# COPY . /go/src/github.com/amimof/node-cert-exporter
# WORKDIR /go/src/github.com/amimof/node-cert-exporter
# RUN make

# FROM scratch
# COPY --from=build-env /go/src/github.com/amimof/node-cert-exporter/bin/node-cert-exporter /go/bin/node-cert-exporter
# COPY --from=build-env /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# ENTRYPOINT ["/go/bin/node-cert-exporter"]

FROM docker.io/library/golang:1.20.4 AS builder

RUN apt-get update && apt-get install -y ca-certificates \
    make \
    git \
    curl \
    mercurial

ARG PACKAGE=github.com/amimof/node-cert-exporter

RUN mkdir -p /go/src/${PACKAGE}
WORKDIR /go/src/${PACKAGE}

COPY . .
# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=vendor -a -o node-cert-exporter -ldflags "-X main.GitCommit=$(git rev-list -1 HEAD)" ${PACKAGE}/cmd/node-cert-exporter



# Copy the binary into a thin image
FROM alpine:3.9.4
RUN apk add --update ca-certificates \
 && apk add --update -t deps curl jq iproute2 bash \
 && apk del --purge deps \
 && rm /var/cache/apk/*

WORKDIR /
COPY --from=builder /go/src/github.com/amimof/node-cert-exporter/node-cert-exporter /usr/bin/node-cert-exporter
ENTRYPOINT ["/usr/bin/node-cert-exporter"]
