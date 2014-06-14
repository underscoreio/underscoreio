#global module:false

"use strict"

module.exports = (grunt) ->
  grunt.loadNpmTasks "grunt-bower-task"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-exec"

  grunt.initConfig
    less:
      screen:
        options:
          paths: [
            "bower_components/bootstrap/less"
            "src/css"
          ]
          yuicompress: true
        files:
          "underscoreio/css/screen.css" : "src/css/screen.less"
          "underscoreio/css/print.css"  : "src/css/print.less"

    uglify:
      site:
        files:
          "underscoreio/js/site.js" : [
            "bower_components/jquery/dist/jquery.js"
            "bower_components/underscore/underscore.js"
            "bower_components/bootstrap/js/collapse.js"
            "bower_components/respond/respond.src.js"
            "src/js/site.js"
          ]

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
        cmd: 'rsync --progress -a --delete -e "ssh -q" underscoreio/ admin@underscore.io:beta.underscore.io/public/htdocs/'

    bower:
      install: {}

    watchImpl:
      options:
        livereload: true
      css:
        files: [
          "src/css/**/*"
        ]
        tasks: [
          "less"
          "exec:jekyll"
        ]
      js:
        files: [
          "src/js/**/*"
        ]
        tasks: [
          "uglify"
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
    "less"
    "uglify"
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
