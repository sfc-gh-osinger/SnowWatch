import boto3
import datetime
import json
import logging
import os
from serializer import datetimeSerializer

logger = logging.getLogger()
logger.setLevel(logging.INFO)

S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']
S3_MONITORING_PATH = os.environ['S3_CLOUDTRAIL_MONITORING_PATH']

def saveProcessedJsonStringToS3(jsonString=None, s3Client):
    """
    This function saves the jsonString as a new 
    monitoring report json in the S3_BUCKET_NAME at
    the S3_MONITORING_PATH directory
    """
    # validate input
    if not jsonString:
        raise ValueError

    # get s3 key and body
    key = S3_MONITORING_PATH + '/' + datetime.datetime.utcnow().isoformat() + '.json'
    body = jsonString.encode("utf-8")

    # save to s3
    logger.info(f"creating new monitoring report at s3://{S3_BUCKET_NAME}/{key}")
    s3Client.Bucket(S3_BUCKET_NAME).put_object(Key=key, Body=body)


def monitor(event, context):
    """
    This method reads cloudtrail logs and writes
    snowflake-friendly, preprocessed json files with the 
    cloudtrail data to s3.
    """
    logger.info(f"Event:\n{event}\n\n")
    logger.info(f"Context:\n{context}\n\n")

    # get bucket / s3_key pairs for new records
    newRecords = getNewRecordsFromEventObject(event)

    # handle each record
    s3Client = boto3.resource("s3")
    for (sourceBucketName, sourceBucketKey) in newRecords:
        # load new logfile json object
        newLogFile = loadLogfile(sourceBucketName, sourceBucketKey)

        # process new logfile json object into a json string
        processedJsonString = processLogfile(newLogfile)

        # save processed json string
        saveProcessedJsonStringToS3(processedJsonString, s3Client)

    return "finished monitoring."
