FROM alpine
RUN apk add --no-cache iptables
COPY redirect .
CMD ./redirect
