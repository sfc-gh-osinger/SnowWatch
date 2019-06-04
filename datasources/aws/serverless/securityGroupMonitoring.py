import boto3
import datetime
import json
import logging
import os
from serializer import datetimeSerializer

logger = logging.getLogger()
logger.setLevel(logging.INFO)

S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']
S3_MONITORING_PATH = os.environ['S3_SG_MONITORING_PATH']

def getAllSecurityGroups():
    """
    This function grabs each security group from each region and returns
    a list of the security groups. 

    Each security group is manually given a 'Region' field for clarity
    """
    regions = boto3.client('ec2').describe_regions()['Regions']
    logger.info(f"searching {len(regions)} region(s).")

    # get list of all groups in each region
    securityGroups = []
    for region in regions:
        ec2 = boto3.client('ec2', region_name=region['RegionName'])
        for group in ec2.describe_security_groups()['SecurityGroups']:
            group["Region"] = region
            securityGroups.append(group)

    # return list of groups
    logger.info(f"succesfully serialized {len(securityGroups)} group(s).")
    return securityGroups


def monitor(event, context):
    """
    This method looks for security groups and reports
    any found groups to a json file in s3.
    """
    groups = getAllSecurityGroups()

    if len(groups) is 0:
        logger.warning("no security groups found")
        return

    # get s3 key and body
    key = S3_MONITORING_PATH + '/' + datetime.datetime.utcnow().isoformat() + '.json'
    body = json.dumps(groups, default=datetimeSerializer).encode("utf-8")

    # save to s3
    logger.info(f"creating new monitoring report at s3://{S3_BUCKET_NAME}/{key}")
    s3 = boto3.resource("s3")
    s3.Bucket(S3_BUCKET_NAME).put_object(Key=key, Body=body)

    return "finished monitoring."
