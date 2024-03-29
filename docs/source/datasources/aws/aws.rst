.. _datasources-aws:

.. image:: https://raw.githubusercontent.com/hashmapinc/SnowWatch/master/docs/source/sw-logo-large.png

=======================================================================================================

AWS Datasource
==============
The SNOWWATCH AWS Datasource is designed to gather data about your AWS infrastructure in a private S3 bucket owned entirely by you. 

We then setup ingestion pipelines from your S3 bucket into Snowflake for further analysis. The data in this S3 bucket is formatted in such a way that Snowflake can easily ingest the data as it arrives.

Serverless
----------
This datasource leverages the `Serverless Framework <https://serverless.com/>`_ to deploy a series of Lambda functions and Cloudformation templates to start organizing your AWS data seamlessly.

None of this monitoring data will ever leave your environment (unless you grant external access to your S3 bucket, like what is done in the Snowflake Setup). 

The following AWS resources are deployed by this datasource:

- S3 bucket for serverless deployments
- S3 bucket for storing your harvested data and cloudtrail
- Cloudtrail Trail 
- 5 Lambda functions that gather data from AWS and saves the data as JSON files in S3
- IAM roles granting read access to your EC2, ELB, and IAM data

The data gathered by this serverless application is stored in your S3 bucket with the following directories:

- ``cloudtrail`` -> raw output from your Cloudtrail Trail (not easily consumed by Snowflake)
- ``cloudtrail_monitoring`` -> processed output from a Lambda function that monitors new cloudtrail logs (easily consumed by Snowflake)
- ``ec2_monitoring`` -> processed output from a Lambda function that monitors ec2 instance metadata
- ``elb_monitoring`` -> processed output from a Lambda function that monitors elastic load balancer metadata 
- ``iam_monitoring`` -> processed output from a Lambda function that monitors users, groups, roles, and policies from IAM
- ``security_group_monitoring`` -> processed output from a Lambda function that monitors security group metadata

Snowflake
---------
To enable realtime data ingestion from AWS, the following objects are created in Snowflake:

- an ``AWS`` schema in your ``SNOWWATCH`` database
- ``LANDING_ZONE`` tables in the ``AWS`` schema for holding ingested data
- an S3 external stage 
- a json file format within the ``AWS`` schema for reading monitoring files generated by the AWS Lambda functions
- a series of snowpipes that auto-ingest json files from s3 as they arrive

Installation Instructions
-------------------------
:ref:`See detailed installation instructions here. <datasources-aws-installation>`

.. toctree::
  :hidden:

  awsInstallation