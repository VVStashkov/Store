SELECT
    EXTRACT(EPOCH FROM (now() - MIN(scheduled_at)))::INT AS lag_seconds,
    COUNT(*) AS pending_count
FROM tasks
WHERE status = 0;

SELECT COUNT(*) AS completed_per_second
FROM tasks
WHERE status = 2
  AND updated_at > now() - interval '1 second';