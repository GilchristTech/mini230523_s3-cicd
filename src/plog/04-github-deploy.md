---
title: GitHub Deployment
---
In [the second plog](plog/02-github-build/) I was regretting adding the
navigation buttons, but now it doesn't feel like time wasted. Anyhoo, deploying
via GitHub.

I told the GitHub repo the following secrets:
  * `AWS_ACCESS_KEY_ID`
  * `AWS_SECRET_ACCESS_KEY`
  * `AWS_REGION`
  * `AWS_S3_BUCKET`
  * `AWS_S3_BUCKET_PATH`: Rather than copying the website files to the root of
    my bucket, I'd like to have them occupy this sub-directory, with a value of
    `mini230523`.

The GitHub Action runner, `act`, supports reading secrets from a `.env` file, so
I put that together (after adding it to `.gitignore`). Next, I updated
`.github/workflows/build.yaml` to the following:
```yaml
name: Build and Deploy

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-node@v3
        with:
          node-version: 19
          cache: npm

      - name: Install packages
        run:  npm ci

      - name: Build static site
        run:  npm run build

      - uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-region:            {{ '${{ secrets.AWS_REGION }}' }}
          aws-access-key-id:     {{ '${{ secrets.AWS_ACCESS_KEY_ID }}' }}
          aws-secret-access-key: {{ '${{ secrets.AWS_SECRET_ACCESS_KEY }}' }}

      - name: Upload site build to S3 bucket
        run: |
          aws s3 sync dist/ s3://{{ '${{ secrets.AWS_S3_BUCKET }}' }}/{{ '${{ secrets.AWS_S3_BUCKET_PATH }}' }} --delete
```

Let's give it a run
```bash
$ act --env-file .env 
```
Aaaand I ran into an issue that the `aws` command wasn't found. Turns out I was
using the medium-size `act` docker image, and that one doesn't have `aws`. I
found a
[GitHub action](https://github.com/marketplace/actions/install-aws-cli-action)
which installs the AWS CLI. This line was added to
`.github/workflows/build.yaml`:
```yaml
  - uses: unfor19/install-aws-cli-action@v1
```
It's a temporary way around this, and I'll delete it later (hopefully, lol).
The new issue is that the `PutObject` operation is getting `AccessDenied`'d.
Turns out I forgot an asterisk in the CloudFormation user policy, whoops!

The static site successfully uploaded to the S3 bucket, but the relative and
root URLs don't point where they need to be. This can be solved by setting the
11ty `pathPrefix`. I had to tweak some stuff to get it working properly. The
`.eleventy.js` file now gets a `PATH_PREFIX` environment variable, which I put
into the GitHub action's build step.

Now the pages on the site can be viewed via HTTP to the S3 bucket's public url!
Well... kinda. 11ty puts `index.html` files throughout the build's directory
structure, and normally this works quite well for resolving URLs, but S3 doesn't
know to redirect requests to these index files. I believe this is handled with
AWS CloudFormation, which I've never actually worked with. So looking into that
is the next step! I've worked on this for nine hours, though, so if it doesn't
appear to be something I can do quickly, I'll be heading to sleep instead.
