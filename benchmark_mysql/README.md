
```
» ruby benchmark_mysql/bench_lock_contention.rb
       user     system      total        real
baseline  2.570898   2.310152   4.881050 ( 27.590617)
query_in_transaction  6.233860   8.312838  14.546698 ( 50.138634)
query_skip_locked  5.764213   9.070295  14.834508 ( 64.298161)
query_skip_locked_per_row 17.291805  24.371933  41.663738 (1001.028541)
```