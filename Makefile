build:
	docker build -t jasonchen/ruby_app:latest .

start:
ifdef apikey
	make build
	docker run -it --env IPSTACK_API_KEY=$(apikey) --env REDIS_URL=$(redis-url) --env REDIS_PASSWORD=$(redis-password) -p 8080:8080  jasonchen/ruby_app
else
	make build
	docker run jasonchen/ruby_app
	echo "Please mention apikey before you start. Now runs a simple ruby app."
endif

push:
	make build
	# docker push jasonchen/ruby_app
