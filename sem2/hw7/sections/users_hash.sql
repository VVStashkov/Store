CREATE TABLE users_hash (
    id SERIAL,
    name TEXT,
    email TEXT
) PARTITION BY HASH (id);

CREATE TABLE users_hash_0 PARTITION OF users_hash
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE users_hash_1 PARTITION OF users_hash
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE users_hash_2 PARTITION OF users_hash
    FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE users_hash_3 PARTITION OF users_hash
    FOR VALUES WITH (MODULUS 4, REMAINDER 3);

CREATE INDEX idx_users_hash_id ON users_hash (id);

INSERT INTO users_hash (name, email)
SELECT 'user_' || gs, 'user' || gs || '@example.com'
FROM generate_series(1, 100000) gs;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM users_hash WHERE id = 12345;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM users_hash WHERE id BETWEEN 10000 AND 20000;

DROP TABLE users_hash;