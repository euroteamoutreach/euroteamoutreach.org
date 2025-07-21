// gulpfile.js - https://jsua.co/mm-gulp

'use strict'; // http://www.w3schools.com/js/js_strict.asp

// 1. LOAD PLUGINS

var gulp = require('gulp');
var sass = require('sass');
var gulpSass = require('gulp-sass')(sass);
var bourbon = require('bourbon').includePaths;
var neat = require('bourbon-neat').includePaths;
var p = require('gulp-load-plugins')({ // This loads all the other plugins.
  DEBUG: false,
  pattern: ['gulp-*', 'gulp.*', 'del', 'run-*', 'browser*', 'vinyl-*'],
  rename: {
    'vinyl-source-stream': 'source',
    'vinyl-buffer': 'buffer',
    'gulp-util': 'gutil'
  },
});

// 2. CONFIGURATION

var
  src  = 'source/', // The Middleman source folder
  dest = '.tmp/',   // The "hot" build folder used by Middleman's external pipeline
  // For development, output assets directly to source to avoid path issues
  devCssDest = process.env.NODE_ENV === 'development' ? 'source/assets/stylesheets/' : '.tmp/assets/stylesheets/',
  devJsDest = process.env.NODE_ENV === 'development' ? 'source/assets/javascripts/' : '.tmp/assets/javascripts/',
  devImagesDest = process.env.NODE_ENV === 'development' ? 'source/assets/images/' : '.tmp/assets/images/',

  development = p.environments.development,
  production = p.environments.production,

  css = {
    in: src + 'assets/stylesheets/**/*.{css,scss,sass}',
    out: dest + 'assets/stylesheets/',
  },

  sassOpts = {
    imagePath: '../assets/images',
    includePaths: [
      bourbon, 
      neat, 
      'node_modules/bourbon/app/assets/stylesheets',
      'node_modules/bourbon-neat/app/assets/stylesheets'
    ],
    errLogToConsole: true
  },

  js = {
    in: src + 'assets/javascripts/*.{js,coffee}',
    out: dest + 'assets/javascripts/'
  },

  images = {
    in: src + 'assets/images/*',
    out: dest + 'assets/images/'
  },

  serverOpts = {
    proxy: 'localhost:4567',
    open: true,
    reloadDelay: 700,
    files: [dest + '**/*.{js,css}', src + '**/*.{html,haml,markdown}']
  };

// 3. WORKER TASKS

// CSS Preprocessing
gulp.task('css', function() {
  return gulp.src(css.in)
    .pipe(development(p.sourcemaps.init()))
    .pipe(gulpSass(sassOpts).on('error', gulpSass.logError))
    .pipe(p.autoprefixer()).on('error', handleError)
    .pipe(production(p.cleanCss()))
    .pipe(development(p.sourcemaps.write('.')))
    .pipe(gulp.dest(devCssDest || css.out));
});

// Javascript Bundling
gulp.task('js', function() {
  var b = p.browserify({
    entries: src + 'assets/javascripts/all.js',
    debug: true
  });

  return b.bundle().on('error', handleError)
    .pipe(p.source('bundle.js'))
    .pipe(production() ? p.buffer() : p.gutil.noop())
    .pipe(production(p.stripDebug()))
    .pipe(production(p.sourcemaps.init()))
    .pipe(production(p.terser()))
    .pipe(production(p.sourcemaps.write()))
    .pipe(gulp.dest(devJsDest || js.out));
});

// Image Optimization (temporarily simplified for compatibility)
gulp.task('images', function() {
  return gulp.src(images.in)
    .pipe(p.changed(images.out))
    .pipe(gulp.dest(devImagesDest || images.out));
});

// Clean .tmp/
gulp.task('clean', function(done) {
  p.del([
    dest + '*'
  ]), done();
});

// Asset Size Report
gulp.task('sizereport', function () {
  return gulp.src(dest + '**/*')
    .pipe(p.sizereport({
      gzip: true
    }));
});

// 4. SUPER TASKS

// Development Task
gulp.task('development', gulp.series('clean', 'css', 'js', 'images'));

// Production Task
gulp.task('production', gulp.series
  ('clean', 'css', 'js', 'images', 'sizereport')
);

// Default Task
// This is the task that will be invoked by Middleman's exteranal pipeline when
// running 'middleman server'
gulp.task('default', gulp.series('development', function watch () {
  // In development, we don't use BrowserSync since Middleman has live reload
  // Just watch files and rebuild assets
  gulp.watch(css.in, gulp.series('css'));
  gulp.watch(js.in, gulp.series('js'));
  gulp.watch(images.in, gulp.series('images'));
}));

function handleError(err) {
  console.log(err.toString());
  this.emit('end');
}
