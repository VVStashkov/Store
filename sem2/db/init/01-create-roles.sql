-- Создание ролей с правом входа
CREATE ROLE app WITH LOGIN PASSWORD 'app_pass';
CREATE ROLE readonly WITH LOGIN PASSWORD 'readonly_pass';

-- Таймауты
ALTER ROLE app SET statement_timeout = '1min';
ALTER ROLE readonly SET statement_timeout = '1min';

-- Права на подключение к базе
GRANT CONNECT ON DATABASE "Warehouse_DB" TO app, readonly;

-- Права на схему warehouse
GRANT USAGE ON SCHEMA warehouse TO app, readonly;

-- Права на существующие объекты
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA warehouse TO app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA warehouse TO app;

GRANT SELECT ON ALL TABLES IN SCHEMA warehouse TO readonly;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA warehouse TO readonly;

-- Права по умолчанию для будущих объектов
ALTER DEFAULT PRIVILEGES IN SCHEMA warehouse GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app;
ALTER DEFAULT PRIVILEGES IN SCHEMA warehouse GRANT USAGE, SELECT ON SEQUENCES TO app;
ALTER DEFAULT PRIVILEGES IN SCHEMA warehouse GRANT SELECT ON TABLES TO readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA warehouse GRANT SELECT ON SEQUENCES TO readonly;