FROM alpine
RUN apk add --no-cache bash socat tini
COPY redirect-to-host .
ENTRYPOINT ["/sbin/tini"]
CMD ["./redirect-to-host"]
