FROM alpine
LABEL maintainer="Hugo Josefson <hugo@josefson.org> (https://www.hugojosefson.com/)"
RUN apk add --no-cache bash socat tini
COPY redirect-to-host .
ENTRYPOINT ["/sbin/tini"]
CMD ["./redirect-to-host"]
