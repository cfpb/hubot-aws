'use strict'

module.exports = (grunt) ->

  pkg = grunt.file.readJSON 'package.json'

  grunt.initConfig

    coffeelint:
      options:
        configFile: 'coffeelint.json'
      dist:
        files:
          src: [
            '**/*.coffee'
            '!node_modules/**'
          ]

    jsonlint:
      src: [
        'package.json'
        'coffeelint.json'
      ]

    watch:
      options:
        interrupt: yes
      dist:
        files: [
          '**/*.{coffee,js,json}'
          '!node_modules/**'
        ]
        tasks: [ 'test' ]

    release:
      options:
        tagName: 'v<%= version %>'
        commitMessage: 'Prepare to release <%= version %>.'

  grunt.registerTask 'test',    [ 'jsonlint', 'coffeelint' ]
  grunt.registerTask 'default', [ 'test', 'watch' ]

  require 'coffee-errors'
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks
