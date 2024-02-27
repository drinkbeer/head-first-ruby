require 'mysql2'
require 'benchmark'

def create_client
  Mysql2::Client.new(host: "localhost", username: "root", database: "benchmark")
end

def reset_table(client)
  client.query("UPDATE test_table SET available = 100")
end

def execute_query(client)
  result = client.query("SELECT id, available FROM test_table WHERE available > 0 LIMIT 1")
  unless result.first
    return false # Indicate no rows found
  end
  id = result.first["id"]
  available = result.first["available"]
  client.query("UPDATE test_table SET available = #{available - 1} WHERE id = #{id}")
  true
end

def execute_query_in_transaction(client)
    client.query("START TRANSACTION")
    result = client.query("SELECT id, available FROM test_table WHERE available > 0 LIMIT 1")
    unless result.first
      client.query("ROLLBACK")
      return false # Indicate no rows found
    end
    id = result.first["id"]
    available = result.first["available"]
    client.query("UPDATE test_table SET available = #{available - 1} WHERE id = #{id}")
    client.query("COMMIT")
    true
end
  
def execute_query_skip_locked(client)
    client.query("START TRANSACTION")
    result = client.query("SELECT id, available FROM test_table WHERE available > 0 LIMIT 1 FOR UPDATE SKIP LOCKED")
    unless result.first
      client.query("ROLLBACK")
      return false # Indicate no rows found
    end
    id = result.first["id"]
    available = result.first["available"]
    client.query("UPDATE test_table SET available = #{available - 1} WHERE id = #{id}")
    client.query("COMMIT")
    true
end

def run_task_in_threads(task_name, &block)
  threads = 2.times.map do
    Thread.new do
      client = create_client
      loop do
        break unless block.call(client)
      end
    end
  end
  threads.each(&:join)
end

Benchmark.bm do |x|
  client = create_client
  x.report("baseline") {
    reset_table(client) # Reset table before the test
    run_task_in_threads("baseline") { |client| execute_query(client) }
  }
  x.report("query_in_transaction") {
    reset_table(client) # Reset table before the test
    run_task_in_threads("query_in_transaction") { |client| execute_query_in_transaction(client) }
  }
  x.report("query_skip_locked") {
    reset_table(client) # Reset table before the test
    run_task_in_threads("query_skip_locked") { |client| execute_query_skip_locked(client) }
  }
end
