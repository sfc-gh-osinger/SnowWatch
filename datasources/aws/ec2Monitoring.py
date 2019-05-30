import boto3
import datetime
import json
import logging
import os
from serializer import datetimeSerializer

logger = logging.getLogger()
logger.setLevel(logging.INFO)

S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']
S3_MONITORING_PATH = os.environ['S3_EC2_MONITORING_PATH']


def getInstanceName(instance=None):
    """
    This method searches an ec2 instance object
    for the Name tag and returns that value as a string
    """
    # return the name if possible, return empty string if not possible
    try:
        for tag in instance["Tags"]:
            if "Name" == tag["Key"]:
                return tag["Value"]
    except Exception as e:
        logger.warning(f"could not extract instance name from [{instance}]")
    
    return ""

def getAllInstances():
    """
    This method returns a list containing each
    ec2 instance from each region
    """
    regions = boto3.client('ec2').describe_regions()['Regions']
    logger.info(f"searching {len(regions)} region(s).")

    # get list of all instances in each region
    instances = []
    for region in regions:
        reservations = boto3.client('ec2', region_name=region['RegionName']).describe_instances()["Reservations"]
        for reservation in reservations:
            for instance in reservation['Instances']:
                instance["Region"] = region
                instance["InstanceName"] = getInstanceName(instance)
                instances.append(instance)

    # return list of instances
    logger.info(f"succesfully serialized {len(instances)} instance(s).")
    return instances

def monitor(event, context):
    """
    This method looks for ec2 instances and reports
    any found instances to a json file in s3.
    """
    instances = getAllInstances()

    if len(instances) is 0:
        logger.warning("no instances found")
        return

    # get s3 key and body
    key = S3_MONITORING_PATH + '/' + datetime.datetime.utcnow().isoformat() + '.json'
    body = json.dumps(instances, default=datetimeSerializer).encode("utf-8")

    # save to s3
    logger.info(f"creating new monitoring report at s3://{S3_BUCKET_NAME}/{key}")
    s3 = boto3.resource("s3")
    s3.Bucket(S3_BUCKET_NAME).put_object(Key=key, Body=body)

    return "finished monitoring."
