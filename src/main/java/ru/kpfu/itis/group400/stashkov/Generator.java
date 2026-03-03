package ru.kpfu.itis.group400.stashkov;

import com.github.javafaker.Faker;
import org.postgresql.geometric.PGpoint;
import org.postgresql.util.PGobject;

import java.sql.*;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.ThreadLocalRandom;

public class Generator {

    private static final String URL = "jdbc:postgresql://localhost:5433/Warehouse_DB";
    private static final String USER = "admin";
    private static final String PASSWORD = "admin_pass";

    private static final int CUSTOMER_COUNT = 250_000;
    private static final int PRODUCT_COUNT = 250_000;
    private static final int ORDER_COUNT = 500_000;
    private static final int ORDER_ITEM_COUNT = 1_000_000;
    private static final int EMPLOYEE_COUNT = 20;

    public static void main(String[] args) {
        Faker faker = new Faker(new java.util.Locale("ru"));
        ThreadLocalRandom rand = ThreadLocalRandom.current();

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {
            conn.setAutoCommit(false);
//
//            // 1. Очистка всех таблиц (включая справочные)
//            System.out.println("Truncating all tables...");
//            try (Statement stmt = conn.createStatement()) {
//                stmt.execute("TRUNCATE " +
//                        "warehouse.order_item, " +
//                        "warehouse.customer_order, " +
//                        "warehouse.product_catalog, " +
//                        "warehouse.customer, " +
//                        "warehouse.employee, " +
//                        "warehouse.warehouse, " +
//                        "warehouse.manager, " +
//                        "warehouse.payment_status, " +
//                        "warehouse.product_category, " +
//                        "warehouse.supplier " +
//                        "RESTART IDENTITY CASCADE");
//            }

            // 2. Заполнение справочных таблиц с новыми полями
            System.out.println("Inserting reference data...");

            // supplier (address, contact_person)
            String[] supplierNames = {
                    "ООО \"Овощной двор\"", "ЗАО \"Фруктовый рай\"", "АО \"Молоко\"",
                    "ООО \"Мясной союз\"", "ИП \"Бакалейщик\"", "ООО \"Напитки\""
            };
            String[] supplierPhones = {
                    "+79990001111", "+79990002222", "+79990003333",
                    "+79990004444", "+79990005555", "+79990006666"
            };
            String supplierSql = "INSERT INTO warehouse.supplier (id, organization_name, phone, address, contact_person) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(supplierSql)) {
                for (int i = 0; i < supplierNames.length; i++) {
                    pstmt.setInt(1, i + 1);
                    pstmt.setString(2, supplierNames[i]);
                    pstmt.setString(3, supplierPhones[i]);
                    pstmt.setString(4, faker.address().fullAddress());
                    pstmt.setString(5, faker.name().fullName());
                    pstmt.addBatch();
                }
                pstmt.executeBatch();
            }

            // product_category (description, parent_category_id, created_at)
            String[] categoryNames = {"Овощи", "Фрукты", "Молочные продукты", "Мясные продукты", "Бакалея", "Напитки"};
            String catSql = "INSERT INTO warehouse.product_category (id, name, description, parent_category_id, created_at) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(catSql)) {
                for (int i = 0; i < categoryNames.length; i++) {
                    pstmt.setInt(1, i + 1);
                    pstmt.setString(2, categoryNames[i]);
                    pstmt.setString(3, faker.lorem().sentence());
                    // parent_category_id: пусть первые две без родителя, остальные ссылаются на первую
                    if (i >= 2) {
                        pstmt.setInt(4, 1);
                    } else {
                        pstmt.setNull(4, Types.INTEGER);
                    }
                    pstmt.setTimestamp(5, Timestamp.valueOf(LocalDate.now().minusDays(rand.nextInt(1000)).atStartOfDay()));
                    pstmt.addBatch();
                }
                pstmt.executeBatch();
            }

            // payment_status (description, sort_order, created_at)
            String[] statuses = {"Ожидает", "Оплачено", "В процессе сборки", "Отменено"};
            String statusSql = "INSERT INTO warehouse.payment_status (id, status, description, sort_order, created_at) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(statusSql)) {
                for (int i = 0; i < statuses.length; i++) {
                    pstmt.setInt(1, i + 1);
                    pstmt.setString(2, statuses[i]);
                    pstmt.setString(3, "Description for " + statuses[i]);
                    pstmt.setInt(4, i + 1);
                    pstmt.setTimestamp(5, Timestamp.valueOf(LocalDate.now().minusDays(rand.nextInt(1000)).atStartOfDay()));
                    pstmt.addBatch();
                }
                pstmt.executeBatch();
            }

            // manager (без изменений)
            Object[][] managers = {
                    {1, "Иванов", "Петр", "Сергеевич", "M", Date.valueOf("1995-05-10")},
                    {2, "Смирнова", "Ольга", "Игоревна", "F", Date.valueOf("1993-07-22")},
                    {3, "Козлов", "Андрей", "Васильевич", "M", Date.valueOf("1992-11-08")},
                    {4, "Афанасьев", "Вячеслав", "Дмитриевич", "M", Date.valueOf("1963-10-10")}
            };
            String managerSql = "INSERT INTO warehouse.manager (id, last_name, first_name, patronymic, gender, birth_date) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(managerSql)) {
                for (Object[] m : managers) {
                    pstmt.setInt(1, (int) m[0]);
                    pstmt.setString(2, (String) m[1]);
                    pstmt.setString(3, (String) m[2]);
                    pstmt.setString(4, (String) m[3]);
                    pstmt.setString(5, (String) m[4]);
                    pstmt.setDate(6, (Date) m[5]);
                    pstmt.addBatch();
                }
                pstmt.executeBatch();
            }

            // warehouse (name)
            Object[][] warehouses = {
                    {1, "г. Казань, ул. Ленина, д. 25", 1},
                    {2, "г. Пермь, пр. Мира, д. 42", 2},
                    {3, "г. Москва, ул. Садовая, д. 18", 3},
                    {4, "г. Новосибирск, ул. Бориса Богаткова, д. 266/1", 4}
            };
            String whSql = "INSERT INTO warehouse.warehouse (id, address, manager_id, name) VALUES (?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(whSql)) {
                for (Object[] w : warehouses) {
                    pstmt.setInt(1, (int) w[0]);
                    pstmt.setString(2, (String) w[1]);
                    pstmt.setInt(3, (int) w[2]);
                    pstmt.setString(4, "Склад №" + w[0]); // name
                    pstmt.addBatch();
                }
                pstmt.executeBatch();
            }

            conn.commit();
            System.out.println("Reference data inserted.");

            // 3. Сотрудники (employee) – без изменений
            System.out.println("Inserting employees...");
            String empSql = "INSERT INTO warehouse.employee (warehouse_id, last_name, first_name, patronymic, gender, birth_date) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(empSql)) {
                for (int i = 1; i <= EMPLOYEE_COUNT; i++) {
                    pstmt.setInt(1, rand.nextInt(1, 5));
                    pstmt.setString(2, faker.name().lastName());
                    pstmt.setString(3, faker.name().firstName());
                    pstmt.setString(4, rand.nextDouble() < 0.8 ? faker.name().firstName() : null);
                    pstmt.setString(5, rand.nextBoolean() ? "M" : "F");
                    pstmt.setDate(6, Date.valueOf(LocalDate.ofInstant(
                            faker.date().birthday().toInstant(), ZoneId.systemDefault())));
                    pstmt.addBatch();
                    if (i % 1000 == 0) pstmt.executeBatch();
                }
                pstmt.executeBatch();
                conn.commit();
            }

            // 4. Товары (product_catalog) – без изменений (описание и период уже были в V2)
            System.out.println("Inserting products...");
            String prodSql = "INSERT INTO warehouse.product_catalog (name, category_id, unit_price, unit_of_measure, supplier_id, description, valid_period) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(prodSql)) {
                for (int i = 1; i <= PRODUCT_COUNT; i++) {
                    pstmt.setString(1, "Product " + i);
                    pstmt.setInt(2, rand.nextInt(1, 7));
                    pstmt.setInt(3, rand.nextInt(1, 100001));
                    String uom = switch (rand.nextInt(3)) {
                        case 0 -> "шт";
                        case 1 -> "кг";
                        default -> "мл";
                    };
                    pstmt.setString(4, uom);
                    pstmt.setInt(5, rand.nextInt(1, 7));
                    pstmt.setString(6, faker.lorem().paragraph());

                    LocalDate start = LocalDate.now().minusDays(rand.nextInt(0, 365));
                    LocalDate end = start.plusDays(rand.nextInt(30, 500));
                    PGobject rangeObj = new PGobject();
                    rangeObj.setType("daterange");
                    rangeObj.setValue("[" + start + "," + end + "]");
                    pstmt.setObject(7, rangeObj);

                    pstmt.addBatch();
                    if (i % 10000 == 0) {
                        pstmt.executeBatch();
                        conn.commit();
                        System.out.println("  " + i + " products");
                    }
                }
                pstmt.executeBatch();
                conn.commit();
            }

            // 5. Клиенты (customer) – без изменений (metadata, tags уже были в V2)
            System.out.println("Inserting customers...");
            String custSql = "INSERT INTO warehouse.customer (last_name, first_name, patronymic, email, metadata, tags) " +
                    "VALUES (?, ?, ?, ?, ?::jsonb, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(custSql)) {
                for (int i = 1; i <= CUSTOMER_COUNT; i++) {
                    pstmt.setString(1, faker.name().lastName());
                    pstmt.setString(2, faker.name().firstName());
                    pstmt.setString(3, rand.nextDouble() < 0.8 ? faker.name().firstName() : null);
                    if (rand.nextDouble() < 0.05) {
                        pstmt.setString(4, null);
                    } else {
                        pstmt.setString(4, faker.internet().emailAddress());
                    }

                    String metadata = String.format(
                            "{\"registered\": \"%s\", \"preferences\": {\"newsletter\": %b}}",
                            LocalDate.now().minusDays(rand.nextInt(1000)),
                            rand.nextBoolean()
                    );
                    pstmt.setString(5, metadata);

                    int tagCount = rand.nextInt(4);
                    String[] tags = new String[tagCount];
                    for (int t = 0; t < tagCount; t++) {
                        tags[t] = "tag" + rand.nextInt(1, 6);
                    }
                    Array tagArray = conn.createArrayOf("text", tags);
                    pstmt.setArray(6, tagArray);

                    pstmt.addBatch();
                    if (i % 10000 == 0) {
                        pstmt.executeBatch();
                        conn.commit();
                        System.out.println("  " + i + " customers");
                    }
                }
                pstmt.executeBatch();
                conn.commit();
            }

            // 6. Обновление складов: добавляем координаты (location) – без изменений
            System.out.println("Updating warehouse locations...");
            String updateWhSql = "UPDATE warehouse.warehouse SET location = ? WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(updateWhSql)) {
                for (int i = 1; i <= 4; i++) {
                    double x = rand.nextDouble() * 180 - 90;
                    double y = rand.nextDouble() * 360 - 180;
                    pstmt.setObject(1, new PGpoint(x, y));
                    pstmt.setInt(2, i);
                    pstmt.addBatch();
                }
                pstmt.executeBatch();
                conn.commit();
            }

            // 7. Заказы (customer_order) с order_date и status (без shipping_address)
            System.out.println("Inserting orders...");
            String orderSql = "INSERT INTO warehouse.customer_order (customer_id, employee_id, order_date, status) " +
                    "VALUES (?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(orderSql)) {
                for (int i = 1; i <= ORDER_COUNT; i++) {
                    int custId;
                    if (rand.nextDouble() < 0.7) {
                        custId = rand.nextInt(1, CUSTOMER_COUNT / 10 + 1);
                    } else {
                        custId = rand.nextInt(CUSTOMER_COUNT / 10 + 1, CUSTOMER_COUNT + 1);
                    }
                    int empId = rand.nextInt(1, EMPLOYEE_COUNT + 1);
                    pstmt.setInt(1, custId);
                    pstmt.setInt(2, empId);
                    // order_date: случайная дата в пределах года
                    LocalDate orderDate = LocalDate.now().minusDays(rand.nextInt(365));
                    pstmt.setTimestamp(3, Timestamp.valueOf(orderDate.atStartOfDay()));
                    // status
                    String[] statusesOrder = {"new", "processing", "shipped", "delivered", "cancelled"};
                    pstmt.setString(4, statusesOrder[rand.nextInt(statusesOrder.length)]);
                    pstmt.addBatch();
                    if (i % 10000 == 0) {
                        pstmt.executeBatch();
                        conn.commit();
                        System.out.println("  " + i + " orders");
                    }
                }
                pstmt.executeBatch();
                conn.commit();
            }

            // 8. Позиции заказа (order_item) – только order_id, product_id, quantity (без цены и скидки)
            System.out.println("Inserting order items...");

            // Определяем количество позиций для каждого заказа
            int[] itemsPerOrder = new int[ORDER_COUNT + 1];
            for (int i = 1; i <= ORDER_COUNT; i++) {
                double r = rand.nextDouble();
                if (r < 0.3) {
                    itemsPerOrder[i] = 1;
                } else if (r < 0.7) {
                    itemsPerOrder[i] = 2;
                } else if (r < 0.9) {
                    itemsPerOrder[i] = 3;
                } else {
                    itemsPerOrder[i] = 4;
                }
            }

            String itemSql = "INSERT INTO warehouse.order_item (order_id, product_id, quantity) VALUES (?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(itemSql)) {
                int totalInserted = 0;

                for (int orderId = 1; orderId <= ORDER_COUNT; orderId++) {
                    int count = itemsPerOrder[orderId];
                    if (count == 0) continue;

                    Set<Integer> usedProducts = new HashSet<>();
                    while (usedProducts.size() < count) {
                        int prodId;
                        if (rand.nextDouble() < 0.7) {
                            prodId = rand.nextInt(1, PRODUCT_COUNT / 10 + 1);
                        } else {
                            prodId = rand.nextInt(PRODUCT_COUNT / 10 + 1, PRODUCT_COUNT + 1);
                        }
                        usedProducts.add(prodId);
                    }

                    for (int prodId : usedProducts) {
                        int qty = rand.nextInt(1, 101);
                        pstmt.setInt(1, orderId);
                        pstmt.setInt(2, prodId);
                        pstmt.setInt(3, qty);
                        pstmt.addBatch();
                        totalInserted++;

                        if (totalInserted % 10000 == 0) {
                            pstmt.executeBatch();
                            conn.commit();
                            System.out.println("  " + totalInserted + " order items inserted");
                        }
                    }
                }
                pstmt.executeBatch();
                conn.commit();
                System.out.println("Total order items inserted: " + totalInserted);
            }

            // 9. Добавим примеры записей в log и manager_change_log (чтобы заполнить новые поля)
            System.out.println("Inserting sample log entries...");
            String logSql = "INSERT INTO warehouse.log (table_name, operation_type, delete_time, username) VALUES (?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(logSql)) {
                pstmt.setString(1, "customer");
                pstmt.setString(2, "DELETE");
                pstmt.setTimestamp(3, Timestamp.valueOf(LocalDate.now().atStartOfDay()));
                pstmt.setString(4, "admin");
                pstmt.addBatch();
                pstmt.executeBatch();
                conn.commit();
            }

            String changeLogSql = "INSERT INTO warehouse.manager_change_log (manager_id, old_last_name, old_first_name, change_date, reason) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(changeLogSql)) {
                pstmt.setInt(1, 1);
                pstmt.setString(2, "СтараяФамилия");
                pstmt.setString(3, "СтароеИмя");
                pstmt.setTimestamp(4, Timestamp.valueOf(LocalDate.now().minusDays(1).atStartOfDay()));
                pstmt.setString(5, "Тестовая причина");
                pstmt.addBatch();
                pstmt.executeBatch();
                conn.commit();
            }

            System.out.println("Data generation completed successfully.");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}