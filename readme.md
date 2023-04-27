# Snowflake_Assignment
Please note that `Snowflake_ass.sql` doesnot contain all the commands as we have ran some commands from `snowsql`(These were alson present in `Snowflake_ass.sql` file but they are commented with tag "This must be run from snowsight").

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


<img width="680" alt="csvfile" src="https://user-images.githubusercontent.com/66582610/233616132-af59696d-236a-4cf8-8e66-0ad443caeedb.png">


As we need to create a table , so we need to run the `CREATE TABLE` command. The below is the code snippet which does the above said things with required additional columns and hardcoded data.

```

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

CREATE OR REPLACE FILE FORMAT mycsvformat
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1;

COPY INTO EMPLOYEE(name,email,country,region,ID,elt_ts,elt_by,file_name)
FROM (select $1, $2, $3 , $4 , $5,CURRENT_TIMESTAMP(),'snow','assignment' from @%EMPLOYEE)
FILE_FORMAT = mycsvformat;



select * from employee;

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

<!-- PUT file:///Users/shubhamjhawar/Downloads/final.json @%EMPLOYEE_VARIANT_TABLE; -->

```

<img width="925" alt="json" src="https://user-images.githubusercontent.com/66582610/233615655-b8fe1e86-e7d8-4d10-add1-49435f6a87fe.png">

<img width="907" alt="jsondataselect" src="https://user-images.githubusercontent.com/66582610/233615440-32ebb425-f103-4435-9fc3-58deb5fa4f37.png">


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


CREATE OR REPLACE STAGE my_stage
  FILE_FORMAT = mycsvformat;

<!-- PUT file:///Users/shubhamjhawar/Downloads/final.csv @my_stage; -->

```

<img width="915" alt="Screenshot 2023-04-08 at 8 03 28 PM" src="https://user-images.githubusercontent.com/123494344/230758566-66f4b72e-de07-4462-8c2f-e192cb589e65.png">

#### Steps for loading data to `external_satge`

We need to created a storage integration object, to integrate snowflake with external provider.

The below are steps to create an s3 bucket and create a connection between snowflake and S3bucket.

We need to create a IAM Role from AWS MANAGMENT CONSOLE and then applied amazons3fullaccess policy and then created s3 bucket name 'assignment-snowflake' and inside that bucket created the folder name csv wherein uploaded the file employee.csv

As said earlier, before creating the external stage we will first create the aws_storage_intergration object which will be used for authentication from snowflake to AWS S3.

1. We created a storage integration object called s3_integration with holding s3 storage provider. The below is the code snippet which does the above said things.

```
CREATE STORAGE INTEGRATION s3_integration type = external_stage storage_provider = s3 enabled = true storage_aws_role_arn = 'arn:aws:iam::574344495913:role/snowflake-role' storage_allowed_locations = ('s3://snowflakeshubham/final.csv');
```

- The above line `arn:aws:iam::574344495913:role/snowflake-role` is the arn for role created in the aws via AWS MANGMENT CONSOLE.


2. As we are working on admin role, we grant all on integration object. The below is the code snippet which does the above said things.

```
GRANT ALL ON INTEGRATION s3_integration TO ROLE admin;
```

3. Describing Integration object to arrange a relatoinship between aws and snowflake, which gives us the external_id and arn for role. The below is the code snippet which does the above said things.

```
DESC INTEGRATION s3_integration;
```

The below are details of imtegration object created above -

<img width="876" alt="S3INTEGRATION" src="https://user-images.githubusercontent.com/66582610/234758039-785f2e20-2be5-4246-abf2-c5b87f8868d6.png">

Now the credential such as (STORAGE_AWS_IAM_USER_ARN, STORAGE_AWS_EXTERNAL_ID) obtained from running the above command will be used to edit the Trust Relationships in the role created in the AWS, so as it will ensure proper authentication and establish the trust relationship with the AWS.

4. We created a external stage called external_stage with holding my_csv_format file format and s3 bucket url. The below is the code snippet which does the above said things.

```
CREATE OR REPLACE STAGE external_stage URL = 's3://snowflakeshubham/final.csv' STORAGE_INTEGRATION = s3_integration FILE_FORMAT = mycsvformat;

```
### Question - 9

Load data into the tables using copy into statements. In one table load from the internal stage and in another from the external

### Approach -

We need to create table employee_internal_stage for loading employee data from internal stage. The below is the code snippet which does the above said things.

```
CREATE OR REPLACE TABLE EMPLOYEE_INTERNAL_STAGE(
ID NUMBER,
NAME VARCHAR(255),
EMAIL VARCHAR(255),
COUNTRY VARCHAR(255),
REGION VARCHAR(255),
elt_ts TIMESTAMP default current_timestamp(),
elt_by varchar default 'snow',
file_name varchar default 'assignment'
);

COPY INTO EMPLOYEE_INTERNAL_STAGE(name,email,country,region,ID,elt_ts,elt_by,file_name)
FROM (select $1, $2, $3 , $4 , $5,CURRENT_TIMESTAMP(),'snow','assignment' from @my_stage/final.csv)
FILE_FORMAT = mycsvformat
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
COPY INTO EMPLOYEE_EXTERNAL_STAGE
FROM (select * from @external_stage)
FILE_FORMAT = mycsvformat;


```
## THE RESULTINGF DATA WHICH OCCURED IS ATTACHED BELOW -

```
select * from employee_internal_stage;
```

The below is the snapshot of fetched rows.

<img width="803" alt="INTERNALSTAGESSV" src="https://user-images.githubusercontent.com/66582610/234758826-7b4d6cbc-d0a9-41de-95b9-2017b4a3bf20.png">


```
select * from employee_external_stage ;
```

The below is the snapshot of fetched rows.

<img width="766" alt="EXTERNALSTAGECSV" src="https://user-images.githubusercontent.com/66582610/234758897-3529fb48-bfcf-4021-9a2d-4a0b40e22b3f.png">
### Question - 10

Upload any parquet file to the stage location and infer the schema of the file.

### Approach -

We have converted the same employee data name `employee.csv` to `employee.parquet`

The below is snapshot of the .parquet file.

<img width="1440" alt="Screenshot 2023-04-09 at 12 47 21 PM" src="https://user-images.githubusercontent.com/123494344/230759757-f1508c8b-dd1e-4107-9d2c-80faae01bacd.png">

We created a file format called my_parquet_format which holds data of format csv. The below is the code snippet which does the above said things.
```
CREATE FILE FORMAT my_parquet_format TYPE = parquet;
CREATE STAGE stage_for_parquet file_format = my_parquet_format;

<!-- PUT file:///Users/shubhamjhawar/Downloads/final.parquet @stage_for_parquet; -->

```

The below is the snapshot of success messsage.

<img width="926" alt="Screenshot 2023-04-08 at 11 03 48 PM" src="https://user-images.githubusercontent.com/123494344/230759827-e90a8432-d42f-4f62-874f-a54579cc35e0.png">

Query to Infer about the schema, The below is the code snippet which does the above said things.



The below is the snapshot of INFER SCHEMA.

<img width="1427" alt="Screenshot 2023-04-09 at 12 51 10 PM" src="https://user-images.githubusercontent.com/123494344/230759890-3c9ad484-dc5b-4178-8a08-522f036a6db6.png">

### Question - 11

Run a select query on the staged parquet file without loading it to a snowflake table.

### Approach -

We are running a select query on the staged parquet file without loading it to a snowflake table. The below is the code snippet which does the above said things.

```
select * from @stage_for_parquet/final.parquet;
```

The below is the snapshot of fetched result.

<img width="1439" alt="Screenshot 2023-04-09 at 12 54 51 PM" src="https://user-images.githubusercontent.com/123494344/230759995-5a965149-6b40-42b7-85b4-b78ca7ef999b.png">

### Question - 12

Add masking policy to the PII columns such that fields like email etc. show as **masked** to a user with the developer role. If the role is PII the value of these columns should be visible.


```

USE ROLE "ACCOUNTADMIN";

CREATE OR REPLACE MASKING POLICY email_masks AS (val string) RETURNS string ->
  CASE
    WHEN CURRENT_ROLE() IN ('DEVELOPER') THEN '***'
    ELSE val
  END;

ALTER TABLE IF EXISTS employee MODIFY COLUMN email SET MASKING POLICY email_masks;



```

### FOR THE ROLE DEVELOPER

```
----------------------------FOR THE DEVLOPER ROLE 
USE ROLE "ACCOUNTADMIN";
GRANT ALL PRIVILEGES ON WAREHOUSE assignment_wh TO ROLE "DEVELOPER";
GRANT USAGE ON DATABASE ASSIGNMENT_DB TO ROLE "DEVELOPER";
GRANT USAGE ON SCHEMA "MY_SCHEMA" TO ROLE "DEVELOPER";
GRANT SELECT ON TABLE assignment_db.my_schema.employee TO ROLE "DEVELOPER";

USE ROLE "DEVELOPER";
select * from employee;


```

<img width="766" alt="MASKING" src="https://user-images.githubusercontent.com/66582610/234759601-4031b55a-1550-4d6d-9439-de71a14eecd9.png">



#
#

### FOR THE ROLE PII

``` 
USE ROLE "ACCOUNTADMIN";
GRANT ALL PRIVILEGES ON WAREHOUSE assignment_wh TO ROLE "PII";
GRANT USAGE ON DATABASE ASSIGNMENT_DB TO ROLE "PII";
GRANT USAGE ON SCHEMA "MY_SCHEMA" TO ROLE "PII";
GRANT SELECT ON TABLE assignment_db.my_schema.employee TO ROLE "PII";

USE ROLE "PII";
select * from employee;

```


<img width="820" alt="NOTMASKEDPII" src="https://user-images.githubusercontent.com/66582610/234759810-d48177b0-2f6e-4a45-a658-d72f0959f904.png">


#
#

### FOR THE ROLE ADMIN

````
USE ROLE "ADMIN";
select * from employee;

````
<img width="738" alt="NOTMASKED" src="https://user-images.githubusercontent.com/66582610/234759630-72e4db1d-6baf-421d-8cb1-3bc91efd3922.png">

