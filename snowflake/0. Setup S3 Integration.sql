// Setup AWS Credentials

// --------------------------------------------------------------------------------
// Set up integration object - register user ID in AWS IAM S3 policy
CREATE OR REPLACE STORAGE INTEGRATION s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE 
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::702778657222:role/snowflake_tech_test'  // Get from IAM Roles
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflaketechtest');
  
DESC INTEGRATION s3_int;