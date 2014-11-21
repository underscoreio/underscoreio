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
            "bower_components"
            "src/css"
          ]
          compress: minify
          yuicompress: minify
        files:
          "underscoreio/css/screen.css" : "src/css/screen.less"
          "underscoreio/css/print.css"  : "src/css/print.less"

    browserify:
      site:
        src:  "src/js/site.coffee"
        dest: "underscoreio/js/site.js"
        cwd:  "."
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
      bootstrap:
        files: [
          {
            expand: true
            cwd: "bower_components/bootstrap/img/"
            src: ["**"]
            dest: "underscoreio/images/"
          }
          {
            expand: true
            cwd: "bower_components/bootstrap/fonts/"
            src: ["**"]
            dest: "underscoreio/fonts/"
          }
        ]
      fontAwesome:
        files: [
          {
            expand: true
            cwd: "bower_components/font-awesome/fonts/"
            src: ["**"]
            dest: "underscoreio/fonts/"
          }
          {
            expand: true
            cwd: "bower_components/bootstrap/fonts/"
            src: ["**"]
            dest: "underscoreio/fonts/"
          }
        ]
      images:
        files: [{
          expand: true
          cwd: "src/images"
          src: ["**"]
          dest: "underscoreio/images/"
        }]

    exec:
      install:
        cmd: "bundle install"
      jekyll:
        cmd: "bundle exec jekyll build --trace --config jekyll_config.yml"
      deploy:
        cmd: 'rsync --progress -a --delete -e "ssh -q" underscoreio/ admin@preview.underscore.io:preview.underscore.io/public/htdocs/'

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
          "exec:jekyll"
        ]
      js:
        files: [
          "src/js/**/*"
        ]
        tasks: [
          "browserify"
          "exec:jekyll"
        ]
      images:
        files: [
          "src/images/**/*"
        ]
        tasks: [
          "copy"
          "exec:jekyll"
        ]
      html:
        files: [
          "src/html/**/*"
          "jekyll_plugins/**/*"
          "jekyll_config.yml"
        ]
        tasks: [
          "copy"
          "exec:jekyll"
        ]

    connect:
      server:
        options:
          port: 4000
          base: 'underscoreio'

  grunt.renameTask "watch", "watchImpl"

  grunt.registerTask "build", [
    "webfont"
    "less"
    "browserify"
    "copy"
    "exec:jekyll"
  ]

  grunt.registerTask "serve", [
    "build"
    "connect:server"
    "watchImpl"
  ]

  grunt.registerTask "deploy", [
    "build"
    "exec:deploy"
  ]

  grunt.registerTask "watch", [
    "serve"
  ]

  grunt.registerTask "default", [
    "build"
  ]
