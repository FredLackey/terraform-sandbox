#!/bin/bash

aws configure set aws_access_key_id ">> ACCESS KEY HERE <<"
aws configure set aws_secret_access_key ">> SECRET KEY HERE <<"
aws configure set region "us-west-1"

aws ecr get-login-password | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-1.amazonaws.com
aws ecr create-repository --repository-name "simpleapi" --image-tag-mutability MUTABLE 

# "repository": {
#   "repositoryArn": "arn:aws:ecr:us-west-1:123456789012:repository/simpleapi",
#   "registryId": "123456789012",
#   "repositoryName": "simpleapi",
#   "repositoryUri": "123456789012.dkr.ecr.us-west-1.amazonaws.com/simpleapi",
#   "createdAt": 1647687440.0,
#   "imageTagMutability": "MUTABLE",
#   "imageScanningConfiguration": {
#     "scanOnPush": false
#   }
# }
