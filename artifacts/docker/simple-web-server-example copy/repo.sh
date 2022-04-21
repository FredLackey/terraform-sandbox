#!/bin/bash

aws configure set aws_access_key_id ">> ACCESS KEY HERE <<"
aws configure set aws_secret_access_key ">> SECRET KEY HERE <<"
aws configure set region "us-west-1"

aws ecr get-login-password | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-1.amazonaws.com
aws ecr create-repository --repository-name "simpleweb" --image-tag-mutability MUTABLE 

# "repository": {
#   "repositoryArn": "arn:aws:ecr:us-west-1:123456789012:repository/simpleweb",
#   "registryId": "123456789012",
#   "repositoryName": "simpleweb",
#   "repositoryUri": "123456789012.dkr.ecr.us-west-1.amazonaws.com/simpleweb",
#   "createdAt": 1647687440.0,
#   "imageTagMutability": "MUTABLE",
#   "imageScanningConfiguration": {
#     "scanOnPush": false
#   }
# }
