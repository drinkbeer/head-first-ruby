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

puts "ENV['REDIS_HOST']: #{ENV['REDIS_HOST']}"
puts "ENV['REDIS_PORT']: #{ENV['REDIS_PORT']}"

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


app = Rack::Lobster.new
server = TCPServer.new 8080
logger = Logger.new("/var/log/ruby.log")

logger.info("Starting the server, ENV['REDIS_HOST']: #{ENV['REDIS_HOST']}, ENV['REDIS_PORT']: #{ENV['REDIS_PORT']}")
# redis = Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'], db: 15)
redis = Redis.new(:host => ENV["REDIS_HOST"] || "127.0.0.1" , :port => ENV["REDIS_PORT"] || 6379, db: 15)

while session = server.accept
  request = session.gets
  puts request
 
  # 1
  method, full_path = request.split(' ')
  # 2
  path, query = full_path.split('?')
 
  # 3
  status, headers, body = app.call({
    'REQUEST_METHOD' => method,
    'PATH_INFO' => path,
    'QUERY_STRING' => query
  })

  puts "path: #{path[1..-1]}, query: #{query}"
  logger.info("path: #{path[1..-1]}, query: #{query}")

  redis.ping
  redis.set("key", "value")
  logger.info("GET key: #{redis.get("key")}")
 
  session.print "HTTP/1.1 #{status}\r\n"
  headers.each do |key, value|
    session.print "#{key}: #{value}\r\n"
  end
  session.print "\r\n"
  body.each do |part|
    session.print part
  end
  session.close
end

