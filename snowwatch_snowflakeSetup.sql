//===========================================================
// create security objects
//===========================================================
USE ROLE SECURITYADMIN;

CREATE ROLE IF NOT EXISTS
  SNOWWATCH_ROLE
  COMMENT='role used by the snowwatch framework to run queries';
    
CREATE ROLE IF NOT EXISTS
  SNOWALERT_RESULTS_READ_ROLE
  COMMENT='read access to the results schema in the snowalert database';
    
CREATE ROLE IF NOT EXISTS
  SNOWWATCH_BI_READ_ROLE
  COMMENT='read access to data in the BI schema of the SNOWWATCH database';

// grant new roles to sysadmin
GRANT ROLE SNOWWATCH_ROLE TO ROLE SYSADMIN;
GRANT ROLE SNOWALERT_RESULTS_READ_ROLE TO ROLE SYSADMIN;
GRANT ROLE SNOWWATCH_BI_READ_ROLE TO ROLE SYSADMIN;

// grant results read role to snowwatch
GRANT ROLE SNOWALERT_RESULTS_READ_ROLE TO ROLE SNOWWATCH_ROLE;

// grant snowwatch_role to current user
GRANT ROLE SNOWALERT_RESULTS_READ_ROLE TO USER CURRENT_USER; // replace this with your username
//===========================================================


//===========================================================
// create top level objects and give them to snowwatch
//===========================================================
USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS
  SNOWWATCH_WAREHOUSE
  COMMENT='Warehouse for powering snowwatch activities'
  WAREHOUSE_SIZE=XSMALL
  AUTO_SUSPEND=60 // shut this bad boy down as fast as possible in between queries
  INITIALLY_SUSPENDED=TRUE;

CREATE DATABASE IF NOT EXISTS
  SNOWWATCH
  COMMENT='Database for holding snowwatch objects';

// grant ownership
GRANT OWNERSHIP ON WAREHOUSE SNOWWATCH_WAREHOUSE TO ROLE SNOWWATCH_ROLE;
GRANT OWNERSHIP ON DATABASE SNOWWATCH TO ROLE SNOWWATCH_ROLE;
//===========================================================


//===========================================================
// Create snowwatch objects
//===========================================================
// set role
USE ROLE SNOWWATCH_ROLE;

// create schema
CREATE SCHEMA IF NOT EXISTS SNOWWATCH.BI;
//===========================================================


//===========================================================
// grant permissions to roles
//===========================================================
USE ROLE SECURITYADMIN;

// SNOWALERT_RESULTS_READ_ROLE PERMISSIONS
GRANT USAGE ON DATABASE SNOWALERT TO ROLE SNOWALERT_RESULTS_READ_ROLE;
GRANT USAGE ON SCHEMA SNOWALERT.RESULTS TO ROLE SNOWALERT_RESULTS_READ_ROLE;

GRANT SELECT ON ALL VIEWS IN SCHEMA SNOWALERT.RESULTS TO ROLE SNOWALERT_RESULTS_READ_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA SNOWALERT.RESULTS TO ROLE SNOWALERT_RESULTS_READ_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA SNOWALERT.RESULTS TO ROLE SNOWALERT_RESULTS_READ_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA SNOWALERT.RESULTS TO ROLE SNOWALERT_RESULTS_READ_ROLE;

// SNOWWATCH_BI_READ_ROLE PERMISSIONS
GRANT USAGE ON DATABASE SNOWWATCH TO ROLE SNOWWATCH_BI_READ_ROLE;
GRANT USAGE ON SCHEMA SNOWWATCH.BI TO ROLE SNOWWATCH_BI_READ_ROLE;

GRANT SELECT ON ALL VIEWS IN SCHEMA SNOWWATCH.BI TO ROLE SNOWWATCH_BI_READ_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA SNOWWATCH.BI TO ROLE SNOWWATCH_BI_READ_ROLE;
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA SNOWWATCH.BI TO ROLE SNOWWATCH_BI_READ_ROLE;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA SNOWWATCH.BI TO ROLE SNOWWATCH_BI_READ_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA SNOWWATCH.BI TO ROLE SNOWWATCH_BI_READ_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA SNOWWATCH.BI TO ROLE SNOWWATCH_BI_READ_ROLE;
//===========================================================