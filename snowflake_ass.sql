-- 1. Create roles as per the below-mentioned hierarchy. Accountadmin
-- already exists in Snowflake .
USE ROLE "ACCOUNTADMIN";

CREATE ROLE "ADMIN";
CREATE ROLE "DEVELOPER";
CREATE ROLE "PII";

GRANT ROLE "DEVELOPER" TO ROLE "ADMIN";
GRANT ROLE "ADMIN" TO ROLE "ACCOUNTADMIN";
GRANT ROLE "PII" TO ROLE "ACCOUNTADMIN";

-- 2. Create an M-sized warehouse using the accountadmin role, name ->
-- assignment_wh and use it for all the queries 

CREATE OR REPLACE WAREHOUSE assignment_wh WITH WAREHOUSE_SIZE='MEDIUM';
GRANT ALL PRIVILEGES ON WAREHOUSE assignment_wh TO ROLE ADMIN;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE "ADMIN";


-- 3  Switch to the admin role 

USE ROLE "ADMIN";


-- 4 Create a database assignment_db 
CREATE OR REPLACE DATABASE assignment_db;

-- 5. Create a schema my_schema

CREATE OR REPLACE schema my_schema;

-- 6. Create a table using any sample csv. You can get 1 by googling for
-- sample csv’s. Preferably search for a sample employee dataset so that
-- you have PII related columns else you can consider any column as PII ( 5
-- ).

CREATE OR REPLACE TABLE EMPLOYEES(
ID NUMBER,
NAME VARCHAR(255),
EMAIL VARCHAR(255),
COUNTRY VARCHAR(255),
REGION VARCHAR(255),
elt_ts TIMESTAMP default current_timestamp(),
elt_by varchar default 'snow',
file_name varchar default 'assignment'
);


-- 7. Also, create a variant version of this dataset 


create table employee_variant_table(
json_data variant
);

create or replace file format json_format
  type = 'json'
  strip_outer_array = true;

COPY INTO employee_variant_table 
FROM @%employee_variant_table file_format = json_format; 

select * from employee_variant_table;

--8 Load the file into an external and internal stage.

CREATE OR REPLACE FILE FORMAT mycsvformat
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1;
  
COPY INTO employees
FROM @%employees file_format = mycsvformat;











