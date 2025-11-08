# slskd-port-forward-gluetun-server

A shell script and Docker container for automatically setting slskd's listening port from Gluetun's control server.

## Config

### Environment Variables

| Variable     | Example                     | Default                 | Description                                                                    |
|--------------|-----------------------------|-------------------------|--------------------------------------------------------------------------------|
| SLSKD_USERNAME | `username`                  | `admin`                 | slskd username                                                           |
| SLSKD_PASSWORD | `password`                  | `adminadmin`            | slskd password                                                           |
| SLSKD_ADDR     | `http://192.168.1.100:5030` | `http://localhost:5030` | HTTP URL for the slskd web UI, with port                                 |
| GTN_ADDR     | `http://192.168.1.100:8000` | `http://localhost:8000` | HTTP URL for the gluetun control server, with port                             |
| GTN_USERNAME | `username`                  | *None*                  | Username for authentication to gluetun control server (if basic auth enabled)  |
| GTN_PASSWORD | `password`                  | *None*                  | Password for authentication to gluetun control server (if basic auth enabled)  |
| GTN_APIKEY   | `apikey`                    | *None*                  | API Key for authentication to gluetun control server (if API key auth enabled) |


## Gluetun Control Server Authentication
Starting in Gluetun v3.4, it is required to setup authentication on the Gluetun control server routes.

See this link for information on how to set this up: https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/control-server.md#authentication

Once configured in Gluetun, you can configure this container to use the appropriate authentication method:
- If using `none` auth, you do not need to provide any of the authentication environment variables
- If using `basic` auth, you should set the `GTN_USERNAME` and `GTN_PASSWORD` environment variables
- If using `apikey` auth, you should set the `GTN_APIKEY` environment variable

## Example

### Docker-Compose

The following is an example docker-compose:

```yaml
  slskd-port-forward-gluetun-server:
    image: ghcr.io/sdaqo/slskd-port-forward-gluetun-server
    container_name: slskd-port-forward-gluetun-server
    restart: unless-stopped
    environment:
      - SLSKD_USERNAME=username
      - SLSKD_PASSWORD=password
      - QBT_ADDR=http://192.168.1.100:8080
      - GTN_ADDR=http://192.168.1.100:8000
      - GTN_APIKEY=CHANGEME
```

## Development

### Build Image
```bash
docker build . -t slskd-port-forward-gluetun-server
```

### Run Container
```bash
docker run --rm -it -e SLSKD_USERNAME=admin -e SLSKD_PASSWORD=adminadmin -e SLSKD_ADDR=http://192.168.1.100:5030 -e GTN_ADDR=http://192.168.1.100:8000 -e GTN_APIKEY=CHANGEME slskd-port-forward-gluetun-server:latest
```
