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

CREATE OR REPLACE TABLE EMPLOYEE(
ID NUMBER,
NAME VARCHAR(255),
EMAIL VARCHAR(255),
COUNTRY VARCHAR(255),
REGION VARCHAR(255),
elt_ts TIMESTAMP default current_timestamp(),
elt_by varchar default 'snow',
file_name varchar default 'assignment'
);


COPY INTO EMPLOYEE(name,email,country,region,ID,elt_ts,elt_by,file_name)
FROM (select $1, $2, $3 , $4 , $5,CURRENT_TIMESTAMP(),'snow','assignment' from @%EMPLOYEE)
FILE_FORMAT = mycsvformat;

select * from employee;

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
  

CREATE OR REPLACE STAGE my_stage
  FILE_FORMAT = mycsvformat;

LIST @my_stage;

SELECT $1, $2, $3 , $4 , $5
FROM '@my_stage/final.csv';


COPY INTO EMPLOYEES_INTERNAL_STAGE(name,email,country,region,ID,elt_ts,elt_by,file_name)
FROM (select $1, $2, $3 , $4 , $5,CURRENT_TIMESTAMP(),'snow','assignment' from @my_stage/final.csv)
FILE_FORMAT = mycsvformat;


select * from employees_internal_stage;


-- Question - 10 and 11
-- Upload any parquet file to the stage location and infer the schema of the file.
--  Run a select query on the staged parquet file without loading it to a snowflake table.
CREATE FILE FORMAT my_parquet_format TYPE = parquet;
CREATE STAGE stage_for_parquet file_format = my_parquet_format;
select * from @stage_for_parquet/final.parquet;


-- 12. Add masking policy to the PII columns such that fields like email,
-- phone number, etc. show as **masked** to a user with the developer role.
-- If the role is PII the value of these columns should be visible ( 15 ).

USE ROLE "ACCOUNTADMIN";

CREATE OR REPLACE MASKING POLICY email_masks AS (val string) RETURNS string ->
  CASE
    WHEN CURRENT_ROLE() IN ('DEVELOPER') THEN '***'
    ELSE val
  END;

ALTER TABLE IF EXISTS employee MODIFY COLUMN email SET MASKING POLICY email_masks;


----------------------------FOR THE DEVLOPER ROLE -------------------------------
USE ROLE "ACCOUNTADMIN";
GRANT ALL PRIVILEGES ON WAREHOUSE assignment_wh TO ROLE "DEVELOPER";
GRANT USAGE ON DATABASE ASSIGNMENT_DB TO ROLE "DEVELOPER";
GRANT USAGE ON SCHEMA "MY_SCHEMA" TO ROLE "DEVELOPER";
GRANT SELECT ON TABLE assignment_db.my_schema.employee TO ROLE "DEVELOPER";

USE ROLE "DEVELOPER";
select * from employee;

-------------------------FOR THE ADMIN ROLE -----------------------------------------------

USE ROLE "ADMIN";
select * from employee;



-------------------------FOR THE PII ROLE -----------------------------------------------

USE ROLE "ACCOUNTADMIN";
GRANT ALL PRIVILEGES ON WAREHOUSE assignment_wh TO ROLE "PII";
GRANT USAGE ON DATABASE ASSIGNMENT_DB TO ROLE "PII";
GRANT USAGE ON SCHEMA "MY_SCHEMA" TO ROLE "PII";
GRANT SELECT ON TABLE assignment_db.my_schema.employee TO ROLE "PII";

USE ROLE "PII";
select * from employee;




