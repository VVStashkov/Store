CREATE SCHEMA warehouse;

CREATE TABLE warehouse.product_category (
    category_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE warehouse.supplier (
    id INT PRIMARY KEY,
    organization_name VARCHAR(100) NOT NULL
);

CREATE TABLE warehouse.manager (
    id INT PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    patronymic VARCHAR(50),
    gender CHAR(1) CHECK (gender IN ('M', 'F')),
    birth_date DATE
);

CREATE TABLE warehouse.warehouse (
    id INT PRIMARY KEY,
    address VARCHAR(200) NOT NULL,
    district VARCHAR(100),
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES warehouse.manager(id)
);

CREATE TABLE warehouse.customer (
    id INT PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    patronymic VARCHAR(50)
);

CREATE TABLE warehouse.employee (
    id INT PRIMARY KEY,
    warehouse_id INT,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    patronymic VARCHAR(50),
    gender CHAR(1) CHECK (gender IN ('M', 'F')),
    birth_date DATE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouse.warehouse(id)
);

CREATE TABLE warehouse.product (
    id INT PRIMARY KEY,
    category_id INT,
    unit_price DECIMAL(10,2) NOT NULL,
    unit_of_measure VARCHAR(20),
    supplier_id INT,
    warehouse_id INT,
    stock_quantity INT DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES warehouse.product_category(category_id),
    FOREIGN KEY (supplier_id) REFERENCES warehouse.supplier(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouse.warehouse(id)
);

CREATE TABLE warehouse.customer_order (
    id INT PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    warehouse_id INT,
    FOREIGN KEY (customer_id) REFERENCES warehouse.customer(id),
    FOREIGN KEY (employee_id) REFERENCES warehouse.employee(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouse.warehouse(id)
);

CREATE TABLE warehouse.order_item (
    id INT PRIMARY KEY,
    product_id INT,
    order_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (product_id) REFERENCES warehouse.product(id),
    FOREIGN KEY (order_id) REFERENCES warehouse.customer_order(id)
);

CREATE TABLE warehouse.payment (
    order_id INT PRIMARY KEY,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    payment_date DATE NOT NULL,
    FOREIGN KEY (order_id) REFERENCES warehouse.customer_order(id)
);