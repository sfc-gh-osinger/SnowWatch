// ============================================
// create hack simulation
// ============================================
USE ROLE SYSADMIN;
CREATE SCHEMA IF NOT EXISTS HASHMAP_DB.SIMULATIONS;

// raw data with offsets for building on-demand simulations
CREATE TABLE IF NOT EXISTS
  HASHMAP_DB.SIMULATIONS.EC2_HACK_RAW 
AS (
  SELECT 
    *,
    DATEDIFF(SECOND, (SELECT MIN(TIMESTAMP_UTC) FROM HASHMAP_DB.SIMULATIONS.EC2_HACK_RAW), TIMESTAMP_UTC) AS SECONDS_OFFSET
  FROM 
    HASHMAP_DB.AWS.CLOUDTRAIL_MONITORING_FLATTENED 
  WHERE 
    EVENT_DATA:"errorCode" = 'Client.InstanceLimitExceeded' 
  ORDER BY 
    TIMESTAMP_UTC DESC
);

// simulation data. Recreate this table to simulate hacks on demand
CREATE OR REPLACE TABLE 
  HASHMAP_DB.SIMULATIONS.EC2_HACK_SIMULATION 
AS (
  SELECT
    OBJECT_CONSTRUCT('cloud', 'AWS', 'SERVICE', 'EC2') AS ENVIRONMENT, 
    ARRAY_CONSTRUCT('cloudtrail') AS SOURCES, 
    EVENT_DATA:"recipientAccountId" AS OBJECT, 
    'Client.InstanceLimitExceeded' AS TITLE, 
    DATEADD(SECOND, SECONDS_OFFSET, CURRENT_TIMESTAMP) AS EVENT_TIME, 
    CURRENT_TIMESTAMP AS ALERT_TIME, 
    ( 
      'Client.InstanceLimitExceeded alert recieved for region ' || 
      EVENT_DATA:"awsRegion" || 
      ' at account ' || 
      EVENT_DATA:"recipientAccountId" || 
      ' from user with arn ' || 
      EVENT_DATA:"userIdentity"."arn" 
    ) AS DESCRIPTION,
    'SnowAlert' AS DETECTOR,
    EVENT_DATA,
    'high' AS SEVERITY,
    EVENT_DATA:"userIdentity"."arn" AS ACTOR,
    EVENT_DATA:"errorCode"::string AS ACTION,
    'SIM_EC2_INSTANCE_LIMIT_EXCEEDED' AS QUERY_ID,
    'SIM_EC2_INSTANCE_LIMIT_EXCEEDED' AS QUERY_NAME
  FROM 
    HASHMAP_DB.SIMULATIONS.EC2_HACK_RAW
);
// ============================================


// ============================================
// create snowalert rule for alerting on 
// the simulation
// ============================================
USE ROLE SNOWALERT;
CREATE OR REPLACE VIEW 
  SNOWALERT.RULES.SIM_EC2_INSTANCE_LIMIT_EXCEEDED_ALERT_QUERY 
AS (
  SELECT
    *
  FROM 
    HASHMAP_DB.SIMULATIONS.EC2_HACK_SIMULATION
);
// ============================================