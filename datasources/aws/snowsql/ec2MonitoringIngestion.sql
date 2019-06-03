//===========================================================
// Create ec2 monitoring objects
//===========================================================
// set context
USE ROLE SNOWWATCH_ROLE;
USE WAREHOUSE SNOWWATCH_WAREHOUSE;

// CREATE TABLE
CREATE TABLE IF NOT EXISTS
  SNOWWATCH.AWS.EC2_MONITORING_LANDING_ZONE (
    RAW_DATA        VARIANT,
    MONITORED_TIME  TIMESTAMP_TZ,
    ARCHITECTURE    STRING(16),
    INSTANCE_TYPE   STRING(16),
    KEY_NAME        STRING(256),
    LAUNCH_TIME     TIMESTAMP_TZ,
    REGION_NAME     STRING(16),
    INSTANCE_STATE  STRING(16),
    INSTANCE_NAME   STRING(256)
  );

// create pipe
CREATE OR REPLACE PIPE
  SNOWWATCH.AWS.EC2_MONITORING_PIPE
  AUTO_INGEST=TRUE
AS 
  COPY INTO 
    SNOWWATCH.AWS.EC2_MONITORING_LANDING_ZONE 
  FROM (
    SELECT 
      $1                                      AS RAW_DATA, 
      TO_TIMESTAMP_TZ(
        REGEXP_SUBSTR(
          METADATA$FILENAME, '\/([^\/]*)\.json', 1, 1, 'e'
        ) || 'Z'
      )                                       AS MONITORED_TIME,
      $1:"Architecture" :: STRING(16)         AS ARCHITECTURE,
      $1:"InstanceType" :: STRING(16)         AS INSTANCE_TYPE,
      $1:"KeyName" :: STRING(256)             AS KEY_NAME,
      TO_TIMESTAMP_TZ($1:"LaunchTime")        AS LAUNCH_TIME,
      $1:"Region"."RegionName" :: STRING(16)  AS REGION_NAME,
      $1:"State"."Name" :: STRING(16)         AS INSTANCE_STATE,
      $1:"InstanceName" :: STRING(256)        AS INSTANCE_NAME
    FROM 
      @SNOWWATCH.AWS.SNOWWATCH_S3_STAGE/ec2_monitoring/
  );
  
    
// Copy any data that may already exist
COPY INTO 
  SNOWWATCH.AWS.EC2_MONITORING_LANDING_ZONE 
FROM (
  SELECT 
    $1                                      AS RAW_DATA, 
    TO_TIMESTAMP_TZ(
      REGEXP_SUBSTR(
        METADATA$FILENAME, '\/([^\/]*)\.json', 1, 1, 'e'
      ) || 'Z'
    )                                       AS MONITORED_TIME,
    $1:"Architecture" :: STRING(16)         AS ARCHITECTURE,
    $1:"InstanceType" :: STRING(16)         AS INSTANCE_TYPE,
    $1:"KeyName" :: STRING(256)             AS KEY_NAME,
    TO_TIMESTAMP_TZ($1:"LaunchTime")        AS LAUNCH_TIME,
    $1:"Region"."RegionName" :: STRING(16)  AS REGION_NAME,
    $1:"State"."Name" :: STRING(16)         AS INSTANCE_STATE,
    $1:"InstanceName" :: STRING(256)        AS INSTANCE_NAME
  FROM 
    @SNOWWATCH.AWS.SNOWWATCH_S3_STAGE/ec2_monitoring/
);

// NOTE: do not forget to add the sqs arn to your s3 bucket for auto_ingest support
SELECT SYSTEM$PIPE_STATUS('SNOWWATCH.AWS.EC2_MONITORING_PIPE');
//===========================================================
