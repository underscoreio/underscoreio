#global module:false

path = require 'path'

"use strict"

module.exports = (grunt) ->
  minify = grunt.option('minify') ? false

  grunt.loadNpmTasks "grunt-browserify"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-exec"
  grunt.loadNpmTasks "grunt-webfont"

  grunt.initConfig
    less:
      screen:
        options:
          paths: [
            "node_modules"
            "src/css"
          ]
          compress: minify
          yuicompress: minify
        files:
          "underscoreio/css/screen.css" : "src/css/screen.less"
          "underscoreio/css/print.css"  : "src/css/print.less"
          "underscoreio/css/ie8.css"    : "src/css/ie8.less"
          "underscoreio/css/ie9.css"    : "src/css/ie9.less"
          "underscoreio/css/ie10.css"   : "src/css/ie10.less"

    browserify:
      site:
        files:
          "underscoreio/js/site.js" : "src/js/site.coffee"
          "underscoreio/js/ie8.js"  : "src/js/ie8.coffee"
        options:
          watch: false
          transform: if minify
            [ 'coffeeify', [ 'uglifyify', { global: true } ] ]
          else
            [ 'coffeeify' ]
          browserifyOptions:
            debug: false
            extensions: [ '.coffee' ]

    webfont:
      icons:
        src: "src/icons/*.svg"
        dest: "underscoreio/fonts"
        destCss: "src/css/common/icons"
        options:
          font: 'uio'
          engine: 'node'
          htmlDemo: false
          relativeFontPath: '/fonts/'
          syntax: 'bootstrap'
          rename: (filename) -> 'uio-' + path.basename(filename)

    copy:
      images:
        files: [{
          expand: true
          cwd: "src/images"
          src: ["**"]
          dest: "underscoreio/images/"
        }]
      php:
        files: [{
          expand: true
          cwd: "src/php"
          src: ["**"]
          dest: "underscoreio/"
        }]

    exec:
      composer:
        cmd: "php composer.phar install"
        cwd: "src/php"
      install:
        cmd: "bundle install"
      jekyllLocal:
        cmd: "bundle exec jekyll build --drafts --trace --config jekyll_config.yml"
      jekyllLive:
        cmd: "bundle exec jekyll build --trace --config jekyll_config.yml"
      deploy:
        cmd: 'rsync --progress -a --delete --exclude files -e "ssh -q" underscoreio/ admin@underscore.io:underscore.io/public/htdocs/'

    watchImpl:
      options:
        livereload: true
      css:
        files: [
          "src/icons/**/*"
          "src/css/**/*"
        ]
        tasks: [
          "webfont"
          "less"
          "exec:jekyllLocal"
        ]
      js:
        files: [
          "src/js/**/*"
        ]
        tasks: [
          "browserify"
          "exec:jekyllLocal"
        ]
      images:
        files: [
          "src/images/**/*"
        ]
        tasks: [
          "copy:images"
          "exec:jekyllLocal"
        ]
      html:
        files: [
          "src/html/**/*"
          "jekyll_plugins/**/*"
          "jekyll_config.yml"
        ]
        tasks: [
          "copy:images"
          "exec:jekyllLocal"
        ]

    connect:
      server:
        options:
          port: 4000
          base: 'underscoreio'

  grunt.renameTask "watch", "watchImpl"

  grunt.registerTask "build:base", [
    "webfont"
    "less"
    "browserify"
    "exec:composer"
    "copy"
  ]

  grunt.registerTask "build", [
    "build:base"
    "exec:jekyllLocal"
  ]

  grunt.registerTask "serve", [
    "build"
    "connect:server"
    "watchImpl"
  ]

  grunt.registerTask "deploy", [
    "build:base"
    "exec:jekyllLive"
    "exec:deploy"
  ]

  grunt.registerTask "watch", [
    "serve"
  ]

  grunt.registerTask "default", [
    "build"
  ]
