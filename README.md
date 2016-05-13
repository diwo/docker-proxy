# Dockerized Lightweight Proxy Server
For those times when you forgot to publish a port to the host.

```
Usage: proxy [-t bind_port:remote_host:remote_port | -u bind_port:remote_host:remote_port]...
  -t  Forward a TCP port
  -u  Forward a UDP port
```

## Example
```
docker run -d --name nginx nginx:1.9
docker run -d --name proxy --link nginx -p 8080:8080 diwo/proxy -t 8080:nginx:80
curl http://localhost:8080
```
