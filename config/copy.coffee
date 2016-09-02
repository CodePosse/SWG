module.exports = (grunt) ->

  # Todo: Fix the www hardcoding
  dist = require('path').join process.cwd(), "dist/#{grunt.option 'app.webfolder'}"
  grunt.file.mkdir dist

  app:
    files: [
      { src: './resource.json', dest: "#{dist}/resource.json" }
      { src: './lib/jquery/dist/jquery.min.js', dest: "#{dist}/jquery.min.js" }
      { src: './lib/angularjs/angular.min.js', dest: "#{dist}/angular.min.js" }
      { src: ['./lib/bootstrap/dist/**/*.min.{js,css}'], dest: dist, expand: true, flatten: true }
      { src: ['**/*.{js,css}'], cwd: './app/src', dest: dist, expand: true }
    ]
  fonts:
    files: [
      { src: ['./lib/bootstrap/dist/fonts/*'], dest: "#{dist}/fonts", expand: true, flatten: true }
    ]
  templates:
    options:
      process: (content, src) ->
        templateVars =
          data:
            urlprefix: grunt.option 'app.urlprefix'
            webprefix: "#{grunt.option 'app.urlprefix'}#{grunt.option 'app.webfolder'}/"

        grunt.template.process content, templateVars
    files: [
      { src: ['./templates/*'], dest: "#{dist}", expand: true, flatten: true }
    ]