---
title: CloudFront
---

Looking at the GitHub action log, the deployment ran! Commits should now result
in automatic deployment. This leaves the `index.html`s issue. This appears to be
an AWS CloudFront thing. So here's my reading material:

* [Implementing Default Directory Indexes in Amazon S3-backed Amazon CloudFront
Origins Using CloudFront Functions](https://aws.amazon.com/blogs/networking-and-content-delivery/implementing-default-directory-indexes-in-amazon-s3-backed-amazon-cloudfront-origins-using-cloudfront-functions/)
* [Steps for creating a distribution (overview)](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-creating.html)

Using the web console, I created a CloudFront distribution.  The site still
seems to be reachable. Luckily, as it is approaching 3AM, it didn't take too
long to get this working. I wrote a function associated with the CloudFront
distribution which is almost identical (not visually
identical, but functionally identical) to the example given by Amazon for
addressing this issue:
```javascript
function handler(event) {
    const request = event.request;
    if (request.uri.endsWith("/")) {
        request.uri += 'index.html';
    }
    else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }

    return request;
}
```

Now, this seems really interesting to me, being able to write scripts which
intercept requests and change which files in the bucket get sent back to the
client. This seems like it could be used for more sophisticated URL
transformations, or for something as simple as a custom 404 page. I'd like to
study CloudFront more some time!
