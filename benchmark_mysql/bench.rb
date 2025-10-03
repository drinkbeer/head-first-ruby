require 'mysql2'
require 'benchmark'

client = Mysql2::Client.new(host: "localhost", username: "root", database: "benchmark")

def execute_query(client)
    result = client.query("SELECT id, available FROM test_table WHERE available > 0 LIMIT 1")
    id = result.first["id"]
    available = result.first["available"]
    client.query("UPDATE test_table SET available = #{available - 1} WHERE id = #{id}")
end

def execute_query_in_transaction(client)
    client.query("START TRANSACTION")
    result = client.query("SELECT id, available FROM test_table WHERE available > 0 LIMIT 1")
    id = result.first["id"]
    available = result.first["available"]
    client.query("UPDATE test_table SET available = #{available - 1} WHERE id = #{id}")
    client.query("COMMIT")
end

def execute_query_skip_locked(client)
    client.query("START TRANSACTION")
    result = client.query("SELECT id, available FROM test_table WHERE available > 0 LIMIT 1 FOR UPDATE SKIP LOCKED")
    id = result.first["id"]
    available = result.first["available"]
    client.query("UPDATE test_table SET available = #{available - 1} WHERE id = #{id}")
    client.query("COMMIT")
end

n=10000
result = Benchmark.bm do |x|
    x.report("baseline") {
        n.times do
            execute_query(client)
        end
    }
    x.report("query_in_transaction") {
        n.times do
            execute_query_in_transaction(client)
        end
    }
    x.report("query_skip_locked") {
        n.times do
            execute_query_skip_locked(client)
        end
    }
end

