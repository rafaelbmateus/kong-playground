# Kong Gateway

[Kong gateway](https://github.com/Kong/kong) is a cloud-native, platform-agnostic,
scalable API Gateway distinguished for its high performance and extensibility via plugins.

This repository is an playground to explore kong gateway features.

# Services and Routes Concepts

Kong Gateway administrators work with an object model to define their desired traffic management policies.
Two important objects in that model are services and routes.
Services and routes are configured in a coordinated manner to define the routing path
that requests and responses will take through the system.

![](https://docs.konghq.com/assets/images/docs/getting-started-guide/route-and-service.png)

## What is a service

In Kong Gateway, a service is an abstraction of an existing upstream application.
Services can store collections of objects like plugin configurations, and policies, and they can be associated with routes.

When defining a service, the administrator provides a name and the upstream application connection information.
The connection details can be provided in the url field as a single string, or by providing individual values for protocol, host, port, and path individually.

Services have a one-to-many relationship with upstream applications, which allows administrators to create sophisticated traffic management behaviors.

## What is a route

A route is a path to a resource within an upstream application. Routes are added to services to allow access to the underlying application.
In Kong Gateway, routes typically map to endpoints that are exposed through the Kong Gateway application.
Routes can also define rules that match requests to associated services. Because of this, one route can reference multiple endpoints.
A basic route should have a name, path or paths, and reference an existing service.

You can also configure routes with:
- Protocols: The protocol used to communicate with the upstream application.
- Hosts: Lists of domains that match a route
- Methods: HTTP methods that match a route
- Headers: Lists of values that are expected in the header of a request
- Redirect status codes: HTTPS status codes
- Tags: Optional set of strings to group routes with

See [Routes](https://docs.konghq.com/gateway/3.3.x/key-concepts/routes/) for a description of how Kong Gateway routes requests.

## Managing services and routes

The following tutorial walks through managing and testing services and routes using the Kong Gateway Admin API.
Kong Gateway also offers other options for configuration management including
[Kong Konnect](https://docs.konghq.com/konnect) and [decK](https://docs.konghq.com/deck/latest).

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

This session follow the [get started](https://docs.konghq.com/gateway/3.3.x/get-started) tutorial.

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
