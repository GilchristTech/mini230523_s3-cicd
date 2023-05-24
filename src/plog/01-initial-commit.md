---
title: "Initial Commit: Static Site"
---
At one hour, forty minutes into this project, I have a basic 11ty-based
blog-style site. Here's some points about it:
* Discovery: `vmin` units are great for margins and padding of large
  elements.
* I have an index page at [/plog/](/plog/). Initially, I had placed this in
	`src/plog/index.njk`, but had discovered that moving it to `src/plog.njk`
	gets the URL where it needs to be, while also excluding it from the `plog`
	collection.
* As I learned with a recent static web project, including the
  NodeJS [Jmespath modules](https://www.npmjs.com/package/jmespath) `search`
	function as a filter in my `.eleventy.js` config results in a very powerful
	tool for working with data in 11ty.

After this, I'm going to focus less on the frontend of the site, and more on the CI/CD site of things. AWS S3 for hosting, and GitHub Actions for building and deployment.
