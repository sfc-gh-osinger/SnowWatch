//===========================================================
// Create cloudtrail monitoring objects
//===========================================================
// set role
USE ROLE SNOWWATCH_ROLE;

// CREATE TABLE
CREATE TABLE IF NOT EXISTS
  SNOWWATCH.AWS.CLOUDTRAIL_MONITORING_LANDING_ZONE(
    EVENT_DATA VARIANT,
    EVENT_REGION_NAME STRING,
    EVENT_NAME STRING,
    EVENT_SOURCE STRING,
    EVENT_TIME TIMESTAMP_TZ,
    EVENT_TYPE STRING,
    EVENT_SOURCE_IP STRING,
    EVENT_USER_AGENT STRING,
    EVENT_USER_ARN STRING
  );

// create pipe
CREATE OR REPLACE PIPE 
  SNOWWATCH.AWS.CLOUDTRAIL_MONITORING_PIPE
  AUTO_INGEST=TRUE
AS 
  COPY INTO 
    SNOWWATCH.AWS.CLOUDTRAIL_MONITORING_LANDING_ZONE 
  FROM (
    SELECT 
      $1 AS EVENT_DATA,
      $1:"awsRegion" :: STRING as EVENT_REGION_NAME,
      $1:"eventName" :: STRING as EVENT_NAME,
      $1:"eventSource" :: STRING as EVENT_SOURCE,
      $1:"eventTime" :: TIMESTAMP_TZ as EVENT_TIME,
      $1:"eventType" :: STRING as EVENT_TYPE,
      $1:"sourceIPAddress" :: STRING as EVENT_SOURCE_IP,
      $1:"userAgent" :: STRING as EVENT_USER_AGENT,
      $1:"userIdentity"."arn" :: STRING as EVENT_USER_ARN
    FROM 
        @SNOWWATCH.AWS.SNOWWATCH_S3_STAGE/cloudtrail_monitoring/
  );
    
// Copy any data that may already exist
COPY INTO 
  SNOWWATCH.AWS.CLOUDTRAIL_MONITORING_LANDING_ZONE 
FROM (
  SELECT 
    $1 AS EVENT_DATA,
    $1:"awsRegion" :: STRING as EVENT_REGION_NAME,
    $1:"eventName" :: STRING as EVENT_NAME,
    $1:"eventSource" :: STRING as EVENT_SOURCE,
    $1:"eventTime" :: TIMESTAMP_TZ as EVENT_TIME,
    $1:"eventType" :: STRING as EVENT_TYPE,
    $1:"sourceIPAddress" :: STRING as EVENT_SOURCE_IP,
    $1:"userAgent" :: STRING as EVENT_USER_AGENT,
    $1:"userIdentity"."arn" :: STRING as EVENT_USER_ARN
  FROM 
    @SNOWWATCH.AWS.SNOWWATCH_S3_STAGE/cloudtrail_monitoring/
);

// NOTE: do not forget to add the sqs arn to your s3 bucket for auto_ingest support
SELECT SYSTEM$PIPE_STATUS('SNOWWATCH.AWS.CLOUDTRAIL_MONITORING_PIPE');
//===========================================================