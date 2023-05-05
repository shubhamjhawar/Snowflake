Created roles using SQL commands under the given constraints
Created the warehouse using SQL command CREATE WAREHOUSE
Granted privileges to the role ADMIN for the new warehouse created
Switched to the admin role and created the database using SQL command and then created the schema
Created an employee table and variant table
Created two internal stages and also one parquet stage
Inferred the schema of parquet stage.
Created a new table for external stage and also a file format.
For external stage, created a storage integraton for aws bucket, and then created an external staging area.
Created two new tables and copied data from the staging area created.
Created a stage for the parquet file and uploaded the parquet file using snowsql.
Using select * command, queried the data from the staging area.
Created a masking policy for email and altered the employee table column.
Granted requied permissions for developer and PII role and then queried the table using both roles.
