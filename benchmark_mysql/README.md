
```
» ruby benchmark_mysql/bench_lock_contention.rb
       user     system      total        real
baseline  6.775197   8.045739  14.820936 ( 65.740013)
query_in_transaction  8.195094   8.051923  16.247017 ( 69.325575)
query_skip_locked  7.035562  10.381892  17.417454 ( 64.018350)
```