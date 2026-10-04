/*
=============================================================
Create Database and Tables (MySQL version)
=============================================================
Script Purpose:
    This script creates a new database named 'gold' after checking if it already exists.
    If the database exists, it is dropped and recreated.

    NOTE ON SCHEMAS: SQL Server supports a database containing multiple schemas
    (e.g. DataWarehouseAnalytics.gold.table_name). MySQL treats "schema" and
    "database" as the same concept, so there is no separate schema layer.
    To keep the same gold.table_name naming used in the rest of the course,
    this script creates the database itself as "gold".

WARNING:
    Running this script will drop the entire 'gold' database if it exists.
    All data in it will be permanently deleted. Make sure you have backups
    before running this.
*/

-- Drop and recreate the 'gold' database
DROP DATABASE IF EXISTS gold;
CREATE DATABASE gold;

USE gold;

-- Create Tables

CREATE TABLE dim_customers(
    customer_key     INT,
    customer_id      INT,
    customer_number  VARCHAR(50),
    first_name       VARCHAR(50),
    last_name        VARCHAR(50),
    country          VARCHAR(50),
    marital_status   VARCHAR(50),
    gender           VARCHAR(50),
    birthdate        DATE,
    create_date      DATE
);

CREATE TABLE dim_products(
    product_key     INT,
    product_id      INT,
    product_number  VARCHAR(50),
    product_name    VARCHAR(50),
    category_id     VARCHAR(50),
    category        VARCHAR(50),
    subcategory     VARCHAR(50),
    maintenance     VARCHAR(50),
    cost            INT,
    product_line    VARCHAR(50),
    start_date      DATE
);

CREATE TABLE fact_sales(
    order_number    VARCHAR(50),
    product_key     INT,
    customer_key    INT,
    order_date      DATE,
    shipping_date   DATE,
    due_date        DATE,
    sales_amount    INT,
    quantity        TINYINT,
    price           INT
);

-- Load data
-- NOTE: LOAD DATA LOCAL INFILE requires local_infile to be enabled:
--   1) On the server:  SET GLOBAL local_infile = 1;
--   2) In MySQL Workbench: Edit > Preferences > SQL Editor >
--      check "Allow LOAD LOCAL INFILE" > reconnect
-- Adjust the file paths below to match where you actually saved the CSVs.

TRUNCATE TABLE dim_customers;

LOAD DATA LOCAL INFILE 'C:/sql/sql-data-analytics-project/datasets/csv-files/gold.dim_customers.csv'
INTO TABLE dim_customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

TRUNCATE TABLE dim_products;

LOAD DATA LOCAL INFILE 'C:/sql/sql-data-analytics-project/datasets/csv-files/gold.dim_products.csv'
INTO TABLE dim_products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

TRUNCATE TABLE fact_sales;

LOAD DATA LOCAL INFILE 'C:/sql/sql-data-analytics-project/datasets/csv-files/gold.fact_sales.csv'
INTO TABLE fact_sales
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
