FROM golang:1.25-trixie AS build

# update as appropriate
ARG EXPORTER_VERSION=0.4.6

RUN apt-get update && apt-get install -y git

ENV CGO_ENABLED=0

WORKDIR /tmp/src

RUN git clone https://github.com/letsencrypt/unbound_exporter.git && \
    cd unbound_exporter && \
    git checkout tags/v${EXPORTER_VERSION} && \
    go build -o /unbound_exporter -trimpath -ldflags="-s -w  -extldflags=-static" .

FROM busybox:stable

COPY --from=build /unbound_exporter /

ENTRYPOINT ["/unbound_exporter"]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD wget http://localhost:9167/metrics -q -O - > /dev/null 2>&1
