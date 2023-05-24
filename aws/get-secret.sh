#!/usr/bin/bash

STACK_NAME="mini230523-user"

SECRET_ARN=$( \
	aws cloudformation describe-stack-resources --stack-name $STACK_NAME --output text \
	--query 'StackResources[?LogicalResourceId == `GithubSecret`].PhysicalResourceId' \
)

aws secretsmanager get-secret-value \
	--secret-id "${SECRET_ARN}" \
	--query 'SecretString' --output text  \
	| python -m json.tool
