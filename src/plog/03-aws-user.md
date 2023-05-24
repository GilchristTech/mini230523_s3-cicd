---
title: AWS User
---

After a minute or two, the GitHub action from the last ran
automatically, and with success!  But nearly four hours into
this project, and I've spent most of it on the frontend. My
commitment in the [first post](/plog/01-initial-commit)
to mainly focus on the build and deployment pipeline
neglected, I seek to remedy this. Next up: getting AWS to be
cool with GitHub. After the GitHub workflow builds the 11ty
site, it should upload the files to an S3 bucket, which I've
named `gill-mini`. Since I've already configured this
bucket (I intend on reusing it with multiple projects), this
part of today's project is about what I'm discovering to be
the bread-and-butter of AWS, permissions. Here's what's
needed:

  * An IAM User
  * A policy which says what the user can and cannot do with
    the bucket.
  * An Access Key for GitHub, which let's it act on the user's
    behalf.
  * This last one's a Secret

For this, I'll use an AWS CloudFormation stack to spin up
and tear down everything. I've got a CloudFormation template
from the similar project I did a couple days ago, but in the
interest of my particular form of rote learning, I'd like to
avoid reading and copying it too actively. On it, I do have
comments for a couple of references I used, though, and
those I think I'll look at:

  * [AWS docs: AWS::IAM::User]( https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-iam-user )
  * [Monica Granbois' post on GitHub/S3/11ty deployment](https://monicagranbois.com/blog/webdev/use-github-actions-to-deploy-11ty-site-to-s3/)
  * [StackOverflow: Declaring an IAM Key Resource by CloudFormation](https://stackoverflow.com/questions/40865710/declaring-an-iam-access-key-resource-by-cloudformation)

Allrighty, let's get goin'

## The files

For organization purposes of this project, I'm creating a dedicated directory for
anything AWS.
```bash
mkdir aws
cd aws
vim user.cf.yaml stack.sh monitor.sh
```

## AWS Bash scripts

When I do AWS stuff in the web console, I get a bit of a
mental block, but I make progress when I learn the AWS
CLI program. My general workflow these days when working
with AWS tends to involve making small shell scripts.
Generally, I try to write new scripts each time so that I
don't forget how to use the AWS CLI. 

Before I get too far in the CloudFormation template, I'd
like to have these files in working order. As such, I'm
starting with *just* this minimalistic template:

### `aws/user.cf.yaml`
```yaml
Resources:
  GithubUser:
    Type: AWS::IAM::User
```

### The stack script

The stack script creates, updates, and deletes the stack.
Here's the code:

#### `aws/stack.sh`
```bash
#!/usr/bin/bash

# Creates, updates, and deletes the CloudFormation GitHub user stack

STACK_NAME="mini230523-user"

if [ $1 = "create" ] || [ $1 = "update" ] ; then
	# Create or update the stack

	aws cloudformation $1-stack --stack-name "${STACK_NAME}" \
		--template-body file://user.cf.yaml \
		--capabilities CAPABILITY_IAM

	aws cloudformation wait stack-$1-complete --stack-name "${STACK_NAME}"

elif [ $1 = "delete" ] ; then
	# Delete the stack

	aws cloudformation delete-stack --stack-name "${STACK_NAME}"
	aws cloudformation wait stack-delete-complete --stack-name "${STACK_NAME}"
fi
```

```bash
$ ./stack create
{
    "StackId": "arn:aws:cloudformation:us-west-2:999999999999:stack/mini230523-user/3332f4a0-f9f3-11ed-bce4-0626acdd9a4b"
}
```

### The monitor script

Manually using the CLI to check the status of the
CloudFormation stack is tedious, and so is using the web
interface which splits things into multiple pages. I've
found that writing shell script leaving it running with the
`watch` command, then placing that terminal on my second
monitor, provides a pretty smooth development experience.

#### `aws/monitor.sh`
```bash
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
```

```bash
$ watch -tc 'sh monitor.sh'
----------------------------------------
|            DescribeStacks            |
+------------------+-------------------+
|  mini230523-user |  CREATE_COMPLETE  |
+------------------+-------------------+
--------------------------------------------------------------------------------------------------------
|                                          DescribeStackEvents                                         |
+-----------------+------------------------------+---------------------+-------------------------------+
|  mini230523-user|  AWS::CloudFormation::Stack  |  CREATE_COMPLETE    |  None                         |
|  GithubUser     |  AWS::IAM::User              |  CREATE_COMPLETE    |  None                         |
|  GithubUser     |  AWS::IAM::User              |  CREATE_IN_PROGRESS |  Resource creation Initiated  |
|  GithubUser     |  AWS::IAM::User              |  CREATE_IN_PROGRESS |  None                         |
|  mini230523-user|  AWS::CloudFormation::Stack  |  CREATE_IN_PROGRESS |  User Initiated               |
+-----------------+------------------------------+---------------------+-------------------------------+
-------------------------------------------------------------------------------
|                           DescribeStackResources                            |
+------------+------------------+---------------------------------------------+
|  GithubUser|  CREATE_COMPLETE |  mini230523-user-GithubUser-10XWC1RL1IAVO   |
+------------+------------------+---------------------------------------------+
```

Good show! The shell scripts seem to be doing their job,
now for the IAM permissions.

## The CloudFormation template

After more distractions of trying to make the monitor script
do some special formatting the stack events (I think I may
have wasted over an hour on this), and just settling on
limiting the number of lines with `head`, I turn my focus to
the important part: the CloudFormation template.

Here's the current iteration:

### `aws/user.cf.yaml`
```yaml
Parameters:
  BucketName:
    Type: String
    Default: gill-mini

Resources:
  GithubUser:
    Type: AWS::IAM::User
    Properties:
      Policies:
        - PolicyName: GithubS3Sync
          PolicyDocument:
            Statement:
            - Effect: Allow
              Action:
                - s3:PutObject
                - s3:GetObject
                - s3:ListBucket
                - s3:DeleteObject
                - s3:GetBucketLocation
              Resource:
                - !Sub arn:aws:s3:::${BucketName}
                - !Sub arn:aws:s3:::${BucketName}/

  GithubAccessKey:
    Type: AWS::IAM::AccessKey
    Properties:
      Status:   Active
      UserName: !Ref GithubUser

  GithubSecret:
    Type: AWS::SecretsManager::Secret
    Properties:
      Name: !Sub /mini/credentials/${GithubUser}
      SecretString: !Sub |
        {
          "AWS_ACCESS_KEY_ID": "${GithubAccessKey}",
          "AWS_SECRET_ACCESS_KEY": "${GithubAccessKey.SecretAccessKey}"
        }
```

In the project from a couple days ago, I used more
restrictive permissions. It's getting late, but if I have
some time, I'll tighten that up a bit.

### SHHH... It's a secret!

To get the secret key, I've got this 'lil script for
fetching it.

#### aws/get-secret.sh
```bash
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
```

The output of this will be copy-pasted into the GitHub
repo's secret editor. In fact, let's call this commit/plog
here, and then git back to the GitHub site of things.
