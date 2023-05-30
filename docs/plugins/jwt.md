# JWT

https://docs.konghq.com/hub/kong-inc/jwt/

## Create a consumer

```console
curl -d "username=user123&custom_id=SOME_CUSTOM_ID" http://localhost:8001/consumers/
```

## Create a JWT credential

```console
curl -X POST http://localhost:8001/consumers/user123/jwt \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "key=Pt2TaOCX7AEmUGIDqkHay1mWNVc12Mw3" | jq
```

Response:

```
HTTP/1.1 201 Created
{
  "algorithm": "HS256",
  "secret": "Pt2TaOCX7AEmUGIDqkHay1mWNVc12Mw3",
  "tags": null,
  "created_at": 1685464582,
  "id": "9f14c093-0a5f-4522-b224-687b5fcacb60",
  "consumer": {
    "id": "712b47c0-8793-4bb0-999b-36775523e25e"
  },
  "key": "wYRSV12Gv1a9H4uchdsVyN69NCS93VUg",
  "rsa_public_key": null
}
```

## List JWT credentials

```console
curl -X GET http://localhost:8001/consumers/user123/jwt | jq
```

## Delete a JWT credential

```console
curl -X DELETE http://localhost:8001/consumers/{consumer}/jwt/{id}
```

## Send a request with the JWT

```console
curl http://localhost:8000/mock/request \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJQdDJUYU9DWDdBRW1VR0lEcWtIYXkxbVdOVmMxMk13MyJ9.7reuMuhPjoZWZVHFjfBujXOX643X-ehYF_2Waccz0Vk'
```
