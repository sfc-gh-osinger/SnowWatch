//===========================================================
// Create cloudtrail monitoring objects
//===========================================================
// set context
USE ROLE SNOWWATCH_ROLE;
USE WAREHOUSE SNOWWATCH_WAREHOUSE;

// CREATE TABLE
CREATE TABLE IF NOT EXISTS
  SNOWWATCH.AWS.IAM_ROLE_MONITORING_LANDING_ZONE (
    RAW_DATA        VARIANT,
    MONITORED_TIME  TIMESTAMP_TZ,  
    ARN             STRING,
    CREATE_DATE     TIMESTAMP_TZ,
    PATH            STRING,
    ROLE_ID         STRING,
    ROLE_NAME       STRING
  );

// create pipe
CREATE OR REPLACE PIPE
  SNOWWATCH.AWS.IAM_ROLE_MONITORING_PIPE
  AUTO_INGEST=TRUE
AS 
  COPY INTO 
    SNOWWATCH.AWS.IAM_ROLE_MONITORING_LANDING_ZONE 
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
      $1:"Path" :: STRING                     AS PATH,
      $1:"RoleId" :: STRING                   AS ROLE_ID,
      $1:"RoleName" :: STRING                 AS ROLE_NAME
    FROM 
      @SNOWWATCH.AWS.SNOWWATCH_S3_STAGE/iam_monitoring/roles/
  );
  
    
// Copy any data that may already exist
COPY INTO 
  SNOWWATCH.AWS.IAM_ROLE_MONITORING_LANDING_ZONE 
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
    $1:"Path" :: STRING                     AS PATH,
    $1:"RoleId" :: STRING                   AS ROLE_ID,
    $1:"RoleName" :: STRING                 AS ROLE_NAME
  FROM 
    @SNOWWATCH.AWS.SNOWWATCH_S3_STAGE/iam_monitoring/roles/
);

// NOTE: do not forget to add the sqs arn to your s3 bucket for auto_ingest support
SELECT SYSTEM$PIPE_STATUS('SNOWWATCH.AWS.IAM_ROLE_MONITORING_PIPE');
//===========================================================
