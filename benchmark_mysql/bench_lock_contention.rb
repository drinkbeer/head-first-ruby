require 'mysql2'
require 'benchmark'

def create_client
  Mysql2::Client.new(host: "localhost", username: "root", database: "benchmark")
end

def execute_query(client)
    test_num = 0;
  result = client.query("SELECT id, available FROM test_table WHERE test_num = #{test_num} AND available > 0 LIMIT 1")
  unless result.first
    return false # Indicate no rows found
  end
  id = result.first["id"]
  available = result.first["available"]
  client.query("UPDATE test_table SET available = #{available - 1} WHERE id = #{id}")
  true
end

# The current model
def execute_query_in_transaction(client)
    test_num = 1;
    client.query("START TRANSACTION")
    result = client.query("SELECT id, available FROM test_table WHERE test_num = #{test_num} AND available > 0 LIMIT 1")
    unless result.first
      client.query("ROLLBACK")
      return false
    end
    id = result.first["id"]
    available = result.first["available"]
    client.query("UPDATE test_table SET available = #{available - 1} WHERE id = #{id}")
    client.query("COMMIT")
    true
end

# The current model with SKIP LOCKED
def execute_query_skip_locked(client)
    test_num = 2;
    client.query("START TRANSACTION")
    result = client.query("SELECT id, available FROM test_table WHERE test_num = #{test_num} AND available > 0 LIMIT 1 FOR UPDATE SKIP LOCKED")
    unless result.first
      client.query("ROLLBACK")
      return false
    end
    id = result.first["id"]
    available = result.first["available"]
    client.query("UPDATE test_table SET available = #{available - 1} WHERE id = #{id}")
    client.query("COMMIT")
    true
end

# The new model that have each variant item in one row, for example, if we have 3 variants, each have 100 available, then we have 300 rows
def execute_query_skip_locked_per_row(client)
    test_num = 3;
    client.query("START TRANSACTION")
    result = client.query("SELECT id, available FROM test_table WHERE test_num = #{test_num} AND available > 0 LIMIT 1 FOR UPDATE SKIP LOCKED")
    unless result.first
      client.query("ROLLBACK")
      return false
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
    run_task_in_threads("baseline") { |client| execute_query(client) }
  }
  x.report("query_in_transaction") {
    run_task_in_threads("query_in_transaction") { |client| execute_query_in_transaction(client) }
  }
  x.report("query_skip_locked") {
    run_task_in_threads("query_skip_locked") { |client| execute_query_skip_locked(client) }
  }
  x.report("query_skip_locked_per_row") {
    run_task_in_threads("query_skip_locked_per_row") { |client| execute_query_skip_locked_per_row(client) }
  }
end
