.. SnowWatch documentation master file, created by
   sphinx-quickstart on Wed May 29 19:40:07 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

.. image:: https://raw.githubusercontent.com/hashmapinc/SnowWatch/master/docs/source/sw-logo-large.png

=======================================================================================================

SNOWWATCH is a collection of SQL commands and automated data harvesting scripts designed to let you efficiently ingest data from multiple cloud environments into the Snowflake Cloud Data Warehouse.

The `Snowflake SnowAlert project <https://github.com/snowflakedb/SnowAlert>`_ is used to provide policy enforcement and alerting to improve the security, compliance, and affordability of your cloud infrastructure.

What SNOWWATCH *is*
---------------------
Working with many clients who implement cloud monitoring solutions (with various levels of success), SNOWWATCH is our best effort at a minimalist and reliable data ingestion pattern. 

The pattern is meant to make cloud data ingestion repeatable and trustworthy. You are encouraged to take the basic patterns in this project and expand them with your business-specific needs. SNOWWATCH is simply a starting point with data engineering best-practices built in.

What SNOWWATCH *is not*
-------------------------
SNOWWATCH is not a platform and it is not a magic solution. This project will not replace your security and site reliability teams. 

However, when used responsibly, this collection of ingestion patterns could save you time and money by allowing your engineers to focus more on business logic and less on setup.

.. toctree::
    :maxdepth: 2
    :caption: Contents:
    :hidden:

    quickstart
    snowalert/deploy
    datasources/datasources

