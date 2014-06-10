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
            "bower_components/bootstrap/js/scrollspy.js"
            "bower_components/bootstrap/js/button.js"
            "bower_components/bootstrap/js/affix.js"
            "bower_components/masonry/dist/masonry.pkgd.js"
            "bower_components/respond/respond.src.js"
            "src/js/site.js"
          ]

    copy:
      bootstrap:
        files: [{
          expand: true
          cwd: "bower_components/bootstrap/img/"
          src: ["**"]
          dest: "underscoreio/images/"
        }]
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
        cmd: 'echo "Deployment not implemented. Search for this text in gruntfile.coffee and replace it with your own deployment command."'

    bower:
      install: {}

    watch:
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
      html:
        files: [
          "src/**/*"
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

  grunt.registerTask "build", [
    "less"
    "uglify"
    "copy"
    "exec:jekyll"
  ]

  grunt.registerTask "serve", [
    "build"
    "connect:server"
    "watch"
  ]

  grunt.registerTask "deploy", [
    "build"
    "exec:deploy"
  ]

  grunt.registerTask "default", [
    "serve"
  ]
