# Snowflake_Assignment

The `Snowflake_Assignment.sql` contains all the sql statements, which i ran for solving various queries in `snowsight`.
Please note that `Snowflake_Assignment.sql` doesnot contain all the commands as we have ran some commands from `snowsql`(These were alson present in `Snowflake_Assignment.sql` file but they are commented with tag "This must be run from snowsight").

The commands, approach and datasets to various queries are as explained below -

### Question - 1

Create roles as per the below-mentioned hierarchy. Accountadmin already exists in Snowflake.

<img width="244" alt="" src="https://user-images.githubusercontent.com/123494344/230756822-0a3d9ec8-c756-42ab-900d-f5c130bc59b8.png">

### Approach -

We have created the roles using SQL command stated above with given contraints. The below is the code snippet which does the above said things.

```
USE ROLE "SECURITYADMIN";

CREATE ROLE "ADMIN";
CREATE ROLE "DEVELOPER";
CREATE ROLE "PII";

GRANT ROLE "DEVELOPER" TO ROLE "ADMIN";
GRANT ROLE "ADMIN" TO ROLE "ACCOUNTADMIN";
GRANT ROLE "PII" TO ROLE "ACCOUNTADMIN";
```

### Question - 2

Create an M-sized warehouse using the accountadmin role, name -> assignment_wh and use it for all the queries.

### Approach -

We have created the warehouse using SQL command stated above with given contraints. The below is the code snippet which does the above said things.

```
CREATE OR REPLACE WAREHOUSE assignment_wh WITH WAREHOUSE_SIZE='MEDIUM';

```

### Granting privileges -

As we created new roles we need to give it some privileges as they are required to run some functional queries.

### Approach -


```
GRANT ALL PRIVILEGES ON WAREHOUSE assignment_wh TO ROLE ADMIN;

GRANT CREATE DATABASE ON ACCOUNT TO ROLE admin;
```

### Question - 3

Switch to the admin role

### Approach -

As we need to switch to admin role, so we need need to run the `USE ROLE` command. The below is the code snippet which does the above said things.

```
USE ROLE ADMIN;
```

### Question - 4

Create a database assignment_db

### Approach -
```
CREATE OR REPLACE DATABASE assignment_db;
```

### Question - 5

Create a schema my_schema

### Approach -


```
CREATE OR REPLACE schema my_schema;
```

### Question - 6

Create a table using any sample csv. You can get 1 by googling for sample csv’s. Preferably search for a sample employee dataset so that you have PII related columns else you can consider any column as PII .

### Approach -

We have downloaded a .CSV file from online and description of dataset is as below -

- Name - final.csv
- No of Rows - 100
- Coloumns -
  - ID
  - NAME
  - COUNTRY
  - EMAIL
  - REGION

The below is snapshot of the .csv file.

<img width="767" alt="Screenshot 2023-04-09 at 11 49 18 AM" src="https://user-images.githubusercontent.com/123494344/230757867-92ebcf9f-e032-4fc1-b246-b5b4e17a6bbc.png">

As we need to create a table , so we need to run the `CREATE TABLE` command. The below is the code snippet which does the above said things with required additional columns and hardcoded data.

```
CREATE TABLE EMPLOYEE_DATA (
  ID NUMBER,
  FIRST_NAME VARCHAR(255),
  LAST_NAME VARCHAR(255),
  EMAIL VARCHAR(255),
  DEPARTMENT VARCHAR(255),
  MOBILE_NUMBER VARCHAR(255),
  CITY VARCHAR(255),
  etl_ts timestamp default current_timestamp(), -- for getting the time at which the record is getting inserted
  etl_by varchar default 'snowsight',-- for getting application name from which the record was inserted
  file_name varchar -- for getting the name of the file used to insert data into the table.
);
```

### Question - 7

Also, create a variant version of this dataset.

### Approach -

```
create table employee_variant_table(
json_data variant
);

create or replace file format json_format
  type = 'json'
  strip_outer_array = true;

COPY INTO employee_variant_table
FROM @%employee_variant_table file_format = json_format;

select * from employee_variant_table;

```

<img width="907" alt="Screenshot 2023-04-08 at 7 48 57 PM" src="https://user-images.githubusercontent.com/123494344/230758111-236a2712-f39f-47cb-a3b8-9f086d12a999.png">

<img width="1110" alt="Screenshot 2023-04-08 at 7 50 14 PM" src="https://user-images.githubusercontent.com/123494344/230758160-43394601-a277-4257-a519-4234fc917fa4.png">

<img width="1106" alt="Screenshot 2023-04-08 at 7 50 56 PM" src="https://user-images.githubusercontent.com/123494344/230758387-7bb1678a-f1e2-426c-841a-b7e7aae135b0.png">

### Question - 8

Load the file into an external and internal stage.

### Approach -

We have created two stages name `internal_stage`(to load form local) and `external_stage`(to load from AWS S3 bucket).

The below are steps followed to create stages and load data into them -

#### Steps for loading data to `internal_satge`

```

CREATE OR REPLACE FILE FORMAT mycsvformat
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1;

COPY INTO employees
FROM @%employees file_format = mycsvformat;


```

<img width="915" alt="Screenshot 2023-04-08 at 8 03 28 PM" src="https://user-images.githubusercontent.com/123494344/230758566-66f4b72e-de07-4462-8c2f-e192cb589e65.png">

#### Steps for loading data to `external_satge`

We need to created a storage integration object, to integrate snowflake with external provider.

The below are steps to create an s3 bucket and create a connection between snowflake and S3bucket.

We need to create a IAM Role from AWS MANAGMENT CONSOLE and then applied amazons3fullaccess policy and then created s3 bucket name 'assignment-snowflake' and inside that bucket created the folder name csv wherein uploaded the file employee.csv

As said earlier, before creating the external stage we will first create the aws_storage_intergration object which will be used for authentication from snowflake to AWS S3.

1. We created a storage integration object called s3_integration with holding s3 storage provider. The below is the code snippet which does the above said things.

```
CREATE STORAGE INTEGRATION s3_integration
type = external_stage
storage_provider = s3
enabled = true
storage_aws_role_arn = 'arn:aws:iam::366068070173:role/s3_chakradhar'
storage_allowed_locations = ('s3://assignment-snowflake/csv/employee.csv');
```

- The above line `storage_aws_role_arn = 'arn:aws:iam::366068070173:role/s3_chakradhar'` is the arn for role created in the aws via AWS MANGMENT CONSOLE.

- The above line `storage_allowed_locations = 's3://assignment-snowflake/csv/employee.csv'` is the path to the AWS S3 Bucket created via AWS MANGMENT CONSOLE.

2. As we are working on admin role, we grant all on integration object. The below is the code snippet which does the above said things.

```
GRANT ALL ON INTEGRATION s3_integration TO ROLE admin;
```

3. Describing Integration object to arrange a relatoinship between aws and snowflake, which gives us the external_id and arn for role. The below is the code snippet which does the above said things.

```
DESC INTEGRATION s3_integration;
```

The below are details of imtegration object created above -

<img width="1118" alt="Screenshot 2023-04-08 at 7 55 23 PM" src="https://user-images.githubusercontent.com/123494344/230758888-446648a9-6644-479c-acd7-fbd6a823a699.png">

Now the credential such as (STORAGE_AWS_IAM_USER_ARN, STORAGE_AWS_EXTERNAL_ID) obtained from running the above command will be used to edit the Trust Relationships in the role created in the AWS, so as it will ensure proper authentication and establish the trust relationship with the AWS.

4. We created a external stage called external_stage with holding my_csv_format file format and s3 bucket url. The below is the code snippet which does the above said things.

```
CREATE OR REPLACE STAGE external_stage
URL = 's3://assignment-snowflake/csv/employee.csv'
STORAGE_INTEGRATION = s3_integration
FILE_FORMAT = my_csv_format;
```

#### Listing both the files, for checking whether data was loaded correctly or not.

```
LIST @internal_stage;
```

The below is the snapshot of success messsage.

<img width="1347" alt="Screenshot 2023-04-09 at 12 25 33 PM" src="https://user-images.githubusercontent.com/123494344/230758994-d18986f8-1735-44e9-8416-f8363e1338b9.png">

```
LIST @external_stage;
```

The below is the snapshot of success messsage.

<img width="1109" alt="Screenshot 2023-04-08 at 8 04 08 PM" src="https://user-images.githubusercontent.com/123494344/230762714-16aa203b-5d38-42d3-b43c-a6d3f29628a1.png">

### Question - 9

Load data into the tables using copy into statements. In one table load from the internal stage and in another from the external

### Approach -

We need to create table employee_internal_stage for loading employee data from internal stage. The below is the code snippet which does the above said things.

```
CREATE TABLE employee_internal_stage (
  ID NUMBER,
  FIRST_NAME VARCHAR(255),
  LAST_NAME VARCHAR(255),
  EMAIL VARCHAR(255),
  DEPARTMENT VARCHAR(255),
  CONTACT_NO VARCHAR(255),
  CITY VARCHAR(255),
  etl_ts timestamp default current_timestamp(), -- for getting the time at which the record is getting inserted
  etl_by varchar default 'snowsight', -- for getting application name from which the record was inserted
  file_name varchar -- for getting the name of the file used to insert data into the table.
);
```

We need to create table employee_internal_stage for loading employee data from external stage. The below is the code snippet which does the above said things.

```
CREATE TABLE employee_external_stage (
  ID NUMBER,
  FIRST_NAME VARCHAR(255),
  LAST_NAME VARCHAR(255),
  EMAIL VARCHAR(255),
  DEPARTMENT VARCHAR(255),
  CONTACT_NO VARCHAR(255),
  CITY VARCHAR(255),
  etl_ts timestamp default current_timestamp(), -- for getting the time at which the record is getting inserted
  etl_by varchar default 'snowsight', -- for getting application name from which the record was inserted
  file_name varchar -- for getting the name of the file used to insert data into the table.
);
```

As we need to copy data into respective table from corresponding stages and we are fetching the table data using metadata function. The below is the code snippet which does the above said things.

```
COPY INTO employee_internal_stage(id, first_name,last_name,email,department,contact_no ,city,file_name)
FROM (
SELECT emp.$1, emp.$2, emp.$3, emp.$4, emp.$5, emp.$6, emp.$7, METADATA$FILENAME
FROM @internal_stage/employee.csv.gz (file_format => my_csv_format) emp);
```

Here we are directly quering from the internal stage, so we need to follow some predefined convention of using $1,$2 and so on to fetch the column values and also to get the name of the file through which the data is loaded we are quering the metadata which the snowflake maintains internally for the staging areas through the command METADATA$FILENAME.

As we need to copy data into respective table from corresponding stages and we are fetching the table data using metadata function. The below is the code snippet which does the above said things.

```
COPY INTO employee_external_stage(id, first_name,last_name,email,department,contact_no ,city,file_name)
FROM (
SELECT emp.$1, emp.$2, emp.$3, emp.$4, emp.$5, emp.$6, emp.$7, METADATA$FILENAME
FROM @external_stage (file_format => my_csv_format) emp);
```

Here we are directly quering from the internal stage, so we need to follow some predefined convention of using $1,$2 and so on to fetch the column values and also to get the name of the file through which the data is loaded we are quering the metadata which the snowflake maintains internally for the staging areas through the command METADATA$FILENAME.

To verify, Displaying the employee data to check whether they are loaded or not.

```
select * from employee_internal_stage limit 10;
```

The below is the snapshot of fetched rows.

<img width="1440" alt="Screenshot 2023-04-08 at 8 15 16 PM" src="https://user-images.githubusercontent.com/123494344/230759503-cb9b3198-af1c-49d1-b112-baff7bbfde2a.png">

```
select * from employee_external_stage limit 10;
```

The below is the snapshot of fetched rows.

<img width="1440" alt="Screenshot 2023-04-08 at 8 15 33 PM" src="https://user-images.githubusercontent.com/123494344/230759510-9ae7db62-60d4-4d28-bb83-4b922ef06c86.png">

### Question - 10

Upload any parquet file to the stage location and infer the schema of the file.

### Approach -

We have converted the same employee data name `employee.csv` to `employee.parquet`

The below is snapshot of the .parquet file.

<img width="1440" alt="Screenshot 2023-04-09 at 12 47 21 PM" src="https://user-images.githubusercontent.com/123494344/230759757-f1508c8b-dd1e-4107-9d2c-80faae01bacd.png">

We created a file format called my_parquet_format which holds data of format csv. The below is the code snippet which does the above said things.

```
CREATE FILE FORMAT my_parquet_format TYPE = parquet;
```

We created a stage called parquet_stage with holding my_parquet_format file format. The below is the code snippet which does the above said things.

```
CREATE STAGE parquet_stage file_format = my_parquet_format;
```

We need to put data in the table stage, as data is in local we need to run the command from snowsql. The below is the code snippet which does the above said things.

```
put file://~/Desktop/employee.parquet @parquet_stage;
```

The below is the snapshot of success messsage.

<img width="926" alt="Screenshot 2023-04-08 at 11 03 48 PM" src="https://user-images.githubusercontent.com/123494344/230759827-e90a8432-d42f-4f62-874f-a54579cc35e0.png">

Query to Infer about the schema, The below is the code snippet which does the above said things.

```
SELECT *
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION=>'@parquet_stage'
      , FILE_FORMAT=>'my_parquet_format'
      )
    );
```

The below is the snapshot of INFER SCHEMA.

<img width="1427" alt="Screenshot 2023-04-09 at 12 51 10 PM" src="https://user-images.githubusercontent.com/123494344/230759890-3c9ad484-dc5b-4178-8a08-522f036a6db6.png">

### Question - 11

Run a select query on the staged parquet file without loading it to a snowflake table.

### Approach -

We are running a select query on the staged parquet file without loading it to a snowflake table. The below is the code snippet which does the above said things.

```
SELECT * from @parquet_stage/employee.parquet;
```

The below is the snapshot of fetched result.

<img width="1439" alt="Screenshot 2023-04-09 at 12 54 51 PM" src="https://user-images.githubusercontent.com/123494344/230759995-5a965149-6b40-42b7-85b4-b78ca7ef999b.png">

### Question - 12

Add masking policy to the PII columns such that fields like email, phone number, etc. show as **masked** to a user with the developer role. If the role is PII the value of these columns should be visible.

### Approach -

We are creating masking policy for given constraints. The below is the code snippet which does the above said things.

#### - `email_mask`

```
CREATE OR REPLACE MASKING POLICY email_mask AS (VAL string) RETURNS string ->
CASE
WHEN CURRENT_ROLE() = 'PII' THEN VAL
ELSE '****MASK****'
END;
```

#### - `contact_mask`

```
CREATE OR REPLACE MASKING POLICY contact_Mask AS (VAL string) RETURNS string ->
CASE
WHEN CURRENT_ROLE() = 'PII' THEN VAL
ELSE '****MASK****'
END;
```

The policies are implemented using a CASE statement that checks the current role and returns either the original value or a masked value.

As we have created the policies, we need to apply those policies to table by altering them. The below is the code snippet which does the above said things.

```
-- Adding the email_mask policy to employee_internal_stage
ALTER TABLE IF EXISTS employee_internal_stage
MODIFY EMAIL SET MASKING POLICY email_mask;

-- Adding the email_mask policy to employee_external_stage
ALTER TABLE IF EXISTS employee_external_stage
MODIFY EMAIL SET MASKING POLICY email_mask;

-- Adding the contact_mask policy to employee_internal_stage
ALTER TABLE IF EXISTS employee_internal_stage
MODIFY contact_no SET MASKING POLICY contact_mask;

-- Adding the conatct_mask policy to employee_external_stage
ALTER TABLE IF EXISTS employee_external_stage
MODIFY contact_no SET MASKING POLICY contact_mask;
```

TO verify whether masking was applied correctly or not, We need to display data being in different roles.

- #### Admin role

As now we are in admin role, displaying data being in that role.

```
SELECT * FROM employee_internal_stage LIMIT 10;
```

The below is the snapshot of fetched result.

<img width="1336" alt="Screenshot 2023-04-09 at 1 03 56 PM" src="https://user-images.githubusercontent.com/123494344/230760319-8c506a59-90a1-44b1-9388-45f6a8a5790c.png">

```
SELECT * FROM employee_external_stage LIMIT 10;
```

The below is the snapshot of fetched result.

<img width="1346" alt="Screenshot 2023-04-09 at 1 04 41 PM" src="https://user-images.githubusercontent.com/123494344/230760324-ec7806c2-0b2b-4f36-9d58-e517e8e504e9.png">

- #### PII role

As we need to display data from PII view, we need to grant certain previlages to `PII` role, for this we need to switch to `ACCOUNTADMIN` role.

```
-- Switching the role
USE ROLE ACCOUNTADMIN;
-- Granting required previlages to role developer
GRANT ALL PRIVILEGES ON WAREHOUSE assignment_wh TO ROLE PII;
GRANT USAGE ON DATABASE ASSIGNMENT_DB TO ROLE PII;
GRANT USAGE ON SCHEMA ASSIGNMENT_DB.MY_SCHEMA TO ROLE PII;
GRANT SELECT ON TABLE assignment_db.my_schema.employee_internal_stage TO ROLE PII;
GRANT SELECT ON TABLE assignment_db.my_schema.employee_external_stage TO ROLE PII;
USE ROLE PII; -- using the role PII
```

Now we are in the PII role, so to display the data

```
SELECT * FROM employee_internal_stage LIMIT 10;
```

The below is the snapshot of fetched result.

<img width="1429" alt="Screenshot 2023-04-09 at 1 09 01 PM" src="https://user-images.githubusercontent.com/123494344/230760481-2eb708bc-e64a-452c-a6fc-db2885bf4e8d.png">

```
SELECT * FROM employee_external_stage LIMIT 10;
```

The below is the snapshot of fetched result.

<img width="1431" alt="Screenshot 2023-04-09 at 1 09 44 PM" src="https://user-images.githubusercontent.com/123494344/230760511-68828270-f8db-49ac-a565-fa02633413a8.png">

- #### Developer role

As we need to display data from Developer view, we need to grant certain previlages to `Developer` role, for this we need to switch to `ACCOUNTADMIN` role.

```
-- Switching the role
USE ROLE ACCOUNTADMIN;
-- Granting required previlages to role developer
GRANT ALL PRIVILEGES ON WAREHOUSE assignment_wh TO ROLE DEVELOPER;
GRANT USAGE ON DATABASE ASSIGNMENT_DB TO ROLE DEVELOPER;
GRANT USAGE ON SCHEMA ASSIGNMENT_DB.MY_SCHEMA TO ROLE DEVELOPER;
GRANT SELECT ON TABLE assignment_db.my_schema.employee_internal_stage TO ROLE DEVELOPER;
GRANT SELECT ON TABLE assignment_db.my_schema.employee_external_stage TO ROLE DEVELOPER;
USE ROLE DEVELOPER; -- using the role Developer
```

Now we are in the Developer role, so to display the data

```
SELECT * FROM employee_internal_stage LIMIT 10;
```

The below is the snapshot of fetched result.

<img width="1335" alt="Screenshot 2023-04-09 at 1 11 50 PM" src="https://user-images.githubusercontent.com/123494344/230760595-abc0c315-eaf4-404c-a999-b69db86a2e5f.png">

```
SELECT * FROM employee_external_stage LIMIT 10;
```

The below is the snapshot of fetched result.

<img width="1341" alt="Screenshot 2023-04-09 at 1 12 07 PM" src="https://user-images.githubusercontent.com/123494344/230760619-8f5d5951-2378-4b96-8eb6-1048ad0baab8.png">

### Snapshot of Role and Trust relationship

<img width="1178" alt="Screenshot 2023-04-09 at 2 34 03 PM" src="https://user-images.githubusercontent.com/123494344/230764588-7f5f5d15-8ce6-409d-9d23-73220d150a46.png">

### Snapshot of Bucket

<img width="1109" alt="Screenshot 2023-04-09 at 2 35 31 PM" src="https://user-images.githubusercontent.com/123494344/230764604-81430b53-e992-4056-aabb-ee8a0dd76fc7.png">
