# Kong Gateway

# Running Kong Gateway

To start the kong gateway using docker compose:

```console
make kong
```

Start kong gateway with postgres:

```console
make kong-postgres
```

## Get Started

https://docs.konghq.com/gateway/latest/get-started

```console
curl --head localhost:8001
```

If Kong Gateway is running properly, it will respond with a 200 HTTP code, similar to the following:

```console
HTTP/1.1 200 OK
Date: Mon, 22 Aug 2022 19:25:49 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Access-Control-Allow-Origin: *
Content-Length: 11063
X-Kong-Admin-Latency: 6
Server: kong/3.3.0
```

The root route of the Admin API provides important information about the running Kong Gateway including networking, security, and plugin information. The full configuration is provided in the .configuration key of the returned JSON document.

```console
curl -s localhost:8001 | jq '.configuration'
```

## Services

### Creating a services:

```console
curl -i -s -X POST http://localhost:8001/services \
  --data name=example_service \
  --data url='http://mockbin.org'
```

### Viewing service configuration

```console
curl -X GET http://localhost:8001/services/example_service
```

### Updating services

```console
curl --request PATCH \
  --url localhost:8001/services/example_service \
  --data retries=6
```

### Listing services

```console
curl -X GET http://localhost:8001/services
```

## Routes

### Creating routes

```console
curl -i -X POST http://localhost:8001/services/example_service/routes \
  --data 'paths[]=/mock' \
  --data name=example_route
```

### Viewing route configuration

```console
curl -X GET http://localhost:8001/services/example_service/routes/example_route
```

### Updating routes

```console
curl --request PATCH \
  --url localhost:8001/services/example_service/routes/example_route \
  --data tags="tutorial"
```

### Listing routes

```console
curl http://localhost:8001/routes
```

## Proxy a request

```console
curl -X GET http://localhost:8000/mock/requests
```

## Rate Limiting


### Enable rate limiting

```console
curl -i -X POST http://localhost:8001/plugins \
  --data name=rate-limiting \
  --data config.minute=5 \
  --data config.policy=local
```

Validate rate limiting:

```console
for _ in {1..6}; do curl -s -i localhost:8000/mock/request; echo; sleep 1; done
```

### Service level rate limiting

```console
curl -X POST http://localhost:8001/services/example_service/plugins \
  --data "name=rate-limiting" \
  --data config.minute=5 \
  --data config.policy=local
```

### Route level rate limiting

```console
curl -X POST http://localhost:8001/routes/example_route/plugins \
  --data "name=rate-limiting" \
  --data config.minute=5 \
  --data config.policy=local
```

### Consumer level rate limiting

1. Create a consumer

```console
curl -X POST http://localhost:8001/consumers/ \
  --data username=jsmith
```

2. Enable rate limiting for the consumer

```console
curl -X POST http://localhost:8001/plugins \
  --data "name=rate-limiting" \
  --data "consumer.username=jsmith" \
  --data "config.second=5"
```

## Proxy Caching

https://docs.konghq.com/gateway/3.3.x/get-started/proxy-caching/

### Global proxy caching

1. Enable proxy caching

```console
curl -i -X POST http://localhost:8001/plugins \
  --data "name=proxy-cache" \
  --data "config.request_method=GET" \
  --data "config.response_code=200" \
  --data "config.content_type=application/json; charset=utf-8" \
  --data "config.cache_ttl=30" \
  --data "config.strategy=memory"
```

2. Validate

```console
curl -i -s -X GET http://localhost:8000/mock/requests | grep X-Cache
```

### Service level proxy caching

```console
curl -X POST http://localhost:8001/services/example_service/plugins \
  --data "name=proxy-cache" \
  --data "config.request_method=GET" \
  --data "config.response_code=200" \
  --data "config.content_type=application/json; charset=utf-8" \
  --data "config.cache_ttl=30" \
  --data "config.strategy=memory"
```

### Route level proxy caching

```console
curl -X POST http://localhost:8001/routes/example_route/plugins \
   --data "name=proxy-cache" \
   --data "config.request_method=GET" \
   --data "config.response_code=200" \
   --data "config.content_type=application/json; charset=utf-8" \
   --data "config.cache_ttl=30" \
   --data "config.strategy=memory"
```

### Consumer level proxy caching

1. Create a consumer

```console
curl -X POST http://localhost:8001/consumers/ \
  --data username=sasha
```

2. Enable cache for the consumer

```console
curl -X POST http://localhost:8001/consumers/sasha/plugins \
  --data "name=proxy-cache" \
  --data "config.request_method=GET" \
  --data "config.response_code=200" \
  --data "config.content_type=application/json; charset=utf-8" \
  --data "config.cache_ttl=30" \
  --data "config.strategy=memory"
```

## Key Authentication

### Set up consumers and keys

1. Create a new consumer

```console
curl -i -X POST http://localhost:8001/consumers/ \
  --data username=luka
```

2. Assign the consumer a key

```
curl -i -X POST http://localhost:8001/consumers/luka/key-auth \
  --data key=top-secret-key
```

### Global key authentication

1. Enable key authentication

```console
curl -X POST http://localhost:8001/plugins/ \
    --data "name=key-auth"  \
    --data "config.key_names=apikey"
```

2. Send an unauthenticated request

```console
curl -i http://localhost:8000/mock/request
```

3. Send the wrong key

```console
curl -i http://localhost:8000/mock/request \
  -H 'apikey:bad-key'
```

4. Send a valid request

```console
curl -i http://localhost:8000/mock/request \
  -H 'apikey:top-secret-key'
```
