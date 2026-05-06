```bash
docker compose up -d
docker exec -it cassandra-node1 cqlsh
```

создание KEYSPACE и переключение на него 
```sql
CREATE KEYSPACE university
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 2};
USE university;
```
создание таблицы
```sql
CREATE TABLE student_grades (
    student_id uuid,
    created_at timestamp,
    subject text,
    grade int,
    PRIMARY KEY (student_id, created_at)
) WITH CLUSTERING ORDER BY (created_at DESC);
```
вставка данных
```sql
-- Студент 1
INSERT INTO student_grades (student_id, created_at, subject, grade)
VALUES (uuid(), toTimestamp(now()), 'Mathematics', 85);

INSERT INTO student_grades (student_id, created_at, subject, grade)
VALUES (uuid(), toTimestamp(now()), 'Physics', 92);

-- Студент 2
INSERT INTO student_grades (student_id, created_at, subject, grade)
VALUES (uuid(), toTimestamp(now()), 'Mathematics', 78);

INSERT INTO student_grades (student_id, created_at, subject, grade)
VALUES (uuid(), toTimestamp(now()), 'Biology', 88);
```
проверка распределеня данных

```sql
SELECT student_id FROM student_grades;
```
```
 student_id
--------------------------------------
 00abf0c4-08db-40d1-98b6-d45de01e2ede
 bf408a5f-ce0a-43fd-8c41-04aedf6d52a6
 85253295-4336-469e-baa9-a999300d66d3
 b924b275-a46c-4baf-bdfc-77cee4a64575
 ```

заменяем <UUID> на конкретный 
```bash
docker exec -it cassandra-node1 nodetool getendpoints university student_grades <UUID>
```

для всех uuid:
```bash
172.24.0.3
172.24.0.2
```
или то же самео в обратном порядке

фильтрация

```bash
cqlsh:university> SELECT * FROM student_grades WHERE subject = 'Mathematics';
InvalidRequest: Error from server: code=2200 [Invalid query] message="Cannot execute this query as it might involve data filtering and thus may have unpredictable performance. If you want to execute this query despite the performance unpredictability, use ALLOW FILTERING"                                                                                        
cqlsh:university>
```
```bash
cqlsh:university> SELECT * FROM university.student_grades WHERE subject = 'Mathematics' ALLOW FILTERING;

 student_id                           | created_at                      | grade | subject
--------------------------------------+---------------------------------+-------+-------------
 bf408a5f-ce0a-43fd-8c41-04aedf6d52a6 | 2026-05-05 18:39:58.615000+0000 |    78 | Mathematics
 b924b275-a46c-4baf-bdfc-77cee4a64575 | 2026-05-05 18:39:40.552000+0000 |    85 | Mathematics

(2 rows)
cqlsh:university> 
```


