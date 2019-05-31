import boto3
from io import BytesIO
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


def loadCloudtrailRecordsAsJsonObject(sourceBucketName=None, sourceBucketKey=None, s3Client=None):
    """
    This function loads the compressed cloudtrail (gz) json string
    from s3 at the given bucketname and key location. The data is
    then uncompressed to json string format and parsed as a json
    object. The 'Records' feild of the parsed json object is 
    returned. If no Records field is found, None is returned
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
    cloudtrailReport = json.loads(bodyContent)
    return cloudtrailReport.setdefault('Records', None)


def getProcessedCloudtrailRecords(cloudtrailRecords=None):
    """
    This function accepts the 'Records' portion of a
    cloudtrail monitoring report as a json object
    and extracts values for a valid json string that can
    be stored in s3 and read by snowflake. The json string
    will be an array of json objects parsed from the 
    cloudtrailRecords list.
    """
    # validate input
    if not cloudtrailRecords :
        raise ValueError('cannot accept None / empty values')

    # get initialize processed records list
    processedRecords = []

    # build processed data
    for cloudtrailRecord in cloudtrailRecords:
        processedRecord = {}
        processedRecord['EVENT_DATA'] = cloudtrailRecord
        processedRecord['EVENT_REGION_NAME'] = cloudtrailRecord.setdefault('awsRegion', None)
        processedRecord['EVENT_NAME'] = cloudtrailRecord.setdefault('eventName', None)
        processedRecord['EVENT_SOURCE'] = cloudtrailRecord.setdefault('eventSource', None)
        processedRecord['EVENT_TIME'] = cloudtrailRecord.setdefault('eventTime', None)
        processedRecord['EVENT_TYPE'] = cloudtrailRecord.setdefault('eventType', None)
        processedRecord['EVENT_SOURCE_IP'] = cloudtrailRecord.setdefault('sourceIPAddress', None)
        processedRecord['EVENT_USER_AGENT'] = cloudtrailRecord.setdefault('userAgent', None)
        processedRecord['EVENT_USER_ARN'] = cloudtrailRecord.setdefault('userIdentity', {}).setdefault('arn', None)
        processedRecords.append(processedRecord)

    return json.dumps(processedRecords)


def saveProcessedJsonStringToS3(jsonString=None, s3Resource=None):
    """
    This function saves the jsonString as a new 
    monitoring report json in the S3_BUCKET_NAME at
    the S3_MONITORING_PATH directory
    """
    # validate input
    if not jsonString or not s3Resource:
        raise ValueError("cannot accept None / empty values")

    # get s3 key and body
    key = S3_MONITORING_PATH + '/' + datetime.datetime.utcnow().isoformat() + '.json'
    body = jsonString.encode("utf-8")

    # save to s3
    logger.info(f"creating new monitoring report at s3://{S3_BUCKET_NAME}/{key}")
    s3Resource.Bucket(S3_BUCKET_NAME).put_object(Key=key, Body=body)


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
    s3Client = boto3.client('s3')
    s3Resource = boto3.resource('s3')
    for sourceBucketName, sourceBucketKey in newRecords:
        try:
            # load new cloudtrail json object
            cloudtrailRecords = loadCloudtrailRecordsAsJsonObject(sourceBucketName, sourceBucketKey, s3Client)

            # process new cloudtrail records json object into a json string
            processedJsonString = getProcessedCloudtrailRecords(cloudtrailRecords)

            # save processed json string
            saveProcessedJsonStringToS3(processedJsonString, s3Resource)

        except Exception as e:
            logger.error(
                f'received error [{e}] ' +
                f'while processing cloudtrail record at bucket [{sourceBucketName}] ' +
                f'with key [{sourceBucketKey}] '
            )

    return "finished monitoring."
