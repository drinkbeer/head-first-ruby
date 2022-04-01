require "redis"

# puts "Hello from ruby-redis!"

# # redis = Redis.new
# redis = Redis.new(host: "my-release-redis-master", port: 6379, db: 15)
# redis.set("mykey", "hello world")
# puts redis.get("mykey")


# require 'socket'

# port_to_listen_to = 8080

# puts "starting to listen to: #{port_to_listen_to}"
# server = TCPServer.open(port_to_listen_to)
# loop {
#   client = server.accept

#   puts 'receiving data ' + Time.now.ctime
#   puts '--------------------------------------------------------------------------------'
#   while (a = client.gets) != "\r\n" do
#     puts a
#   end

#   puts '--------------------------------------------------------------------------------'


#   client.puts "HTTP/1.1 200 Success"
#   client.puts ""
#   client.puts "Success\n"
#   client.close
# }

# puts "ENV['REDIS_HOST']: #{ENV['REDIS_HOST']}"
# puts "ENV['REDIS_PORT']: #{ENV['REDIS_PORT']}"

# while session = server.accept
#     request = session.gets
#     puts request
   
#     session.print "HTTP/1.1 200\r\n" # 1
#     session.print "Content-Type: text/html\r\n" # 2
#     session.print "\r\n" # 3
#     session.print "Hello world! The time is #{Time.now}" #4
   
#     session.close
# end


# http_server.rb
require 'socket'
require 'rack'
require 'rack/lobster'
require "logger"


# app = Rack::Lobster.new
app = Proc.new do
  ['200', {'Content-Type' => 'text/html'}, ["Hello Redis and Ruby! The time is #{Time.now} \r\n"]]
end
server = TCPServer.new 8080
logger = Logger.new(STDOUT)

logger.info("Starting the server, ENV['REDIS_HOST']: #{ENV['REDIS_HOST']}, ENV['REDIS_PORT']: #{ENV['REDIS_PORT']}")
# redis = Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'], db: 15)
redis = Redis.new(:host => ENV["REDIS_HOST"] || "127.0.0.1" , :port => ENV["REDIS_PORT"] || 6379, db: 15)

while session = server.accept
  request = session.gets
  # puts request
  logger.info("request: #{request}")
 
  # 1
  method, full_path = request.split(' ')
  # 2
  path, query = full_path.split('?')
  path = path[1..-1]
 
  # 3
  # status, headers, body = app.call({
  #   'REQUEST_METHOD' => method,
  #   'PATH_INFO' => path,
  #   'QUERY_STRING' => query
  # })
  status, headers, body = app.call({})

  # puts "path: #{path[1..-1]}, query: #{query}"
  logger.info("method: #{method}, path: #{path}, query: #{query}, status: #{status}, headers: #{headers}, body: #{body}")

  # redis.ping
  # redis.set("key", "value")
  # logger.info("Set key successful. GET key: #{redis.get("key")}")
 
  session.print "HTTP/1.1 #{status}\r\n"
  headers.each do |key, value|
    session.puts "#{key}: #{value}\r\n"
  end
  session.print "\r\n"
  body.each do |part|
    session.puts part
  end

  str = ""
  if path.empty?
    redis.ping
    str = "PING redis successful!"
  else
    if path == "GET"
      result = redis.get(query)
      if result.nil?
        str = "GET #{query} successful! The key doesn't exist in redis."
      else
        str = "GET #{query} successful! The value: #{result}"
      end
    else
      if path == "SET"
        key, value = query.split("=")
        redis.set(key, value)
        str = "SET key #{key}, value #{value} successful!"
      end
    end
  end
  session.puts "\n     #{str}"
  session.close
end

