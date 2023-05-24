#!/usr/bin/bash

# Prints info on the CloudFormation GitHub user stack

STACK_NAME="mini230523-user"

aws cloudformation describe-stacks \
	--stack-name "${STACK_NAME}" --output table \
	--query 'Stacks[][StackName,StackStatus]'

# If the stack wasn't found, we'll get a non-zero error code. Everything else in
# this script depends on the stack existing, so let's exit.
DESCRIBE_STACK_EXIT_CODE=$?
if [[ $DESCRIBE_STACK_EXIT_CODE -ne 0 ]] ; then
	exit $DESCRIBE_STACK_EXIT_CODE
fi

aws cloudformation describe-stack-events \
	--stack-name "${STACK_NAME}" --output table \
	--query 'StackEvents[][LogicalResourceId,ResourceType,ResourceStatus,ResourceStatusReason]' \
	| head -n 12 

aws cloudformation describe-stack-resources \
	--stack-name "${STACK_NAME}" --output table \
	--query 'StackResources[][LogicalResourceId,ResourceStatus,PhysicalResourceId]'
