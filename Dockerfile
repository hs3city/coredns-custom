FROM docker.io/golang:1.20.1-alpine3.17 as builder

RUN apk add --no-cache git==2.38.4-r1 make==4.3-r1 && \
    git clone https://github.com/coredns/coredns /go/src/github.com/coredns/coredns --depth=1 --branch=v1.10.1

WORKDIR /go/src/github.com/coredns/coredns

RUN sed -i '/^view:view/a tailscale:github.com/damomurf/coredns-tailscale' plugin.cfg && \
    sed -i '/^tailscale:github/a mdns:github.com/openshift/coredns-mdns' plugin.cfg && \
    make

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /go/src/github.com/coredns/coredns/coredns /usr/bin/

ENTRYPOINT ["/usr/bin/coredns"]
