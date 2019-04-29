# Nginx caching proxy

A simple frontend for caching requests to an upstream source. This is a custom-built Nginx with modules statically linked in. The VTS module is included for live metrics. It supports multiple upstreams, including health check options.

## Volumes

| Path   | Description                 |
| ------ | --------------------------- |
| /cache | Store nginx cache data here |

## Endpoints

The container includes VTS metrics module and the default `nginx.conf` includes a path
that exposes live metrics.

| URL     |              |
| ------- | ------------ |
| /status | Live metrics |

## Purging

This module has cache purging enable with no restrictions on IP range. To purge the cache use the `PURGE` method with a wildcard.

    curl -X PURGE -D – "https://www.example.com/*"


## Environment variables
| Name                   | Default                      | Description                                                                                                                   |
| -----------------------| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| LISTENPORT             | 8888                         | Bind the webserver to this port (useful for host network)                                                                     |
| UPSTREAM               |                              | Include server address and port for upstream target, multiple targets can be split with a semicolon ';'                       |
| UPSTREAM_PROTOCOL      | http                         | The upstream protocol to use (all upstreams must match)                                                                       |
| UPSTREAM_OPTS          | max_fails=5 fail_timeout=15s | Options to append to each upstream                                                                                            |
| WORKERS                | 4                            | How many nginx worker processes to spawn                                                                                      |
| MAX_EVENTS             | 1024                         | How many connections we can handle                                                                                            |
| SENDFILE               | on                           | Turn sendfile kerenel optimization on?                                                                                        |
| TCP_NOPUSH             | off                          | Disable TCP push?                                                                                                             |
| CACHE_SIZE             | 1G                           | Size of cache on disk                                                                                                         |
| CACHE_MEM              | 10m                          | Ram size for cache keys                                                                                                       |
| CACHE_AGE              | 365d                         | When should we auto retire entries?                                                                                           |
| USE_PERFLOG            | 0                            | Also logs to /log/access.log if set to 1, useful for [exporting](https://www.martin-helmich.de/en/blog/monitoring-nginx.html) |
| PROXY_CACHE_LOCK       | on                           | Only allow one cache request to the upstream                                                                                  |
| SSL                    | off                          | Set to on, to use SSL over the listenport                                                                                     |
| CERTIFICATE            | /etc/certs.d/bad.pem         | Use this to map in a proper certificate                                                                                       |
| CERTIFICATE_KEY        | /etc/certs.d/bad.key         | Use this to map in a proper key                                                                                               |
| CUSTOM_CONFIGURATION   |                              | Use this to include any custom nginx configuration in the root location                                                       |


## Example Configuration

The following docker compose 

```yaml

version: '2'

services:
  cache:
    image: seanhoughton/nginx-cache:1.16.0
    environment:
      - LISTENPORT=3333
      - UPSTREAM=server1.com:80;server2.com:80
      - UPSTREAM_OPTS="max_fails=3 fail_timeout=30s"
      - UPSTREAM_PROTOCOL=http
      - CACHE_SIZE=1024g
      - CACHE_MEM=256g
      - CACHE_AGE=30d
      - MAX_EVENTS=1024
      - WORKERS=16
    ports:
      - 3333:3333
    volumes:
      - cache:/cache

volumes:
    cache:
```


## Resources

* https://www.nginx.com/blog/nginx-caching-guide/
* https://github.com/FRiCKLE/ngx_cache_purge
* https://github.com/vozlt/nginx-module-vts/