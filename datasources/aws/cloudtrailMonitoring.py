import boto3
import BytesIO
import gzip
import datetime
import json
import logging
import os
from serializer import datetimeSerializer

logger = logging.getLogger()
logger.setLevel(logging.INFO)

S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']
S3_MONITORING_PATH = os.environ['S3_CLOUDTRAIL_MONITORING_PATH']

def getNewRecordsFromEventObject(event=None):
    """
    This function returns a list of (bucketName, objectKey) tuples
    extracted from the event object.
    """
    if not event or not event["Records"]:
        raise ValueError("no Records to process")
    
    s3Records = [eventRecord['s3'] for eventRecord in event['Records']]
    return [(s3Record['bucket']['name'], s3Record['object']['key']) for s3Record in s3Records]


def loadCloudtrailReportAsJsonObject(sourceBucketName=None, sourceBucketKey=None, s3Client=None):
    """
    This function loads the compressed cloudtrail (gz) json string
    from s3 at the given bucketname and key location. The data is
    then uncompressed to json string format and a parsed json
    object is returned.
    """
    # validate input
    if not sourceBucketName or not sourceBucketKey or not s3Client:
        raise ValueError("cannot accept None / empty values")
    
    # load raw body from s3
    response = s3Client.get_object(Bucket=sourceBucketName, Key=sourceBucketKey)
    rawBody = response['Body'].read()

    # process compressed bytes data into json string
    bodyContent = gzip.GzipFile(fileobj=BytesIO(rawBody)).read()

    # return processed json object
    return json.loads(bodyContent)


def saveProcessedJsonStringToS3(jsonString=None, s3Client=None):
    """
    This function saves the jsonString as a new 
    monitoring report json in the S3_BUCKET_NAME at
    the S3_MONITORING_PATH directory
    """
    # validate input
    if not jsonString or not s3Client:
        raise ValueError("cannot accept None / empty values")

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
    logger.info(f"Event:\n\n{event}\n\n")
    logger.info(f"Context:\n\n{context}\n\n")

    # get (bucketName, objectKey) pairs for new records
    newRecords = getNewRecordsFromEventObject(event)

    # handle each record
    s3Client = boto3.resource("s3")
    for sourceBucketName, sourceBucketKey in newRecords:
        # load new logfile json object
        newLogFile = loadCloudtrailReportAsJsonObject(sourceBucketName, sourceBucketKey, s3Client)

        # process new logfile json object into a json string
        processedJsonString = processLogfile(newLogfile)

        # save processed json string
        saveProcessedJsonStringToS3(processedJsonString, s3Client)

    return "finished monitoring."
