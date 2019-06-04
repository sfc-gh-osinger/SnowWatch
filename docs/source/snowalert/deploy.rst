.. _snowalert-deploy:

SnowAlert Deployment
====================

A core part of the SnowWatch platform is the deployment of the `SnowAlert security analytics framework. <https://github.com/snowflakedb/SnowAlert/>`_

This framework is provided as a docker image hosted at docker hub `here <https://hub.docker.com/r/snowsec/snowalert>`_
There are 2 docker images:

1. The snowsec/snowalert which is responsible for generating the alerts and violations
2. The snowsec/snowalert-webui which is the administration interface for SnowAlert. This container hosts a web application that allows a user to input an alert/violation/supression query.

There are several ways to orchestrate the containers.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   k8s
   fargate
   linux
