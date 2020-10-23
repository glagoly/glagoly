'use strict';

var $            = require('gulp-load-plugins')();
var argv         = require('yargs').argv;
var autoprefixer = require('autoprefixer');
var browser      = require('browser-sync');
var gulp         = require('gulp');
var named        = require('vinyl-named');
var rimraf       = require('rimraf');
var webpack      = require('webpack-stream');
const path       = require('path');


// Check for --production flag
var PRODUCTION = !!(argv.production);

// Port to use for the development server.
var PORT = 8000;

// Browsers to target when prefixing CSS.
var COMPATIBILITY = '*';

// File paths to various assets are defined here.
var PATHS = {
  assets: [
    'src/assets/favicon.ico',
  ],
  sass: [
    'node_modules/foundation-sites/scss',
    'node_modules/motion-ui/src',
  ],
  dist: 'apps/web/priv/static',
  javascript: [
    // N20
    'deps/n2o/priv/protocols/bert.js',
    'deps/n2o/priv/protocols/client.js',
    'deps/n2o/priv/protocols/nitrogen.js',
    'deps/n2o/priv/bullet.js',
    'deps/n2o/priv/n2o.js',
    'deps/n2o/priv/utf8.js',
    // 'deps/n2o/priv/utf8.js',
    'deps/n2o/priv/validation.js',
    // App
    'src/assets/js/utf8.js',
    'src/assets/js/app.js'
  ]
};

// Build the "dist" folder by running all of the below tasks
gulp.task('build',
 gulp.series(clean, gulp.parallel(javascript, images, copy, sass)));

// Build the site, run the server, and watch for file changes
gulp.task('default',
  gulp.series('build', server, watch));

// Delete the "dist" folder
// This happens every time a build starts
function clean(done) {
  rimraf(PATHS.dist, done);
}

// Copy files out of the assets folder
// This task skips over the "img", "js", and "scss" folders, which are parsed separately
function copy() {
  return gulp.src(PATHS.assets)
    .pipe(gulp.dest(PATHS.dist));
}

// Compile Sass into CSS
// In production, the CSS is compressed
function sass() {
  return gulp.src('src/assets/scss/app.scss')
    .pipe($.sourcemaps.init())
    .pipe($.sass({
      includePaths: PATHS.sass,
    })
      .on('error', $.sass.logError))
    .pipe($.postcss([autoprefixer()]))
    .pipe($.if(PRODUCTION, $.cleanCss({ compatibility: COMPATIBILITY })))
    .pipe($.if(!PRODUCTION, $.sourcemaps.write()))
    .pipe(gulp.dest(PATHS.dist + '/css'))
    .pipe(browser.reload({ stream: true }));
}

var webpackConfig = {
  mode: (PRODUCTION ? 'production' : 'development'),
  devtool: !PRODUCTION && 'source-map',
  resolve: {
    modules: [
      "node_modules",
      path.resolve(__dirname, "deps/n2o/priv/"),
    ],
  }
}

// Combine JavaScript into one file
// In production, the file is minified
function javascript() {
  var uglify = $.if(PRODUCTION, $.uglify()
    .on('error', function (e) {
      console.log(e);
  }));

  return gulp.src(PATHS.javascript)
    .pipe($.sourcemaps.init())
    .pipe($.concat('app.js'))
    .pipe(uglify)
    .pipe($.if(!PRODUCTION, $.sourcemaps.write()))
    .pipe(gulp.dest(PATHS.dist + '/js')); 
};

// Copy images to the "dist" folder
// In production, the images are compressed
function images() {
  var imagemin = $.if(PRODUCTION, $.imagemin({
    progressive: true
  }));

  return gulp.src('src/assets/img/**/*')
    .pipe(imagemin)
    .pipe(gulp.dest(PATHS.dist + '/img'));
};

// Start a server with BrowserSync to preview the site in
function server(done) {
  browser.init({
    server: PATHS.dist, port: PORT
  }, done);
}

// Start a server with LiveReload to preview the site in
function server(done) {
  browser.init({
    proxy: 'localhost:7001'
  }, done);
};

// Reload the browser with BrowserSync
function reload(done) {
  browser.reload();
  done();
}

// Watch for changes to static assets, pages, Sass, and JavaScript
function watch() {
  gulp.watch(PATHS.assets, copy);
  gulp.watch('src/assets/scss/**/*.scss').on('all', sass);
  gulp.watch('src/assets/js/**/*.js').on('all', gulp.series(javascript, browser.reload));
  gulp.watch('src/assets/img/**/*').on('all', gulp.series(images, browser.reload));
}
