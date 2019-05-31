//===========================================================
// Create cloudtrail monitoring objects
//===========================================================
// set role
USE ROLE SNOWWATCH_ROLE;

A.EVENT_DATA AS EVENT_DATA,
A.EVENT_DATA:"awsRegion" :: STRING as EVENT_REGION_NAME,
A.EVENT_DATA:"eventName" :: STRING as EVENT_NAME,
A.EVENT_DATA:"eventSource" :: STRING as EVENT_SOURCE,
A.EVENT_DATA:"eventTime" :: TIMESTAMP_TZ as EVENT_TIME,
A.EVENT_DATA:"eventType" :: STRING as EVENT_TYPE,
A.EVENT_DATA:"sourceIPAddress" :: STRING as EVENT_SOURCE_IP,
A.EVENT_DATA:"userAgent" :: STRING as EVENT_USER_AGENT,
A.EVENT_DATA:"userIdentity"."arn" :: STRING as EVENT_USER_ARN,

CREATE OR REPLACE TABLE
  SNOWWATCH.AWS.CLOUDTRAIL_MONITORING_LANDING_ZONE(
    TIMESTAMP_UTC TIMESTAMP_TZ, 
    EVENT_DATA VARIANT
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
      $1:"Records"[0]:"eventTime" :: TIMESTAMP_TZ AS TIMESTAMP_UTC,
      $1:"Records" AS EVENT_DATA 
    FROM 
        @SNOWWATCH.AWS.CLOUDTRAIL_MONITORING_STAGE
  );
    
// refresh pipe to catch any existing files in the stage
ALTER PIPE SNOWWATCH.AWS.CLOUDTRAIL_MONITORING_PIPE REFRESH;

// NOTE: do not forget to add the sqs arn to your s3 bucket for auto_ingest support
SELECT SYSTEM$PIPE_STATUS('SNOWWATCH.AWS.CLOUDTRAIL_MONITORING_PIPE');
//===========================================================