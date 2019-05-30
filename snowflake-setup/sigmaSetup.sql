//===========================================================
// create warehouse
//===========================================================
USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS
  SIGMA_WAREHOUSE
  COMMENT='Warehouse for powering Sigma Computing queries'
  WAREHOUSE_SIZE=XSMALL
  AUTO_SUSPEND=60 // shut this bad boy down as fast as possible in between queries
  INITIALLY_SUSPENDED=TRUE;
//===========================================================


//===========================================================
// create security objects
//===========================================================
USE ROLE SECURITYADMIN;

CREATE USER IF NOT EXISTS 
  SIGMA_SERVICE_ACCOUNT 
  COMMENT='Account for sigma computing authentication'
  PASSWORD="my super cool password." // use your own password, dummy
  MUST_CHANGE_PASSWORD=false; 

CREATE ROLE IF NOT EXISTS
    SIGMA_ROLE
    COMMENT='role used by the sigma service account to run queries';
    
CREATE ROLE IF NOT EXISTS
    SNOWALERT_READ_ROLE
    COMMENT='read access to the snowalert database';
    
CREATE ROLE IF NOT EXISTS
    HASHMAP_DATA_READ_ROLE
    COMMENT='read access to data in the hashmap database';
//===========================================================


//===========================================================
// assign roles
//===========================================================
USE ROLE SECURITYADMIN;

GRANT ROLE SIGMA_ROLE TO USER SIGMA_SERVICE_ACCOUNT;
GRANT ROLE SNOWALERT_READ_ROLE TO USER SIGMA_SERVICE_ACCOUNT;
GRANT ROLE HASHMAP_DATA_READ_ROLE TO USER SIGMA_SERVICE_ACCOUNT;

GRANT ROLE SIGMA_ROLE TO ROLE SYSADMIN;
GRANT ROLE SNOWALERT_READ_ROLE TO ROLE SYSADMIN;
GRANT ROLE HASHMAP_DATA_READ_ROLE TO ROLE SYSADMIN;

GRANT ROLE SNOWALERT_READ_ROLE TO ROLE SIGMA_ROLE;
GRANT ROLE HASHMAP_DATA_READ_ROLE TO ROLE SIGMA_ROLE;
//===========================================================


//===========================================================
// grant permissions to roles
//===========================================================
USE ROLE SECURITYADMIN;

// SIGMA_ROLE PERMISSIONS
GRANT USAGE ON WAREHOUSE SIGMA_WAREHOUSE TO ROLE SIGMA_ROLE;


// SNOWALERT_READ_ROLE PERMISSIONS
GRANT USAGE ON DATABASE SNOWALERT TO ROLE SNOWALERT_READ_ROLE;

GRANT USAGE ON SCHEMA SNOWALERT.DATA TO ROLE SNOWALERT_READ_ROLE;
GRANT USAGE ON SCHEMA SNOWALERT.RESULTS TO ROLE SNOWALERT_READ_ROLE;
GRANT USAGE ON SCHEMA SNOWALERT.RULES TO ROLE SNOWALERT_READ_ROLE;

GRANT SELECT ON ALL VIEWS IN SCHEMA SNOWALERT.DATA TO ROLE SNOWALERT_READ_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA SNOWALERT.DATA TO ROLE SNOWALERT_READ_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA SNOWALERT.DATA TO ROLE SNOWALERT_READ_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA SNOWALERT.DATA TO ROLE SNOWALERT_READ_ROLE;

GRANT SELECT ON ALL VIEWS IN SCHEMA SNOWALERT.RESULTS TO ROLE SNOWALERT_READ_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA SNOWALERT.RESULTS TO ROLE SNOWALERT_READ_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA SNOWALERT.RESULTS TO ROLE SNOWALERT_READ_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA SNOWALERT.RESULTS TO ROLE SNOWALERT_READ_ROLE;

GRANT SELECT ON ALL VIEWS IN SCHEMA SNOWALERT.RULES TO ROLE SNOWALERT_READ_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA SNOWALERT.RULES TO ROLE SNOWALERT_READ_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA SNOWALERT.RULES TO ROLE SNOWALERT_READ_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA SNOWALERT.RULES TO ROLE SNOWALERT_READ_ROLE;


// HASHMAP_DATA_READ_ROLE PERMISSIONS
GRANT USAGE ON DATABASE HASHMAP_DB TO ROLE HASHMAP_DATA_READ_ROLE;

GRANT USAGE ON SCHEMA HASHMAP_DB.AWS TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT USAGE ON SCHEMA HASHMAP_DB.AWS_INVENTORY TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT USAGE ON SCHEMA HASHMAP_DB.HR TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT USAGE ON SCHEMA HASHMAP_DB.SECOPS TO ROLE HASHMAP_DATA_READ_ROLE;

GRANT SELECT ON ALL VIEWS IN SCHEMA HASHMAP_DB.AWS TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA HASHMAP_DB.AWS TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HASHMAP_DB.AWS TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA HASHMAP_DB.AWS TO ROLE HASHMAP_DATA_READ_ROLE;

GRANT SELECT ON ALL VIEWS IN SCHEMA HASHMAP_DB.AWS_INVENTORY TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA HASHMAP_DB.AWS_INVENTORY TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HASHMAP_DB.AWS_INVENTORY TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA HASHMAP_DB.AWS_INVENTORY TO ROLE HASHMAP_DATA_READ_ROLE;

GRANT SELECT ON ALL VIEWS IN SCHEMA HASHMAP_DB.HR TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA HASHMAP_DB.HR TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA HASHMAP_DB.SECOPS TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA HASHMAP_DB.SECOPS TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HASHMAP_DB.HR TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA HASHMAP_DB.HR TO ROLE HASHMAP_DATA_READ_ROLE;

GRANT SELECT ON ALL VIEWS IN SCHEMA HASHMAP_DB.SECOPS TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA HASHMAP_DB.SECOPS TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA HASHMAP_DB.SECOPS TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA HASHMAP_DB.SECOPS TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HASHMAP_DB.SECOPS TO ROLE HASHMAP_DATA_READ_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA HASHMAP_DB.SECOPS TO ROLE HASHMAP_DATA_READ_ROLE;
//===========================================================