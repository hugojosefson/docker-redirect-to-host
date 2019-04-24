# hugojosefson/redirect-to-host

Redirects incoming TCP connections to Docker host.

Meant to be used in a `docker stack` as temporary replacement for a
service you wish to develop and run locally on the host.

The other services in the stack can continue try to access the service
like normal, and the requests will be forwarded up to the host.

Make sure the service you are developing listens on `0.0.0.0` with the
relevant port. Then if it needs to contact the other services, make
sure their ports are published, so they can be accessed on `localhost`
from the service running on the host.

## Example usage with `docker swarm`

Given `*.local.example.com` is registered in DNS as `127.0.0.1`.

In the `docker-compose.yml` file, where you want to replace
`example-backend` with `redirect-to-host` so you can develop and run
`example-backend` in your IDE on the host:

```yaml
version: "3.7"

networks:
  traefik-net: {}

services:
  traefik:
    image: traefik
    command: --docker --docker.swarmMode --docker.watch
      --docker.domain=local.example.com --api
    ports:
      - 80:80
      - 8080:8080
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    deploy:
      mode: global
      placement:
        constraints:
          - node.role == manager
    networks:
      - traefik-net

  example-backend:
    image: hugojosefson/redirect-to-host
    deploy:
      replicas: 1
      labels:
        traefik.port: 10100
        traefik.frontend.rule: Host:example-backend.local.example.com
    environment:
      PORT: 10100
    networks:
      - traefik-net

  example-frontend:
    image: docker-registry.example.com/example-frontend:master
    deploy:
      replicas: 1
      labels:
        traefik.port: 10200
        traefik.frontend.rule: Host:example-frontend.local.example.com
    environment:
      API_ROOT: http://example-backend.local.example.com/api/v1
      PORT: 10200
    networks:
      - traefik-net

  example-other-service:
    image: docker-registry.example.com/example-other-service:master
    deploy:
      replicas: 1
      labels:
        traefik.port: 10300
        traefik.frontend.rule: Host:example-other-service.local.example.com
    environment:
      PORT: 10300
    networks:
      - traefik-net

```

You may then deploy the stack:

```bash
docker stack deploy \
  --with-registry-auth \
  --prune \
  --compose-file docker-compose.yml \
  thestack
```

In this example, `example-frontend` will be able to connect to the
`example-backend` you run in development mode on the host. It will then
be able to access `example-other-service` on
http://example-other-service.local.example.com.
