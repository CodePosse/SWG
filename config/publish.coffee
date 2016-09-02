module.exports = (grunt) ->
  options:
    site: 'SouthwestGas'
    assettype: 'swgFile'
    parenttype: 'swgGroup'
    mode: 'sync'
  dev:
    options:
      host: 'wcsdev.swgas.com'
      username: 'fwadmin'
      password: 'Passw0rd'
  jsk:
    options:
      host: 'localhost:9080'
      username: 'fwadmin'
      password: 'xceladmin'
