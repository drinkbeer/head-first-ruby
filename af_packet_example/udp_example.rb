require 'socket'
require 'timeout'

# Create a UDP socket
udp_socket = UDPSocket.new

# Bind the socket to a specific address and port (for receiving)
udp_socket.bind('0.0.0.0', 12345)

# Send data
puts "Sending data..."
udp_socket.send("Hello, UDP!", 0, "127.0.0.1", 12345)

# Receive data with a timeout
puts "Waiting to receive data (5 second timeout)..."
begin
  Timeout.timeout(5) do
    data, addr = udp_socket.recvfrom(1024)
    puts "Received data: #{data} from #{addr}"
  end
rescue Timeout::Error
  puts "No data received within the timeout period."
end

# Close the socket
udp_socket.close
