//===========================================================
// Create snowflake objects
//===========================================================
// set role
USE ROLE SYSADMIN;

// create schema and table
CREATE SCHEMA HASHMAP_DB.AWS;
CREATE TABLE IF NOT EXISTS HASHMAP_DB.AWS.EC2_MONITORING_LANDING_ZONE(TIMESTAMP_UTC TIMESTAMP_NTZ, INSTANCE_DATA VARIANT);

// create file format
CREATE OR REPLACE FILE FORMAT
  HASHMAP_DB.AWS.EC2_MONITORING_JSON_FORMAT
  TYPE=JSON
  STRIP_OUTER_ARRAY=TRUE;

// create stage
CREATE STAGE IF NOT EXISTS
  HASHMAP_DB.AWS.EC2_MONITORING_STAGE
  URL='s3://sf-snowalert-trail/ec2_monitoring/'
  CREDENTIALS=(AWS_KEY_ID='<add your key here>' AWS_SECRET_KEY='<add your key here>')
  FILE_FORMAT=HASHMAP_DB.AWS.EC2_MONITORING_JSON_FORMAT;

// confirm stage works
LIST @HASHMAP_DB.AWS.EC2_MONITORING_STAGE;

// create pipe
CREATE OR REPLACE PIPE
  HASHMAP_DB.AWS.EC2_MONITORING_PIPE
  AUTO_INGEST=TRUE
AS 
  COPY INTO 
    HASHMAP_DB.AWS.EC2_MONITORING_LANDING_ZONE 
  FROM (
    SELECT 
      TO_TIMESTAMP_NTZ(REGEXP_SUBSTR(METADATA$FILENAME, '\/([^\/]*)\.json', 1, 1, 'e')) AS TIMESTAMP_UTC,
      $1 AS INSTANCE_DATA 
    FROM @HASHMAP_DB.AWS.EC2_MONITORING_STAGE
  );
    
// refresh pipe to catch any existing files in the stage
ALTER PIPE HASHMAP_DB.AWS.EC2_MONITORING_PIPE REFRESH;
