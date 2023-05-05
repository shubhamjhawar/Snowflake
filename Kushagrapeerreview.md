Created roles using SQL commands under the given constraints using "GRANT" and "CREATE"
Created the warehouse using SQL command "CREATE WAREHOUSE"
Granted privileges to the role "ADMIN" for the new warehouse created
Switched to the "ADMIN" role and created the database using SQL command and then created the schema
Created an employee table.
Created an employee variant table
Created an internal stage and loaded the file using snowsql.
For external stage, created a storage integraton for aws bucket, and then created an external staging area and also used for the variant table.
Created a stage for the parquet file and uploaded the parquet file using snowsql.
Using select * command, queried the data from the staging area.
Created a masking policy for email and phone number and altered the employee table column.
Granted requied permissions for developer and PII role and then queried the table using both roles.
