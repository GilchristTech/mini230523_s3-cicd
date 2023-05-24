module.exports = function (config) {
	config.addPassthroughCopy("static");
	config.addPlugin(require("eleventy-sass"));
	config.addPlugin(require("@11ty/eleventy").EleventyHtmlBasePlugin);

	config.addFilter("search", require("jmespath").search);

	return {
		dir: { input: "src", output: "dist", includes: "includes", data: "data" },
		pathPrefix: null
	};
};
