создаём docker-compose.yaml и запускаем его
```shell
docker exec -it redis-redis-1 redis-cli
```
### 1
```shell
127.0.0.1:6379> HSET student:1 name "Damir" group "11-400" gpa 4.5
(integer) 3
127.0.0.1:6379> HSET student:2 name "Ivan" group "11-401" gpa 3.8
(integer) 3
127.0.0.1:6379> HSET student:3 name "Anna" group "11-400" gpa 4.9
(integer) 3
127.0.0.1:6379> HGETALL student:1
1) "name"
2) "Damir"
3) "group"
4) "11-400"
5) "gpa"
6) "4.5"
127.0.0.1:6379> HGETALL student:2
1) "name"
2) "Ivan"
3) "group"
4) "11-401"
5) "gpa"
6) "3.8"
127.0.0.1:6379> HGETALL student:3
1) "name"
2) "Anna"
3) "group"
4) "11-400"
5) "gpa"
6) "4.9"
```

### 2
```shell
127.0.0.1:6379> ZADD leaderboard 4.5 "Damir"
(integer) 1
127.0.0.1:6379> ZADD leaderboard 3.8 "Ivan"
(integer) 1
127.0.0.1:6379> ZADD leaderboard 4.9 "Anna"
(integer) 1
127.0.0.1:6379> ZREVRANGE leaderboard 0 2 WITHSCORES
1) "Anna"
2) "4.9"
3) "Damir"
4) "4.5"
5) "Ivan"
6) "3.8"
```

### 3
```shell
127.0.0.1:6379> RPUSH tasks "send_email" "resize_image" "notify_user" "backup_db" "update_cache"
(integer) 5
127.0.0.1:6379> LPOP tasks
"send_email"
127.0.0.1:6379> LPOP tasks
"resize_image"
127.0.0.1:6379> LPOP tasks
"notify_user"
127.0.0.1:6379> LRANGE tasks 0 -1
1) "backup_db"
2) "update_cache"
```
0 -1 означает от начала до конца
### 4
```shell
127.0.0.1:6379> SET temp_key "doomed" EX 10
OK
127.0.0.1:6379> TTL temp_key
(integer) 8
127.0.0.1:6379> GET temp_key
(nil)
127.0.0.1:6379> 
```

### 5
```shell
127.0.0.1:6379> HGET student:1 gpa
"4.5"
127.0.0.1:6379> HGET student:2 gpa
"3.8"
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379(TX)>   HINCRBYFLOAT student:1 gpa -0.5
QUEUED
127.0.0.1:6379(TX)>   HINCRBYFLOAT student:2 gpa 0.5
QUEUED
127.0.0.1:6379(TX)> EXEC
1) "4"
2) "4.3"
127.0.0.1:6379> HGET student:1 gpa
"4"
127.0.0.1:6379> HGET student:2 gpa
"4.3"
127.0.0.1:6379> 
```


### 6
первый терминал
```shell
127.0.0.1:6379> SUBSCRIBE news
```
второй терминал
```shell
127.0.0.1:6379> PUBLISH news "Hello from Redis!"
(integer) 1
127.0.0.1:6379> PUBLISH news "Second message"
(integer) 1
127.0.0.1:6379> PUBLISH news "GPA leaderboard updated"
(integer) 1
127.0.0.1:6379> 
```
первый терминал
```shell
1) "subscribe"
2) "news"
3) (integer) 1
1) "message"
2) "news"
3) "Hello from Redis!"
1) "message"
2) "news"
3) "Second message"
1) "message"
2) "news"
3) "GPA leaderboard updated"
```