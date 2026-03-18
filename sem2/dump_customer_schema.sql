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

SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: customer id; Type: DEFAULT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.customer ALTER COLUMN id SET DEFAULT nextval('warehouse.customer_id_seq'::regclass);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: admin
--

ALTER TABLE ONLY warehouse.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);


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
-- Name: customer archive_customer_trigger; Type: TRIGGER; Schema: warehouse; Owner: admin
--

CREATE TRIGGER archive_customer_trigger BEFORE DELETE ON warehouse.customer FOR EACH ROW EXECUTE FUNCTION warehouse.archive_deleted_customer();


--
-- PostgreSQL database dump complete
--

