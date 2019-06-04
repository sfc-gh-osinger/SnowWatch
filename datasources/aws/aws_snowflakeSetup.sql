//===========================================================
// Create snowwatch objects for AWS integration
//===========================================================
// set role
USE ROLE SNOWWATCH_ROLE;

// create schema
CREATE SCHEMA IF NOT EXISTS SNOWWATCH.AWS;

// create file format
CREATE FILE FORMAT IF NOT EXISTS
  SNOWWATCH.AWS.SNOWWATCH_JSON_ARRAY_FORMAT
  TYPE=JSON
  STRIP_OUTER_ARRAY=TRUE;

// create stage
CREATE STAGE IF NOT EXISTS
  SNOWWATCH.AWS.SNOWWATCH_S3_STAGE
  URL= '<your snowwatch bucket here>'  //'s3://snowwatch-' + your aws account ID
  CREDENTIALS=(AWS_KEY_ID='<add your key here>' AWS_SECRET_KEY='<add your key here>')
  FILE_FORMAT=SNOWWATCH.AWS.CLOUDTRAIL_MONITORING_JSON_FORMAT;

// confirm stage works
LIST @SNOWWATCH.AWS.SNOWWATCH_S3_STAGE;
//===========================================================