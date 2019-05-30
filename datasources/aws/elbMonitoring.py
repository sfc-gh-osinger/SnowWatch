import boto3
import datetime
import json
import logging
import os
from serializer import datetimeSerializer

logger = logging.getLogger()
logger.setLevel(logging.INFO)

S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']
S3_MONITORING_PATH = os.environ['S3_ELB_MONITORING_PATH']

def getAllV1ELBs():
    """
    This function grabs each classic elb from each region and returns
    a list of them.
    """
    regions = boto3.client('ec2').describe_regions()['Regions']
    logger.info(f"searching {len(regions)} region(s) for classic load balancers.")

    # get list of all load balancers in each region
    elbs = []
    for region in regions:
        elbClient = boto3.client('elb', region_name=region['RegionName'])
        for elb in elbClient.describe_load_balancers()['LoadBalancerDescriptions']:
            # add region before adding elb to list of elbs
            elb["Region"] = region
            elbs.append(elb)

    # return list of load balancers
    logger.info(f"succesfully serialized {len(elbs)} classic elastic load balancers(s).")
    return elbs


def getAllV2ELBs():
    """
    This function grabs each v2 elb from each region and returns
    a list of them.
    """
    regions = boto3.client('ec2').describe_regions()['Regions']
    logger.info(f"searching {len(regions)} region(s) for modern load balancers.")

    # get list of all load balancers in each region
    elbs = []
    for region in regions:
        elbClient = boto3.client('elbv2', region_name=region['RegionName'])
        for elb in elbClient.describe_load_balancers()['LoadBalancers']:
            # add region
            elb["Region"] = region

            # add listeners to see which SSL policies are attached to this elb
            elbArn = elb['LoadBalancerArn']
            listeners = elbClient.describe_listeners(LoadBalancerArn=elbArn)
            elb["Listeners"] = listeners # add listeners as feild in the ELB

            elbs.append(elb)

    # return list of load balancers
    logger.info(f"succesfully serialized {len(elbs)} modern elastic load balancers(s).")
    return elbs

def monitor(event, context):
    """
    This method looks for elastic load balancers and reports
    any found elbs to a json file in s3.
    """
    v1ELBs = getAllV1ELBs()
    v2ELBs = getAllV2ELBs()
    elbs = [] + v1ELBs + v2ELBs

    if len(elbs) is 0:
        logger.warning("no elastic load balancers found")
        return

    # get s3 key and body
    key = S3_MONITORING_PATH + '/' + datetime.datetime.utcnow().isoformat() + '.json'
    body = json.dumps(elbs, default=datetimeSerializer).encode("utf-8")

    # save to s3
    logger.info(f"creating new monitoring report at s3://{S3_BUCKET_NAME}/{key}")
    s3 = boto3.resource("s3")
    s3.Bucket(S3_BUCKET_NAME).put_object(Key=key, Body=body)

    return "finished monitoring."
