##### Container images and mandatory configurations:
    - cuongopswat/go-coffeeshop-web
		REVERSE_PROXY_URL: <proxy_service:port>
		WEB_PORT: 8888

	- cuongopswat/go-coffeeshop-proxy
		APP_NAME: <Any Name>
		GRPC_PRODUCT_HOST: <product service>
		GRPC_PRODUCT_PORT: 5001
		GRPC_COUNTER_HOST: <counter service>
		GRPC_COUNTER_PORT: 5002

	- cuongopswat/go-coffeeshop-barista
		APP_NAME: <Any Name>
		IN_DOCKER: "true"
		PG_URL: <Postgresql connection string>
		PG_DSN_URL: <host=… user=… password=… dbname=… sslmode=disable> sslmode=disable
		RABBITMQ_URL: <RabbitMQ connection string>

	- cuongopswat/go-coffeeshop-kitchen
		APP_NAME: <Any Name>
		IN_DOCKER: "true"
		PG_URL: <Postgresql connection string>
		PG_DSN_URL: <host=… user=… password=… dbname=… sslmode=disable> sslmode=disable
		RABBITMQ_URL: <RabbitMQ connection string>

	- cuongopswat/go-coffeeshop-counter
		APP_NAME:<Any Name>
		IN_DOCKER: "true"
		PG_URL: <Postgresql connection string>
		PG_DSN_URL: <host=… user=… password=… dbname=… sslmode=disable>
		RABBITMQ_URL: <RabbitMQ connection string>
		PRODUCT_CLIENT_URL: <product-service:port>

	- cuongopswat/go-coffeeshop-product
		APP_NAME: <Any Name>
		postgres:14-alpine
		POSTGRES_DB
		POSTGRES_USER
		POSTGRES_PASSWORD

	- rabbitmq:3.11-management-alpine
		RABBITMQ_DEFAULT_USER
		RABBITMQ_DEFAULT_PASS

##### Containers start order:
    1. PostgreSQL:
    2. RabbitMQ:
    3. Product
    4. Counter
    5. The remaining services

##### Port to expose:
    - Postgresql: 5432
	- RabbiMQ: 5672 and 15672
	- proxy: 5000
	- product: 5001
	- counter: 5002
	- web: 8888
---
# Infrastructure as code
1. Resources:
    