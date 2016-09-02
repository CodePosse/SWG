module.exports = (grunt) ->

  Q = require 'q'
  requestQ = Q.denodeify require('request')

  INFO = grunt.log.writeln
  DEBUG = grunt.log.debug
  ERROR = grunt.log.error
  HEADER = grunt.log.subhead

  options = {}

  START_ID = 900000000000

  webroot =
    _id: START_ID
    name: 'Webroot'
    type: 'swgGroup'
    description: 'Root folder for all web resources'
    subtype: 'Folder'

  requestHeader =
    Accept: 'application/json'
    'X-CSRF-Token': ''

  ticket = null

  genId = (str) ->
    return 0 if not str?

    id = START_ID
    for ch, i in str
      num = ch.charCodeAt()
      num *= (i+1)
      id += num
    id

  login = ->
    HEADER "Logging in to #{options.host}"
    requestOpts =
      uri: "http://#{options.host}/cas/v1/tickets"
      form: { username: options.username, password: options.password }
      method: 'POST'

    requestQ(requestOpts).then (resp) ->
      throw new Error "Cannot login, server error: #{resp[0].statusCode}" if resp[0].statusCode not in [200, 201]

      location = resp[0]?.headers?.location
      requestQ(method: 'POST', uri: location, form: { service: '*' })
        .then (resp) ->
          ticket = resp[1]
          DEBUG "Got multi-ticket #{ticket}"
          requestHeader['X-CSRF-Token'] = resp[1]

  findAsset = (type, term, field) ->
    field = 'name' if not field?

    requestOpts =
      uri: "http://#{options.host}/cs/REST/sites/#{options.site}/types/#{type}/search"
      qs: { multiticket: ticket }
      headers: requestHeader

    requestOpts.qs["field:#{field}:equals"] = term

    DEBUG "Searching for type: #{type}, #{field}: #{term}"

    requestQ(requestOpts).then (resp) ->
      throw new Error resp[0] if resp[0]?.statusCode isnt 200

      # The data for search is not a JSON object. This is different to an asset post.
      json = JSON.parse(resp[1])
      return 0 if json.count is 0

      # Return the first
      assetid = json?.assetinfo?[0].id?.split(":")[1]

      DEBUG "Found asset #{assetid}"
      return assetid

  makeFileAsset = (file) ->
    asset =
      name: file.filename
      description: "#{file.path}/#{file.filename}"
      publist: [options.site]
      subtype: 'WebFile'
      type: 'swgFile'
      parent:[
          parentDefName: webroot.subtype
          asset: ["#{webroot.type}:#{webroot._id}"]
        ]
      attribute: [{
          name: 'File'
          data:
            blobValue:
              filedata: grunt.file.read(file.abspath, { encoding: 'base64' })
              filename: file.filename
        },{
          name: 'filename'
          data: { stringValue: file.filename }
        },{
          name: 'path'
          data: { stringValue: file.path }
        }]

  createAsset = (asset) ->
    requestOpts =
      uri: "http://#{options.host}/cs/REST/sites/#{options.site}/types/#{asset.type}/assets"
      qs: { multiticket: ticket }
      headers: requestHeader
      body: asset
      json: true
      method: 'POST'

    requestOpts.uri = "#{requestOpts.uri}/#{asset._id}" if asset._id?

    # Don't use the asset.id, it will give you a 500 error because Sites will reject the data
    requestQ(requestOpts).then (resp) ->
      # Create = 200, Update = 201
      if resp[0].statusCode in [200, 201]
        assetid = resp[1]?.id?.split(":")[1]
        DEBUG "Asset created/updated with id #{assetid}"
        assetid
      else
        throw new Error resp[1]

  deleteAsset = (type, id) ->
    requestOpts =
      uri: "http://#{options.host}/cs/REST/sites/#{options.site}/types/#{type}/assets/#{id}"
      qs: { multiticket: ticket }
      headers: requestHeader
      method: "DELETE"

   # Don't use the asset.id, it will give you a 500 error because Sites will reject the data
    requestQ(requestOpts).then (resp) ->
      # Create = 200, Update = 201
      if resp[0].statusCode in [200, 201]
        DEBUG "Deleting asset #{type}:#{id}"
        true
      else
        throw new Error resp[1]

  publish = ->
    HEADER "Publishing files to Sites, mode: #{options.mode}."
    DEBUG "Mode is not sync, will not update asset if it already exists." if options.mode isnt 'sync'

    files = []
    grunt.file.setBase "dist"
    grunt.file.recurse "#{grunt.option 'app.webfolder'}", (abspath, rootdir, subdir, filename) ->
      # Files will always be in subdir under the dist directory
      path = if subdir? then "#{rootdir}/#{subdir}" else rootdir
      files.push { abspath: "dist/#{abspath}", path: path, filename: filename }

    grunt.file.setBase ".."

    promise = findAsset(webroot.type, webroot.name).then (assetid) ->
      if assetid isnt 0
        webroot._id = assetid
      else
        createAsset webroot

    files.forEach (f) ->
      promise = promise.then(->
        asset = makeFileAsset(f)
        findAsset(asset.type, asset.description, 'description').then (assetid) ->
          if assetid isnt 0
            asset._id = assetid
            if options.mode is 'sync' then createAsset(asset) else assetid
          else
            asset._id = genId(f.abspath)
            createAsset asset
      )
    promise

  clean = ->
    HEADER "Deleting all web assets from Sites"

    # Sort by id desc to make the Webroot parent go last. You cannot delete the parent until all the children are deleted
    requestOpts =
      uri: "http://#{options.host}/cs/REST/sites/#{options.site}/search"
      qs: {multiticket: ticket, 'field:id:startswith': '9', 'sortfield:id:des'}
      headers: requestHeader
      method: 'GET'

    requestQ(requestOpts).then (resp) ->
      if resp[0].statusCode isnt 200
        ERROR 'Unable to get to Sites'
        throw new Error resp[1]
      else
        # The data for search is not a JSON object. This is different to an asset post.
        json = JSON.parse(resp[1])

        DEBUG (if json.count is 0 then "No assets found to delete" else "Found #{json.count} assets to delete")

        return 0 if json.count is 0

        p = Q()
        json.assetinfo.forEach(
          (asset) ->
            [type, id] = asset.id.split(':')
            p = p.then(-> deleteAsset(type, id))
        )
        p

  grunt.registerMultiTask 'publish', 'Publishes changes to Sites', ->
    taskDone = @async()

    options = @.options()

    overrides = ['host', 'username', 'password', 'mode']
    overrides.forEach (opt) ->
      envKey = "SITES_#{opt.toUpperCase()}"
      if grunt.option(opt)?
        options[opt] = grunt.option(opt)
        DEBUG "Override for #{opt} specified on command: #{options[opt]}"
      else if process.env[envKey]?
        options[opt] = process.env[envKey]
        DEBUG "Override for #{opt} found in the environment: #{envKey}=#{options[opt]}"
 
    webroot.publist = [options.site]

    return taskDone() if options.mode is 'dry-run'

    login()
      .then(if options.mode is 'clean' then clean else publish)
      .fail((err) -> ERROR err)
      .done(-> taskDone())
