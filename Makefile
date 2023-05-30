compose=docker compose

kong:
	$(compose) up -d

kong-postgres:
	KONG_DATABASE=postgres $(compose) --profile database up -d

clean:
	$(compose) kill
	$(compose) rm -f
