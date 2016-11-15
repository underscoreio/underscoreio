#global module:false

path = require 'path'

"use strict"

module.exports = (grunt) ->
  # minify = grunt.option('minify') ? false

  # grunt.loadNpmTasks "grunt-browserify"
  # grunt.loadNpmTasks "grunt-contrib-connect"
  # grunt.loadNpmTasks "grunt-contrib-copy"
  # grunt.loadNpmTasks "grunt-contrib-less"
  # grunt.loadNpmTasks "grunt-contrib-watch"
  # grunt.loadNpmTasks "grunt-exec"
  grunt.loadNpmTasks "grunt-webfont"

  grunt.initConfig
    webfont:
      icons:
        src: "_assets/icons/*.svg"
        dest: "_assets/css/common/icons"
        destScss: "_assets/css/common/icons"
        options:
          font: 'uio'
          engine: 'node'
          htmlDemo: false
          relativeFontPath: './'
          stylesheets: ['scss']
          syntax: 'bootstrap'
          fontFilename: 'uio'
          rename: (filename) -> 'uio-' + path.basename(filename)

    # exec:
    #   jekyllLocal:
    #     cmd: "jekyll build --trace"
    #   jekyllLive:
    #     cmd: "jekyll build --trace"
    #   deploy:
    #     cmd: 's3_website push'
    #   deployssh:
    #     cmd: 'rsync --progress -a --delete --exclude files -e "ssh -q" dist/ admin@underscore.io:underscore.io/public/htdocs/'

    # connect:
    #   server:
    #     options:
    #       port: 4000
    #       base: 'dist'
