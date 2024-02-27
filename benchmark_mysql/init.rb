require 'mysql2'

# Connect to the MySQL database
client = Mysql2::Client.new(host: "localhost", username: "root", database: "benchmark")

(1..2000).each do |i|
    row = client.query("SELECT * FROM test_table WHERE id = #{i}").first
    if row
        client.query("DELETE FROM test_table WHERE id = #{i}")
    end

    random_number = rand(1..10000)
    priority_value = "priority#{random_number}"
    available = 100;
    test_num = 0;
    client.query("INSERT INTO test_table (id, priority, available, test_num) VALUES (#{i}, '#{priority_value}', #{available}, #{test_num})")
end

(202001..204000).each do |i|
    row = client.query("SELECT * FROM test_table WHERE id = #{i}").first
    if row
        client.query("DELETE FROM test_table WHERE id = #{i}")
    end

    random_number = rand(1..10000)
    priority_value = "priority#{random_number}"
    available = 100;
    test_num = 1;
    client.query("INSERT INTO test_table (id, priority, available, test_num) VALUES (#{i}, '#{priority_value}', #{available}, #{test_num})")
end

(204001..206000).each do |i|
    row = client.query("SELECT * FROM test_table WHERE id = #{i}").first
    if row
        client.query("DELETE FROM test_table WHERE id = #{i}")
    end

    random_number = rand(1..10000)
    priority_value = "priority#{random_number}"
    available = 100;
    test_num = 1;
    client.query("INSERT INTO test_table (id, priority, available, test_num) VALUES (#{i}, '#{priority_value}', #{available}, #{test_num})")
end

(206001..208000).each do |i|
    row = client.query("SELECT * FROM test_table WHERE id = #{i}").first
    if row
        client.query("DELETE FROM test_table WHERE id = #{i}")
    end

    random_number = rand(1..10000)
    priority_value = "priority#{random_number}"
    available = 100;
    test_num = 2;
    client.query("INSERT INTO test_table (id, priority, available, test_num) VALUES (#{i}, '#{priority_value}', #{available}, #{test_num})")
end

(2001..202000).each do |i|
    row = client.query("SELECT * FROM test_table WHERE id = #{i}").first
    if row
        client.query("DELETE FROM test_table WHERE id = #{i}")
    end

    random_number = rand(1..10000)
    priority_value = "priority##{random_number}"
    available = 1
    test_num = 3
    client.query("INSERT INTO test_table (id, priority, available, test_num) VALUES (#{i}, '#{priority_value}', #{available}, #{test_num})")
end