#!/bin/bash

# Build section
#wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O yq && chmod +x yq && mv yq /usr/bin/yq
npm i -g serverless@3.12.0

# Preparing the secret variables defined using the prefix "SECRET_".
secrets=$(env | awk -F = '/^SECRET_/ {print $1}')
secrets_list=""
for data in ${secrets}
do
  name=$(echo $data | sed 's/'^SECRET_'//g')
  secrets_list="$secrets_list --param $name=\${$data}"
done

# Reading custom variables from the secret
echo $SERVERLESS_SETTINGS | base64 -d > settings.yaml

echo "::group::Final 'settings.yaml' File"
cat settings.yaml
echo "::endgroup::"

# Allow the loop below to work properly.
IFS='
'

# Transforming settings.yaml variables to parameters
keys=($(yq e 'keys | .[]' settings.yaml))
values=($(yq e '.[]' settings.yaml))
for index in ${!keys[*]}
do
  parameters_list="$parameters_list --param \"${keys[$index]}=${values[$index]}\""
done

# Merge template and app yaml files
yq eval-all '. as $item ireduce ({}; . * $item )' template.yaml app.yaml > /tmp/a.yaml

# Force log retention value
yq e '(.functions[]) .logRetentionInDays |= 7' /tmp/a.yaml > /tmp/b.yaml

# Handle RabbitMQ ARN and credentials, if needed.
yq e '(.functions[].events[] | select(. | has("activemq"))) .activemq.arn = "${param:rabbitMQArn}"' /tmp/b.yaml > /tmp/a.yaml
yq e '(.functions[].events[] | select(. | has("activemq"))) .activemq.basicAuthArn = "${param:rabbitMQCredentialsArn}"' /tmp/a.yaml > serverless.yaml

echo "::group::Final 'serverless.yaml' File"
cat serverless.yaml
echo "::endgroup::"

echo "::group::Deploy using serverless framework..."
bash -c " \
  serverless deploy    \
  --verbose            \
  --stage $ENVIRONMENT \
  $parameters_list     \
  $secrets_list        \
"
echo "::endgroup::"
echo "Done!"
