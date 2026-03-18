--
-- PostgreSQL database dump
--

-- Dumped from database version 15.16 (Debian 15.16-1.pgdg13+1)
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: warehouse; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA warehouse;


ALTER SCHEMA warehouse OWNER TO admin;

--
-- Name: pageinspect; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pageinspect WITH SCHEMA public;


--
-- Name: EXTENSION pageinspect; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pageinspect IS 'inspect the contents of database pages at a low level';


--
-- Name: add_customer(character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: warehouse; Owner: admin
--

CREATE PROCEDURE warehouse.add_customer(IN p_last_name character varying, IN p_first_name character varying, IN p_patronymic character varying DEFAULT NULL::character varying, IN p_email character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO warehouse.customer 
    (last_name, first_name, patronymic, email)
    VALUES (p_last_name, p_first_name, p_patronymic, p_email);
END;
$$;


ALTER PROCEDURE warehouse.add_customer(IN p_last_name character varying, IN p_first_name character varying, IN p_patronymic character varying, IN p_email character varying) OWNER TO admin;

--
-- Name: add_product(character varying, integer, integer, character varying, integer); Type: PROCEDURE; Schema: warehouse; Owner: admin
--

CREATE PROCEDURE warehouse.add_product(IN p_name character varying, IN p_category_id integer, IN p_unit_price integer, IN p_unit_of_measure character varying, IN p_supplier_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO warehouse.product_catalog (name, category_id, unit_price, unit_of_measure, supplier_id)
    VALUES (p_name, p_category_id, p_unit_price, p_unit_of_measure, p_supplier_id);
END;
$$;


ALTER PROCEDURE warehouse.add_product(IN p_name character varying, IN p_category_id integer, IN p_unit_price integer, IN p_unit_of_measure character varying, IN p_supplier_id integer) OWNER TO admin;

--
-- Name: archive_deleted_customer(); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.archive_deleted_customer() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO warehouse.customer_archive (id, last_name, first_name, patronymic, email)
    VALUES (OLD.id, OLD.last_name, OLD.first_name, OLD.patronymic, OLD.email);
    RETURN OLD;
END;
$$;


ALTER FUNCTION warehouse.archive_deleted_customer() OWNER TO admin;

--
-- Name: audit_batch_inserts(); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.audit_batch_inserts() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE NOTICE 'Выполнена массовая вставка в таблицу %', TG_TABLE_NAME;
    RETURN NULL;
END;
$$;


ALTER FUNCTION warehouse.audit_batch_inserts() OWNER TO admin;

--
-- Name: calculate_factorial(integer); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.calculate_factorial(n integer) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    result BIGINT := 1;
    counter INTEGER := 1;
BEGIN
    IF n < 0 THEN
        RETURN NULL;
    END IF;
    
    WHILE counter <= n LOOP
        result := result * counter;
        counter := counter + 1;
    END LOOP;
    
    RETURN result;
END;

$$;


ALTER FUNCTION warehouse.calculate_factorial(n integer) OWNER TO admin;

--
-- Name: change_price(integer, integer); Type: PROCEDURE; Schema: warehouse; Owner: admin
--

CREATE PROCEDURE warehouse.change_price(IN p_product_id integer, IN p_new_price integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_new_price <= 0 THEN
        RAISE EXCEPTION 'Цена должна быть больше 0';
    END IF;
    
    UPDATE warehouse.product_catalog 
    SET unit_price = p_new_price 
    WHERE id = p_product_id;
    
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Не удлаось обновить цену';
END;
$$;


ALTER PROCEDURE warehouse.change_price(IN p_product_id integer, IN p_new_price integer) OWNER TO admin;

--
-- Name: check_availability(integer); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.check_availability(p_product_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM warehouse.product_inventory 
        WHERE product_id = p_product_id AND stock_quantity > 0
    );
END;
$$;


ALTER FUNCTION warehouse.check_availability(p_product_id integer) OWNER TO admin;

--
-- Name: check_customer_exists(integer); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.check_customer_exists(p_customer_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    customer_exists BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM warehouse.customer WHERE id = p_customer_id
    ) INTO customer_exists;
    
    RETURN customer_exists;
END;
$$;


ALTER FUNCTION warehouse.check_customer_exists(p_customer_id integer) OWNER TO admin;

--
-- Name: check_employee_age(); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.check_employee_age() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXTRACT(YEAR FROM AGE(NEW.birth_date)) < 18 THEN
        RAISE EXCEPTION 'Сотрудник должен быть старше 18 лет';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION warehouse.check_employee_age() OWNER TO admin;

--
-- Name: check_stock_before_order(); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.check_stock_before_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    available_stock INT;
BEGIN
    SELECT stock_quantity INTO available_stock
    FROM warehouse.product_inventory 
    WHERE product_id = NEW.product_id;
    
    IF available_stock < NEW.quantity THEN
        RAISE EXCEPTION 'Недостаточно товара на складе. Доступно: %, запрошено: %', 
            available_stock, NEW.quantity;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION warehouse.check_stock_before_order() OWNER TO admin;

--
-- Name: check_warehouse(integer); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.check_warehouse(p_warehouse_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    wh_count INT;
BEGIN
    SELECT COUNT(*) INTO wh_count
    FROM warehouse.warehouse
    WHERE id = p_warehouse_id;
    
    IF wh_count = 0 THEN
        RAISE EXCEPTION 'Склад не найден';
    END IF;
    
    RAISE NOTICE 'Склад ID % существует', p_warehouse_id;
    RETURN 'OK';
END;
$$;


ALTER FUNCTION warehouse.check_warehouse(p_warehouse_id integer) OWNER TO admin;

--
-- Name: count_products_in_warehouse(integer); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.count_products_in_warehouse(p_warehouse_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    product_count INT;
BEGIN
    SELECT COUNT(*) INTO product_count
    FROM warehouse.product_inventory
    WHERE warehouse_id = p_warehouse_id;
    
    RETURN product_count;
END;
$$;


ALTER FUNCTION warehouse.count_products_in_warehouse(p_warehouse_id integer) OWNER TO admin;

--
-- Name: create_test_orders(integer); Type: PROCEDURE; Schema: warehouse; Owner: admin
--

CREATE PROCEDURE warehouse.create_test_orders(IN p_count integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    i INT := 1;
    customer_id INT;
    employee_id INT;
BEGIN
    SELECT id INTO customer_id FROM warehouse.customer LIMIT 1;
    SELECT id INTO employee_id FROM warehouse.employee LIMIT 1;
    
    WHILE i <= p_count LOOP
        INSERT INTO warehouse.customer_order (customer_id, employee_id)
        VALUES (customer_id, employee_id);
        
        i := i + 1;
    END LOOP;
END;
$$;


ALTER PROCEDURE warehouse.create_test_orders(IN p_count integer) OWNER TO admin;

--
-- Name: delete_customer(integer); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.delete_customer(p_customer_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM warehouse.customer WHERE id = p_customer_id;
    
    RETURN TRUE;
    
EXCEPTION
    WHEN others THEN
        RETURN FALSE;
END;
$$;


ALTER FUNCTION warehouse.delete_customer(p_customer_id integer) OWNER TO admin;

--
-- Name: get_customer_info(integer); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.get_customer_info(p_customer_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (
        SELECT 'Клиент: ' || c.last_name || ' ' || c.first_name || ' ' || c.patronymic ||
               ', Email: ' || COALESCE(c.email, 'нет') || 
               ', Заказов: ' || COUNT(co.id)::TEXT
        FROM warehouse.customer c
        LEFT JOIN warehouse.customer_order co ON c.id = co.customer_id
        WHERE c.id = p_customer_id
        GROUP BY c.id, c.last_name, c.first_name, c.email
    );
END;
$$;


ALTER FUNCTION warehouse.get_customer_info(p_customer_id integer) OWNER TO admin;

--
-- Name: get_order_total(integer); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.get_order_total(p_order_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (
        SELECT SUM(oi.quantity * pc.unit_price)
        FROM warehouse.order_item oi
        JOIN warehouse.product_catalog pc ON oi.product_id = pc.id
        WHERE oi.order_id = p_order_id
    );
END;
$$;


ALTER FUNCTION warehouse.get_order_total(p_order_id integer) OWNER TO admin;

--
-- Name: get_product_price(integer); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.get_product_price(p_product_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    product_price INT;
    product_name VARCHAR(100);
BEGIN
    SELECT unit_price, name INTO product_price, product_name
    FROM warehouse.product_catalog
    WHERE id = p_product_id;
    
    RETURN product_price;
END;
$$;


ALTER FUNCTION warehouse.get_product_price(p_product_id integer) OWNER TO admin;

--
-- Name: log_batch_deletes(); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.log_batch_deletes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO warehouse.batch_delete_log (table_name, operation_type)
    VALUES (TG_TABLE_NAME, TG_OP);
    RETURN NULL;
END;
$$;


ALTER FUNCTION warehouse.log_batch_deletes() OWNER TO admin;

--
-- Name: log_manager_changes(); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.log_manager_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO warehouse.manager_change_log (manager_id, old_last_name, old_first_name)
	VALUES (OLD.id, OLD.last_name, OLD.first_name);
    RETURN NEW;
END;
$$;


ALTER FUNCTION warehouse.log_manager_changes() OWNER TO admin;

--
-- Name: log_new_order(); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.log_new_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DECLARE
        customer_name TEXT;
        employee_name TEXT;
    BEGIN

        SELECT CONCAT(last_name, ' ', first_name) INTO customer_name
        FROM warehouse.customer 
        WHERE id = NEW.customer_id;
        
        SELECT CONCAT(last_name, ' ', first_name) INTO employee_name
        FROM warehouse.employee 
        WHERE id = NEW.employee_id;
        
        INSERT INTO warehouse.order_log (order_id, customer_id, employee_id, log_message)
        VALUES (
            NEW.id,
            NEW.customer_id,
            NEW.employee_id,
            'Создан новый заказ №' || NEW.id || 
            ' от клиента: ' || customer_name || 
            ', оформлен сотрудником: ' || employee_name
        );
    END;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION warehouse.log_new_order() OWNER TO admin;

--
-- Name: rate_customer(integer); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.rate_customer(p_customer_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    order_count INT;
    customer_rating TEXT;
BEGIN
    SELECT COUNT(*) INTO order_count
    FROM warehouse.customer_order
    WHERE customer_id = p_customer_id;
    
    customer_rating := 
        CASE 
            WHEN order_count = 0 THEN 'Новый'
            WHEN order_count BETWEEN 1 AND 5 THEN 'Обычный'
            WHEN order_count BETWEEN 6 AND 15 THEN 'Постоянный'
            ELSE 'VIP'
        END;
    
    RETURN customer_rating;
END;
$$;


ALTER FUNCTION warehouse.rate_customer(p_customer_id integer) OWNER TO admin;

--
-- Name: update_order_total_on_insert(); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.update_order_total_on_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE warehouse.payment
    SET amount = COALESCE(amount, 0) + 
        (SELECT unit_price FROM warehouse.product_catalog WHERE id = NEW.product_id) * NEW.quantity
    WHERE order_id = NEW.order_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION warehouse.update_order_total_on_insert() OWNER TO admin;

--
-- Name: update_price_modification_date(); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.update_price_modification_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.unit_price != OLD.unit_price THEN
        NEW.last_price_change = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION warehouse.update_price_modification_date() OWNER TO admin;

--
-- Name: update_stock(integer, integer, integer); Type: PROCEDURE; Schema: warehouse; Owner: admin
--

CREATE PROCEDURE warehouse.update_stock(IN p_product_id integer, IN p_warehouse_id integer, IN p_quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE warehouse.product_inventory 
    SET stock_quantity = p_quantity
    WHERE product_id = p_product_id AND warehouse_id = p_warehouse_id;
    
    IF NOT FOUND THEN
        INSERT INTO warehouse.product_inventory (product_id, warehouse_id, stock_quantity)
        VALUES (p_product_id, p_warehouse_id, p_quantity);
    END IF;
END;
$$;


ALTER PROCEDURE warehouse.update_stock(IN p_product_id integer, IN p_warehouse_id integer, IN p_quantity integer) OWNER TO admin;

--
-- Name: update_stock_after_sale(); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.update_stock_after_sale() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE warehouse.product_inventory 
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION warehouse.update_stock_after_sale() OWNER TO admin;

--
-- Name: validate_email(character varying); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.validate_email(p_email character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_email IS NULL THEN
		RAISE EXCEPTION 'Некорректный email';
        
    END IF;
    
    IF p_email LIKE '%@%' THEN
		RAISE NOTICE 'Email прошел проверку';
        RETURN TRUE;
	ELSE 
		RAISE NOTICE 'Email прошел проверку';
		RETURN FALSE;
    END IF;
    
    
END;
$$;


ALTER FUNCTION warehouse.validate_email(p_email character varying) OWNER TO admin;

--
-- Name: validate_order(integer, integer); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.validate_order(p_customer_id integer, p_product_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    customer_exists BOOLEAN;
    product_exists BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM warehouse.customer WHERE id = p_customer_id) 
    INTO customer_exists;
    
    SELECT EXISTS(SELECT 1 FROM warehouse.product_catalog WHERE id = p_product_id) 
    INTO product_exists;
    
    IF NOT customer_exists THEN
        RETURN 'Ошибка: Клиент не найден';
    END IF;
    
    IF NOT product_exists THEN
        RETURN 'Ошибка: Товар не найден';
    END IF;
    
    RETURN 'Заказ может быть создан';
END;
$$;


ALTER FUNCTION warehouse.validate_order(p_customer_id integer, p_product_id integer) OWNER TO admin;

--
-- Name: validate_payment_status_change(); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.validate_payment_status_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD.status IS NOT NULL AND NEW.status != OLD.status THEN
        IF OLD.status = 2 AND NEW.status = 1 THEN
            RAISE EXCEPTION 'Нельзя изменить статус с "Оплачено" на "Ожидание"';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION warehouse.validate_payment_status_change() OWNER TO admin;

--
-- Name: validate_product_price(); Type: FUNCTION; Schema: warehouse; Owner: admin
--

CREATE FUNCTION warehouse.validate_product_price() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.unit_price < 0 THEN
        RAISE EXCEPTION 'Цена товара не может быть отрицательной. Указано: %', NEW.unit_price;
    END IF;
    
    IF NEW.unit_price IS NULL THEN
        RAISE EXCEPTION 'Цена товара не может быть NULL';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION warehouse.validate_product_price() OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_schema_history OWNER TO admin;

--
-- Name: customer; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.customer (
    id integer NOT NULL,
    last_name character varying(50) NOT NULL,
    first_name character varying(50) NOT NULL,
    patronymic character varying(50),
    email character varying(100),
    metadata jsonb,
    tags text[]
);


ALTER TABLE warehouse.customer OWNER TO admin;

--
-- Name: customer_archive; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.customer_archive (
    id integer,
    last_name character varying(50),
    first_name character varying(50),
    patronymic character varying(50),
    email character varying(100),
    archive_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE warehouse.customer_archive OWNER TO admin;

--
-- Name: customer_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: admin
--

CREATE SEQUENCE warehouse.customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.customer_id_seq OWNER TO admin;

--
-- Name: customer_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: admin
--

ALTER SEQUENCE warehouse.customer_id_seq OWNED BY warehouse.customer.id;


--
-- Name: customer_order; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.customer_order (
    id integer NOT NULL,
    customer_id integer,
    employee_id integer,
    order_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'new'::character varying
);


ALTER TABLE warehouse.customer_order OWNER TO admin;

--
-- Name: customer_order_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: admin
--

CREATE SEQUENCE warehouse.customer_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.customer_order_id_seq OWNER TO admin;

--
-- Name: customer_order_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: admin
--

ALTER SEQUENCE warehouse.customer_order_id_seq OWNED BY warehouse.customer_order.id;


--
-- Name: employee; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.employee (
    id integer NOT NULL,
    warehouse_id integer NOT NULL,
    last_name character varying(50) NOT NULL,
    first_name character varying(50) NOT NULL,
    patronymic character varying(50),
    gender character(1),
    birth_date date,
    CONSTRAINT employee_gender_check CHECK ((gender = ANY (ARRAY['M'::bpchar, 'F'::bpchar])))
);


ALTER TABLE warehouse.employee OWNER TO admin;

--
-- Name: employee_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: admin
--

CREATE SEQUENCE warehouse.employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.employee_id_seq OWNER TO admin;

--
-- Name: employee_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: admin
--

ALTER SEQUENCE warehouse.employee_id_seq OWNED BY warehouse.employee.id;


--
-- Name: log; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.log (
    id integer NOT NULL,
    table_name text,
    operation_type text,
    delete_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    username character varying(100)
);


ALTER TABLE warehouse.log OWNER TO admin;

--
-- Name: log_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: admin
--

CREATE SEQUENCE warehouse.log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.log_id_seq OWNER TO admin;

--
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: admin
--

ALTER SEQUENCE warehouse.log_id_seq OWNED BY warehouse.log.id;


--
-- Name: manager; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.manager (
    id integer NOT NULL,
    last_name character varying(50) NOT NULL,
    first_name character varying(50) NOT NULL,
    patronymic character varying(50),
    gender character(1),
    birth_date date,
    CONSTRAINT manager_gender_check CHECK ((gender = ANY (ARRAY['M'::bpchar, 'F'::bpchar])))
);


ALTER TABLE warehouse.manager OWNER TO admin;

--
-- Name: manager_change_log; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.manager_change_log (
    manager_id integer NOT NULL,
    old_last_name character varying(50),
    old_first_name character varying(50),
    change_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reason text
);


ALTER TABLE warehouse.manager_change_log OWNER TO admin;

--
-- Name: manager_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: admin
--

CREATE SEQUENCE warehouse.manager_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.manager_id_seq OWNER TO admin;

--
-- Name: manager_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: admin
--

ALTER SEQUENCE warehouse.manager_id_seq OWNED BY warehouse.manager.id;


--
-- Name: order_item; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.order_item (
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT order_item_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE warehouse.order_item OWNER TO admin;

--
-- Name: order_log; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.order_log (
    log_id integer NOT NULL,
    order_id integer NOT NULL,
    customer_id integer NOT NULL,
    employee_id integer NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    log_message text
);


ALTER TABLE warehouse.order_log OWNER TO admin;

--
-- Name: order_log_log_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: admin
--

CREATE SEQUENCE warehouse.order_log_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.order_log_log_id_seq OWNER TO admin;

--
-- Name: order_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: admin
--

ALTER SEQUENCE warehouse.order_log_log_id_seq OWNED BY warehouse.order_log.log_id;


--
-- Name: payment; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.payment (
    order_id integer NOT NULL,
    amount integer NOT NULL,
    status integer,
    payment_date date,
    comment text
);


ALTER TABLE warehouse.payment OWNER TO admin;

--
-- Name: payment_status; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.payment_status (
    id integer NOT NULL,
    status character varying(20) NOT NULL,
    description text,
    sort_order integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE warehouse.payment_status OWNER TO admin;

--
-- Name: payment_status_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: admin
--

CREATE SEQUENCE warehouse.payment_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.payment_status_id_seq OWNER TO admin;

--
-- Name: payment_status_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: admin
--

ALTER SEQUENCE warehouse.payment_status_id_seq OWNED BY warehouse.payment_status.id;


--
-- Name: product_catalog; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.product_catalog (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    category_id integer,
    unit_price integer NOT NULL,
    unit_of_measure character varying(20),
    supplier_id integer,
    last_price_change timestamp without time zone,
    valid_period daterange,
    description text
);


ALTER TABLE warehouse.product_catalog OWNER TO admin;

--
-- Name: product_catalog_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: admin
--

CREATE SEQUENCE warehouse.product_catalog_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.product_catalog_id_seq OWNER TO admin;

--
-- Name: product_catalog_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: admin
--

ALTER SEQUENCE warehouse.product_catalog_id_seq OWNED BY warehouse.product_catalog.id;


--
-- Name: product_category; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.product_category (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    parent_category_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE warehouse.product_category OWNER TO admin;

--
-- Name: product_category_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: admin
--

CREATE SEQUENCE warehouse.product_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.product_category_id_seq OWNER TO admin;

--
-- Name: product_category_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: admin
--

ALTER SEQUENCE warehouse.product_category_id_seq OWNED BY warehouse.product_category.id;


--
-- Name: product_inventory; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.product_inventory (
    product_id integer NOT NULL,
    warehouse_id integer NOT NULL,
    stock_quantity integer DEFAULT 0
);


ALTER TABLE warehouse.product_inventory OWNER TO admin;

--
-- Name: supplier; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.supplier (
    id integer NOT NULL,
    organization_name character varying(100) NOT NULL,
    phone character varying(20),
    address text,
    contact_person character varying(100)
);


ALTER TABLE warehouse.supplier OWNER TO admin;

--
-- Name: supplier_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: admin
--

CREATE SEQUENCE warehouse.supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.supplier_id_seq OWNER TO admin;

--
-- Name: supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: admin
--

ALTER SEQUENCE warehouse.supplier_id_seq OWNED BY warehouse.supplier.id;


--
-- Name: warehouse; Type: TABLE; Schema: warehouse; Owner: admin
--

CREATE TABLE warehouse.warehouse (
    id integer NOT NULL,
    address character varying(200) NOT NULL,
    manager_id integer,
    location point,
    name character varying(100)
);


ALTER TABLE warehouse.warehouse OWNER TO admin;

--
-- Name: warehouse_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: admin
--

CREATE SEQUENCE warehouse.warehouse_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.warehouse_id_seq OWNER TO admin;

--
-- Name: warehouse_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: admin
--

ALTER SEQUENCE warehouse.warehouse_id_seq OWNED BY warehouse.warehouse.id;


--
-- Name: customer id; Type: DEFAULT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.customer ALTER COLUMN id SET DEFAULT nextval('warehouse.customer_id_seq'::regclass);


--
-- Name: customer_order id; Type: DEFAULT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.customer_order ALTER COLUMN id SET DEFAULT nextval('warehouse.customer_order_id_seq'::regclass);


--
-- Name: employee id; Type: DEFAULT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.employee ALTER COLUMN id SET DEFAULT nextval('warehouse.employee_id_seq'::regclass);


--
-- Name: log id; Type: DEFAULT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.log ALTER COLUMN id SET DEFAULT nextval('warehouse.log_id_seq'::regclass);


--
-- Name: manager id; Type: DEFAULT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.manager ALTER COLUMN id SET DEFAULT nextval('warehouse.manager_id_seq'::regclass);


--
-- Name: order_log log_id; Type: DEFAULT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.order_log ALTER COLUMN log_id SET DEFAULT nextval('warehouse.order_log_log_id_seq'::regclass);


--
-- Name: payment_status id; Type: DEFAULT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.payment_status ALTER COLUMN id SET DEFAULT nextval('warehouse.payment_status_id_seq'::regclass);


--
-- Name: product_catalog id; Type: DEFAULT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.product_catalog ALTER COLUMN id SET DEFAULT nextval('warehouse.product_catalog_id_seq'::regclass);


--
-- Name: product_category id; Type: DEFAULT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.product_category ALTER COLUMN id SET DEFAULT nextval('warehouse.product_category_id_seq'::regclass);


--
-- Name: supplier id; Type: DEFAULT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.supplier ALTER COLUMN id SET DEFAULT nextval('warehouse.supplier_id_seq'::regclass);


--
-- Name: warehouse id; Type: DEFAULT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.warehouse ALTER COLUMN id SET DEFAULT nextval('warehouse.warehouse_id_seq'::regclass);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: customer_order customer_order_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.customer_order
    ADD CONSTRAINT customer_order_pkey PRIMARY KEY (id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (id);


--
-- Name: log log_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


--
-- Name: manager_change_log manager_change_log_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.manager_change_log
    ADD CONSTRAINT manager_change_log_pkey PRIMARY KEY (manager_id);


--
-- Name: manager manager_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.manager
    ADD CONSTRAINT manager_pkey PRIMARY KEY (id);


--
-- Name: order_log order_log_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.order_log
    ADD CONSTRAINT order_log_pkey PRIMARY KEY (log_id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (order_id);


--
-- Name: payment_status payment_status_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.payment_status
    ADD CONSTRAINT payment_status_pkey PRIMARY KEY (id);


--
-- Name: payment_status payment_status_status_key; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.payment_status
    ADD CONSTRAINT payment_status_status_key UNIQUE (status);


--
-- Name: product_catalog product_catalog_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.product_catalog
    ADD CONSTRAINT product_catalog_pkey PRIMARY KEY (id);


--
-- Name: product_category product_category_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.product_category
    ADD CONSTRAINT product_category_pkey PRIMARY KEY (id);


--
-- Name: product_inventory product_inventory_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.product_inventory
    ADD CONSTRAINT product_inventory_pkey PRIMARY KEY (product_id, warehouse_id);


--
-- Name: supplier supplier_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (id);


--
-- Name: warehouse warehouse_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.warehouse
    ADD CONSTRAINT warehouse_pkey PRIMARY KEY (id);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: customer_last_name; Type: INDEX; Schema: warehouse; Owner: admin
--

CREATE INDEX customer_last_name ON warehouse.customer USING btree (last_name);


--
-- Name: customer_on_email_btree; Type: INDEX; Schema: warehouse; Owner: admin
--

CREATE INDEX customer_on_email_btree ON warehouse.customer USING btree (email);


--
-- Name: customer_on_email_hash; Type: INDEX; Schema: warehouse; Owner: admin
--

CREATE INDEX customer_on_email_hash ON warehouse.customer USING hash (email);


--
-- Name: idx_customer_metadata; Type: INDEX; Schema: warehouse; Owner: admin
--

CREATE INDEX idx_customer_metadata ON warehouse.customer USING gin (metadata);


--
-- Name: idx_customer_tags; Type: INDEX; Schema: warehouse; Owner: admin
--

CREATE INDEX idx_customer_tags ON warehouse.customer USING gin (tags);


--
-- Name: idx_product_description; Type: INDEX; Schema: warehouse; Owner: admin
--

CREATE INDEX idx_product_description ON warehouse.product_catalog USING gin (to_tsvector('english'::regconfig, description));


--
-- Name: idx_product_valid_period; Type: INDEX; Schema: warehouse; Owner: admin
--

CREATE INDEX idx_product_valid_period ON warehouse.product_catalog USING gist (valid_period);


--
-- Name: order_item_on_product_id_btree; Type: INDEX; Schema: warehouse; Owner: admin
--

CREATE INDEX order_item_on_product_id_btree ON warehouse.order_item USING btree (product_id);


--
-- Name: product_catalog_on_category_id_btree; Type: INDEX; Schema: warehouse; Owner: admin
--

CREATE INDEX product_catalog_on_category_id_btree ON warehouse.product_catalog USING btree (category_id);


--
-- Name: product_catalog_on_category_id_hash; Type: INDEX; Schema: warehouse; Owner: admin
--

CREATE INDEX product_catalog_on_category_id_hash ON warehouse.product_catalog USING hash (category_id);


--
-- Name: customer archive_customer_trigger; Type: TRIGGER; Schema: warehouse; Owner: admin
--

CREATE TRIGGER archive_customer_trigger BEFORE DELETE ON warehouse.customer FOR EACH ROW EXECUTE FUNCTION warehouse.archive_deleted_customer();


--
-- Name: product_inventory audit_batch_inserts_trigger; Type: TRIGGER; Schema: warehouse; Owner: admin
--

CREATE TRIGGER audit_batch_inserts_trigger AFTER INSERT ON warehouse.product_inventory FOR EACH STATEMENT EXECUTE FUNCTION warehouse.audit_batch_inserts();


--
-- Name: employee check_employee_age_trigger; Type: TRIGGER; Schema: warehouse; Owner: admin
--

CREATE TRIGGER check_employee_age_trigger BEFORE INSERT OR UPDATE ON warehouse.employee FOR EACH ROW EXECUTE FUNCTION warehouse.check_employee_age();


--
-- Name: order_item check_stock_trigger; Type: TRIGGER; Schema: warehouse; Owner: admin
--

CREATE TRIGGER check_stock_trigger BEFORE INSERT ON warehouse.order_item FOR EACH ROW EXECUTE FUNCTION warehouse.check_stock_before_order();


--
-- Name: manager log_manager_changes_trigger; Type: TRIGGER; Schema: warehouse; Owner: admin
--

CREATE TRIGGER log_manager_changes_trigger AFTER UPDATE ON warehouse.manager FOR EACH ROW EXECUTE FUNCTION warehouse.log_manager_changes();


--
-- Name: customer_order log_new_order_trigger; Type: TRIGGER; Schema: warehouse; Owner: admin
--

CREATE TRIGGER log_new_order_trigger AFTER INSERT ON warehouse.customer_order FOR EACH ROW EXECUTE FUNCTION warehouse.log_new_order();


--
-- Name: order_item update_order_total_insert_trigger; Type: TRIGGER; Schema: warehouse; Owner: admin
--

CREATE TRIGGER update_order_total_insert_trigger AFTER INSERT ON warehouse.order_item FOR EACH ROW EXECUTE FUNCTION warehouse.update_order_total_on_insert();


--
-- Name: product_catalog update_price_date_trigger; Type: TRIGGER; Schema: warehouse; Owner: admin
--

CREATE TRIGGER update_price_date_trigger BEFORE UPDATE ON warehouse.product_catalog FOR EACH ROW EXECUTE FUNCTION warehouse.update_price_modification_date();


--
-- Name: order_item update_stock_after_sale_trigger; Type: TRIGGER; Schema: warehouse; Owner: admin
--

CREATE TRIGGER update_stock_after_sale_trigger AFTER INSERT ON warehouse.order_item FOR EACH ROW EXECUTE FUNCTION warehouse.update_stock_after_sale();


--
-- Name: payment validate_payment_status_trigger; Type: TRIGGER; Schema: warehouse; Owner: admin
--

CREATE TRIGGER validate_payment_status_trigger BEFORE UPDATE ON warehouse.payment FOR EACH ROW EXECUTE FUNCTION warehouse.validate_payment_status_change();


--
-- Name: product_catalog validate_product_price_trigger; Type: TRIGGER; Schema: warehouse; Owner: admin
--

CREATE TRIGGER validate_product_price_trigger BEFORE INSERT OR UPDATE ON warehouse.product_catalog FOR EACH ROW EXECUTE FUNCTION warehouse.validate_product_price();


--
-- Name: customer_order customer_order_customer_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.customer_order
    ADD CONSTRAINT customer_order_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES warehouse.customer(id);


--
-- Name: customer_order customer_order_employee_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.customer_order
    ADD CONSTRAINT customer_order_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES warehouse.employee(id);


--
-- Name: employee employee_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.employee
    ADD CONSTRAINT employee_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES warehouse.warehouse(id);


--
-- Name: order_item order_item_order_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.order_item
    ADD CONSTRAINT order_item_order_id_fkey FOREIGN KEY (order_id) REFERENCES warehouse.customer_order(id);


--
-- Name: order_item order_item_product_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.order_item
    ADD CONSTRAINT order_item_product_id_fkey FOREIGN KEY (product_id) REFERENCES warehouse.product_catalog(id);


--
-- Name: payment payment_order_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.payment
    ADD CONSTRAINT payment_order_id_fkey FOREIGN KEY (order_id) REFERENCES warehouse.customer_order(id);


--
-- Name: payment payment_status_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.payment
    ADD CONSTRAINT payment_status_fkey FOREIGN KEY (status) REFERENCES warehouse.payment_status(id);


--
-- Name: product_catalog product_catalog_category_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.product_catalog
    ADD CONSTRAINT product_catalog_category_id_fkey FOREIGN KEY (category_id) REFERENCES warehouse.product_category(id);


--
-- Name: product_catalog product_catalog_supplier_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.product_catalog
    ADD CONSTRAINT product_catalog_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES warehouse.supplier(id);


--
-- Name: product_category product_category_parent_category_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.product_category
    ADD CONSTRAINT product_category_parent_category_id_fkey FOREIGN KEY (parent_category_id) REFERENCES warehouse.product_category(id);


--
-- Name: product_inventory product_inventory_product_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.product_inventory
    ADD CONSTRAINT product_inventory_product_id_fkey FOREIGN KEY (product_id) REFERENCES warehouse.product_catalog(id);


--
-- Name: product_inventory product_inventory_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.product_inventory
    ADD CONSTRAINT product_inventory_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES warehouse.warehouse(id);


--
-- Name: warehouse warehouse_manager_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.warehouse
    ADD CONSTRAINT warehouse_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES warehouse.manager(id);


--
-- PostgreSQL database dump complete
--

