#!/bin/bash

# comment
# ---------------------------
# Require "cfn-lint" you need this command
# $ sudo pip install cfn-lint

# include env
. ./environment/stack_env

# deployment
# ---------------------------
# Stack Validate
RESULT=$(cfn-lint ${TEMPLATE} -i W3010)
#RESULT="throw"
if [ -z "${RESULT}" ]; then
  # ---------------------------
  # S3 Push
  aws s3 cp ./${TEMPLATE} s3://${S3BUCKET}/
  # ---------------------------
  # Stack Update
  aws cloudformation deploy --stack-name ${STACKNAME} \
  --template-file ${TEMPLATE} \
  --s3-bucket ${S3BUCKET} \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-execute-changeset \
  --parameter-overrides \
  EnvTag=${Env} Project=${PJName} \
  VpcCidr=${VpcCidr} \
  PublicSubnetAzACidr=${PublicSubnetAzACidr} \
  PublicSubnetAzDCidr=${PublicSubnetAzDCidr} \
  PrivateSubnetAzACidr=${PrivateSubnetAzACidr} \
  PrivateSubnetAzDCidr=${PrivateSubnetAzDCidr} \
  MaintenanceIp=${MaintenanceIp} WebHealthCheckPath=${WebHealthCheckPath} \
  AcmArn=${AcmArn}
  
  # ---------------------------
  # S3 delete
  aws s3 rm s3://${S3BUCKET}/${TEMPLATE}
fi

echo "${RESULT}"

