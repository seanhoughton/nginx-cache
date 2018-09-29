# Nginx proxy cache

A simple frontend for caching requests to an upstream source.

# Volumes

|Path|Description|
|----|-----------|
|/cache|Store nginx cache data here|


# Environment variables
|Name|Default|Description|
|----|-------|-----------|
|LISTENPORT|8888|Bind the webserver to this port (useful for host network)|
|UPSTREAM||Include protocol, server address and port for upstream target|
|WORKERS|4|How many nginx worker processes to spawn|
|MAX_EVENTS|1024|How many connections we can handle|
|SENDFILE|on|Turn sendfile kerenel optimization on?|
|TCP_NOPUSH|off|Disable TCP push?|
|CACHE_SIZE|1G|Size of cache on disk|
|CACHE_MEM|10m|Ram size for cache keys|
|CACHE_AGE|365d|When should we auto retire entries?|
|USE_PERFLOG|0|Also logs to /log/access.log if set to 1, useful for [exporting](https://www.martin-helmich.de/en/blog/monitoring-nginx.html)|
|PROXY_CACHE_LOCK|on|Only allow one cache request to the upstream|
|SSL|off|Set to on, to use SSL over the listenport|
|CERTIFICATE|/etc/certs.d/bad.pem|Use this to map in a proper certificate|
|CERTIFICATE_KEY|/etc/certs.d/bad.key|Use this to map in a proper key|


# Resources

* https://www.nginx.com/blog/nginx-caching-guide/
