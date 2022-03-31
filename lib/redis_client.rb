require "redis"

redis = Redis.new
# redis = Redis.new(host: "10.0.1.1", port: 6380, db: 15)
redis.set("mykey", "hello world")
puts redis.get("mykey")
