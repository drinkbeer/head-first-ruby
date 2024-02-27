require 'mysql2'

# Connect to the MySQL database
client = Mysql2::Client.new(host: "localhost", username: "root", database: "benchmark")

1.times do
    random_number = rand(1..10000) # Adjust the range as needed
    priority_value = "priority#{random_number}"
    client.query("INSERT INTO test_table (priority) VALUES ('#{priority_value}')")
end

