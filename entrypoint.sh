#!/bin/bash

# Build section
npm install -g serverless@3.12.0 &>/dev/null

# Preparing the secret variables defined using the prefix "SECRET_".
secrets=$(env | awk -F = '/^SECRET_/ {print $1}')
secrets_list=""
for data in ${secrets}
do
  name=$(echo $data | sed 's/'^SECRET_'//g')
  secrets_list="$secrets_list --param $name=\${$data}"
done

# Reading custom variables from the secret
SERVERLESS_SETTINGS=${SERVERLESS_SETTINGS_OVERRIDE:-$SERVERLESS_SETTINGS}
echo $SERVERLESS_SETTINGS | base64 -d > settings.yml

echo "::group::Final 'settings.yml' File"
cat settings.yml
echo "::endgroup::"

# Allow the loop below to work properly.
IFS='
'

# Transforming settings.yml variables to parameters
keys=($(yq e 'keys | .[]' settings.yml))
values=($(yq e '.[]' settings.yml))
for index in ${!keys[*]}
do
  parameters_list="$parameters_list --param \"${keys[$index]}=${values[$index]}\""
done

# Merge template and app yml files
cp $GITHUB_ACTION_PATH/template.yml .
yq eval-all '. as $item ireduce ({}; . * $item )' template.yml serverless.yml > /tmp/a.yml

# Force log retention value
yq e '(.functions[]) .logRetentionInDays |= 7' /tmp/a.yml > /tmp/b.yml

# Handle RabbitMQ ARN and credentials, if needed.
yq e '(.functions[].events[] | select(. | has("activemq"))) .activemq.arn = "${param:rabbitMQArn}"' /tmp/b.yml > /tmp/a.yml
yq e '(.functions[].events[] | select(. | has("activemq"))) .activemq.basicAuthArn = "${param:rabbitMQCredentialsArn}"' /tmp/a.yml > serverless.yml

echo "::group::Final 'serverless.yml' File"
cat serverless.yml
echo "::endgroup::"

echo "::group::Executing '$COMMAND' using serverless framework..."
bash -c " \
  serverless $COMMAND  \
  --verbose            \
  --stage $ENVIRONMENT \
  $parameters_list     \
  $secrets_list        \
"
echo "::endgroup::"
echo "Done!"
