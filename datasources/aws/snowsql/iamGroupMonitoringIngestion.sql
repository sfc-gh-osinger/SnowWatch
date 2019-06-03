//===========================================================
// Create cloudtrail monitoring objects
//===========================================================
// set context
USE ROLE SNOWWATCH_ROLE;
USE WAREHOUSE SNOWWATCH_WAREHOUSE;

// CREATE TABLE
CREATE TABLE IF NOT EXISTS
  SNOWWATCH.AWS.IAM_GROUP_MONITORING_LANDING_ZONE (
    RAW_DATA        VARIANT,
    MONITORED_TIME  TIMESTAMP_TZ,  
    ARN             STRING,
    CREATE_DATE     TIMESTAMP_TZ,
    GROUP_ID        STRING,
    GROUP_NAME      STRING,
    PATH            STRING,
  );

// create pipe
CREATE OR REPLACE PIPE
  SNOWWATCH.AWS.IAM_GROUP_MONITORING_PIPE
  AUTO_INGEST=TRUE
AS 
  COPY INTO 
    SNOWWATCH.AWS.IAM_GROUP_MONITORING_LANDING_ZONE 
  FROM (
    SELECT 
      $1                                      AS RAW_DATA, 
      TO_TIMESTAMP_TZ(
        REGEXP_SUBSTR(
          METADATA$FILENAME, '\/([^\/]*)\.json', 1, 1, 'e'
        ) || 'Z'
      )                                       AS MONITORED_TIME,
      $1:"Arn" :: STRING                      AS ARN,
      $1:"CreateDate" :: TIMESTAMP_TZ         AS CREATE_DATE,
      $1:"GroupId" :: STRING                  AS GROUP_ID,
      $1:"GroupName" :: STRING                AS GROUP_NAME,
      $1:"Path" :: STRING                     AS PATH
    FROM 
      @SNOWWATCH.AWS.SNOWWATCH_S3_STAGE/iam_monitoring/groups/
  );
  
    
// Copy any data that may already exist

// NOTE: do not forget to add the sqs arn to your s3 bucket for auto_ingest support
SELECT SYSTEM$PIPE_STATUS('SNOWWATCH.AWS.IAM_GROUP_MONITORING_PIPE');
//===========================================================
