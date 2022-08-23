# Snowflake Data Engineer Tech Test

## Areas of Improvement
There was an error when running the Python script to generate data, with KeyError: 'bws'
Resolution: Remove 'bws' from products_cats_frequency, change food freq to 35.
The pull request includes this fix.

### AWS Integration
1. A secure S3 bucket is created where the contents of folder input_data/starter/ is uploaded to the bucket.
2. The S3 bucket is made publicly accessible through an IAM role with a Trust Policy that only allows access to specific Snowflake credentials.

### Snowflake ETL Pipeline
The pipeline consists of 5 SQL scripts which needs to be executed in sequence only once, and it will create an automated pipeline that loads the data from S3 bucket into the appropriate tables daily going forward.
*The virtual environment and data files were gitignored, but it was tested with up to 2 years of data.

##### 0. Setup S3 Integration
Setup the Integration object that provides credentials STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID for IAM S3 role Trust Policy.

##### 1. Setup Databases
Creates the databases and schema for staging, file formats and data tables.

##### 2. Load Data Stored Procs
Creates the stored procedures which loads the customers, products and transactions from S3 bucket into stage tables. 
Customers and Products are full truncate reloads, while Transactions will only fetch the newly added json files without duplicates.

##### 3. Load Data Tasks 
Creates the tasks which schedules the job to kick off at 9am daily, starting with loading Customers -> Products -> Transactions json -> Transactions.
The final Transactions task uses a Stream object to update the Transaction table, in order to insert only the deltas.

##### 4. Create View
Creates the view which counts the number of purchases made by each customer for each product.

### Further Implementation Details
The current design is simplistic and doesn't account for tracking modifications - such as insertion time, soft-deletes and modified time etc on Customers and Products. This should be done in a real project.
For the data scientists to receive weekly updates for the view, a possible solution is to schedule a job that sends the view in an email.