//===========================================================
// Create snowflake objects
//===========================================================
// set role
USE ROLE SYSADMIN;

// create schema and table
CREATE SCHEMA IF NOT EXISTS HASHMAP_DB.AWS;
CREATE OR REPLACE TABLE
  HASHMAP_DB.AWS.CLOUDTRAIL_MONITORING_LANDING_ZONE(
    TIMESTAMP_UTC TIMESTAMP_TZ, 
    EVENT_DATA VARIANT
  );

// create file format
CREATE OR REPLACE FILE FORMAT
  HASHMAP_DB.AWS.CLOUDTRAIL_MONITORING_JSON_FORMAT
  TYPE=JSON;

// create stage
CREATE STAGE IF NOT EXISTS
  HASHMAP_DB.AWS.CLOUDTRAIL_MONITORING_STAGE
  URL='s3://sf-snowalert-trail/AWSLogs/660239660726/CloudTrail/'
  CREDENTIALS=(AWS_KEY_ID='<add your key here>' AWS_SECRET_KEY='<add your key here>')
  FILE_FORMAT=HASHMAP_DB.AWS.CLOUDTRAIL_MONITORING_JSON_FORMAT;

// confirm stage works
LIST @HASHMAP_DB.AWS.CLOUDTRAIL_MONITORING_STAGE;

// create pipe
CREATE OR REPLACE PIPE 
  HASHMAP_DB.AWS.CLOUDTRAIL_MONITORING_PIPE
  AUTO_INGEST=TRUE
AS 
  COPY INTO 
    HASHMAP_DB.AWS.CLOUDTRAIL_MONITORING_LANDING_ZONE 
  FROM (
    SELECT 
      $1:"Records"[0]:"eventTime" :: TIMESTAMP_TZ AS TIMESTAMP_UTC,
      $1:"Records" AS EVENT_DATA 
    FROM 
        @HASHMAP_DB.AWS.CLOUDTRAIL_MONITORING_STAGE
  );
    
// refresh pipe to catch any existing files in the stage
ALTER PIPE HASHMAP_DB.AWS.CLOUDTRAIL_MONITORING_PIPE REFRESH;

// NOTE: do not forget to add the sqs arn to your s3 bucket for auto_ingest support
SELECT SYSTEM$PIPE_STATUS('HASHMAP_DB.AWS.CLOUDTRAIL_MONITORING_PIPE');