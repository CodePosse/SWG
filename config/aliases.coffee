module.exports = (grunt) ->

  # The url prefix for paths after the hostname.
  grunt.option 'app.urlprefix', '/'

  # The path after the url prefix for all web resources. This is typically the folder inside the dist directory.
  grunt.option 'app.webfolder', 'www'

  dev: ->
    grunt.task.run ['coffeelint', 'clean', 'copy', 'publish:dev']

  jsk: ->
    grunt.option 'app.urlprefix', '/cs/swg/'

    grunt.task.run ['coffeelint', 'clean', 'copy', 'publish:jsk']
