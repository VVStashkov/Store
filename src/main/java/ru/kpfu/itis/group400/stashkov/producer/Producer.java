package ru.kpfu.itis.group400.stashkov.producer;

import ru.kpfu.itis.group400.stashkov.DbUtil;

import java.sql.*;
import java.util.Random;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class Producer {
    private static final Random random = new Random();
    private static final long TASKS_PER_SECOND = 200;

    public static void main(String[] args) {
        ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
        scheduler.scheduleAtFixedRate(Producer::produceBatch, 0, 1000 / TASKS_PER_SECOND, TimeUnit.MILLISECONDS);
    }

    private static void produceBatch() {
        try (Connection conn = DbUtil.getConnection()) {
            conn.setAutoCommit(false);

            // 2. Вставка задачи
            long orderId = random.nextLong(1_000_000);
            String action = random.nextBoolean() ? "process_order" : "send_notification";
            int priority = random.nextInt(100) < 80 ? random.nextInt(4) : 8 + random.nextInt(3); // 80% низкие, 20% высокие
            String payload = String.format("{\"orderId\":%d, \"items\":%d}", orderId, random.nextInt(10)+1);

            String sql = "INSERT INTO tasks (order_id, action, payload, priority) VALUES (?, ?, ?::jsonb, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setLong(1, orderId);
                stmt.setString(2, action);
                stmt.setString(3, payload);
                stmt.setInt(4, priority);
                stmt.executeUpdate();
            }

            conn.commit();
            // Уведомляем воркеров о новой задаче
            try (Statement notifyStmt = conn.createStatement()) {
                notifyStmt.execute("NOTIFY task_channel");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

}