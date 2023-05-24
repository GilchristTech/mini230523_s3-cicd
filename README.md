# Mini 05/23/23
This is a single-day (mini) project for deploying a static 11ty site to an AWS
S3 bucket, using GitHub actions.

## Building
`npm run build`

## Directory breakdown
This repo hosts both the static site code and cloud code, and different directories have
different purposes.

	* `src/`: Static 11ty site source code
	* `static/`: Static files for the 11ty site
	* `.github/workflows/`: GitHub actions code
	* `aws/`: Scripts and templates for AWS
