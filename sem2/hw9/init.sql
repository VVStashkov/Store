CREATE TABLE IF NOT EXISTS tasks (
    id BIGSERIAL PRIMARY KEY,
    payload TEXT NOT NULL,
    status SMALLINT NOT NULL DEFAULT 0,      -- 0=ready, 1=running, 2=completed, 3=failed
    priority INT NOT NULL DEFAULT 0,         -- больше = выше приоритет
    attempts INT NOT NULL DEFAULT 0,
    scheduled_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    worker_id TEXT
);

ALTER TABLE tasks SET (
    autovacuum_vacuum_scale_factor = 0.01,
    autovacuum_vacuum_threshold = 100,
    autovacuum_vacuum_cost_delay = 5
    );

-- Индекс для быстрого выбора задач
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_ready ON tasks (status, priority DESC, scheduled_at)
    WHERE status = 0;



CREATE OR REPLACE FUNCTION notify_task_channel() RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('task_channel', NEW.id::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER task_notify_trigger
    AFTER INSERT ON tasks
    FOR EACH ROW
EXECUTE FUNCTION notify_task_channel();
