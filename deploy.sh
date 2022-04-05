#!/bin/bash

set -x

# Preparing the secret variables defined using the prefix "SECRET_".
secrets=$(env | awk -F = '/^SECRET_/ {print $1}')
secrets_list=""
for data in ${secrets}
do
  name=$(echo $data | sed 's/'^SECRET_'//g')
  secrets_list="$secrets_list --param $name=\${$data}"
done

export AWS_REGION="us-east-2"
export DEPLOYMENT_BUCKET="trybe-common-s3-serverless-deployments"
export COMPANY="trybe"

npm i -g serverless@3.x

serverless deploy      \
  --verbose            \
  --region $AWS_REGION \
  --stage $ENVIRONMENT \
  $secrets_list        \
