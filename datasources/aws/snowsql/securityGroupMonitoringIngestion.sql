//===========================================================
// Create cloudtrail monitoring objects
//===========================================================
// set context
USE ROLE SNOWWATCH_ROLE;
USE WAREHOUSE SNOWWATCH_WAREHOUSE;

// CREATE TABLE
CREATE TABLE IF NOT EXISTS
  SNOWWATCH.AWS.SECURITY_GROUP_MONITORING_LANDING_ZONE (
    RAW_DATA        VARIANT,
    MONITORED_TIME  TIMESTAMP_TZ,
    DESCRIPTION     STRING,
    GROUP_ID        STRING,
    GROUP_NAME      STRING,
    OWNER_ID        STRING,
    REGION_NAME     STRING(16),
    VPC_ID          STRING
  );

// create pipe
CREATE OR REPLACE PIPE
  SNOWWATCH.AWS.SECURITY_GROUP_MONITORING_PIPE
  AUTO_INGEST=TRUE
AS 
  COPY INTO 
    SNOWWATCH.AWS.SECURITY_GROUP_MONITORING_LANDING_ZONE 
  FROM (
    SELECT 
      $1                                      AS RAW_DATA, 
      TO_TIMESTAMP_TZ(
        REGEXP_SUBSTR(
          METADATA$FILENAME, '\/([^\/]*)\.json', 1, 1, 'e'
        ) || 'Z'
      )                                       AS MONITORED_TIME,
      $1:"Description" :: STRING              AS DESCRIPTION,
      $1:"GroupId" :: STRING                  AS GROUP_ID,
      $1:"GroupName" :: STRING                AS GROUP_NAME,
      $1:"OwnerId" :: STRING                  AS OWNER_ID,
      $1:"Region"."RegionName" :: STRING(16)  AS REGION_NAME,
      $1:"VpcId":: STRING                     AS VPC_ID
    FROM 
      @SNOWWATCH.AWS.SNOWWATCH_S3_STAGE/security_group_monitoring/
  );
  
    
// Copy any data that may already exist
COPY INTO 
  SNOWWATCH.AWS.SECURITY_GROUP_MONITORING_LANDING_ZONE 
FROM (
  SELECT 
    $1                                      AS RAW_DATA, 
    TO_TIMESTAMP_TZ(
      REGEXP_SUBSTR(
        METADATA$FILENAME, '\/([^\/]*)\.json', 1, 1, 'e'
      ) || 'Z'
    )                                       AS MONITORED_TIME,
    $1:"Description" :: STRING              AS DESCRIPTION,
    $1:"GroupId" :: STRING                  AS GROUP_ID,
    $1:"GroupName" :: STRING                AS GROUP_NAME,
    $1:"OwnerId" :: STRING                  AS OWNER_ID,
    $1:"Region"."RegionName" :: STRING(16)  AS REGION_NAME,
    $1:"VpcId":: STRING                     AS VPC_ID
  FROM 
    @SNOWWATCH.AWS.SNOWWATCH_S3_STAGE/security_group_monitoring/
);

// NOTE: do not forget to add the sqs arn to your s3 bucket for auto_ingest support
SELECT SYSTEM$PIPE_STATUS('SNOWWATCH.AWS.SECURITY_GROUP_MONITORING_PIPE');
//===========================================================
