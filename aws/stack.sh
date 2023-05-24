#!/usr/bin/bash

# Creates, updates, and deletes the CloudFormation GitHub user stack

STACK_NAME="mini230523-user"

if [ $1 = "create" ] || [ $1 = "update" ] ; then
	# Create or update the stack

	aws cloudformation $1-stack --stack-name "${STACK_NAME}" \
		--template-body file://user.cf.yaml \
		--capabilities CAPABILITY_IAM

	# Exit if something went wrong
	if [[ $? -ne 0 ]] ; then
		exit
	fi

	aws cloudformation wait stack-$1-complete --stack-name "${STACK_NAME}"

elif [ $1 = "delete" ] ; then
	# Delete the stack

	aws cloudformation delete-stack --stack-name "${STACK_NAME}"

	# Exit if something went wrong
	if [[ $? -ne 0 ]] ; then
		exit
	fi

	aws cloudformation wait stack-delete-complete --stack-name "${STACK_NAME}"
fi
