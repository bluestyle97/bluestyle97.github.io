module.exports = {
  content: ["_site/**/*.html", "_site/**/*.js"],
  css: ["_site/assets/css/*.css"],
  output: "_site/assets/css/",
  skippedContentGlobs: ["_site/assets/**/*.html"],
  // Keep the whole grid regardless of what the current markup happens to use.
  //
  // purgecss rewrites the vendor stylesheets in place, but `bust_file_cache` hashes the
  // *source* file, which never changes. So when a template starts using a column class
  // that was previously purged, the deployed CSS changes while its cache-busting query
  // does not, and browsers keep serving a copy that is missing the new rules until the
  // 10-minute max-age expires. Safelisting the grid keeps the purged output stable
  // across layout edits, for a few KB.
  safelist: {
    standard: [/^col-/, /^row$/, /^offset-/, /^order-/],
  },
};
