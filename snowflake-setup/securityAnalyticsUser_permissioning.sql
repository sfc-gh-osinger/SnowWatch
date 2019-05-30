/**
 * This script is used to grant missing permissions to
 * the existing SECURITYANALYTICS role used by the 
 * SECURITYANALYTICS user with the SECURITYANALYTICS warehouse.
 *
 * See the sigmaSetup.sql script for building a sigma service
 * account from scratch.
 *
 * This script MUST be run after the sigmaSetup.sql script because
 * it relies on security objects defined there.
 */
//===========================================================
// assign roles
//===========================================================
USE ROLE SECURITYADMIN;

GRANT ROLE SIGMA_ROLE TO ROLE SECURITYANALYTICS;
//===========================================================