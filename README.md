
# SWG Homepage Redesign

This documentation's premise is to document the workings of the development process of the project, the build process for the project & patterns used throughout the project for future development by SWG.

# Deliverables

  * [SWG Homepage Redesign - Home (fully responsive)](http://plinteractive.github.io/swg_wcm_project/)
  * [SWG Homepage Redesign - Home & Business Safety](http://plinteractive.github.io/swg_wcm_project/#/safety)
  * [SWG Homepage Redesign - Residential Services](http://plinteractive.github.io/swg_wcm_project/#/residential)
  * [SWG Homepage Redesign - Contact](http://plinteractive.github.io/swg_wcm_project/#/contact)
  * [SWG Homepage Redesign - History](http://plinteractive.github.io/swg_wcm_project/#/history)
  * [SWG Homepage Redesign - Heating](http://plinteractive.github.io/swg_wcm_project/#/heating)
  * [SWG Homepage Redesign - Contractor Referrals](http://plinteractive.github.io/swg_wcm_project/#/contractor-referrals)
  * [SWG Homepage Redesign - Contractor Referrals Results](http://plinteractive.github.io/swg_wcm_project/#/contractor-referrals-results)
  * [SWG Homepage Redesign - Rebates and Promotions - All/Filter](http://plinteractive.github.io/swg_wcm_project/#/rebates-and-promotions)
  * [SWG Homepage Redesign - Rebates and Promotions - Details](http://plinteractive.github.io/swg_wcm_project/#/rebates-and-promotions-detail)
  * [SWG Homepage Redesign - Natural Gas Products](http://plinteractive.github.io/swg_wcm_project/#/natural-gas-products)
  * [SWG Homepage Redesign - Template](http://plinteractive.github.io/swg_wcm_project/#/template)

# Development

Development is done via [node.js](http://nodejs.org) powering a static server for rendering routed pages; along with tasks such as compiling `.less` files into `.css` and building `.js` files from many others. This is needed for working on additional assets/pages. The process is doumented below.

## Setup 

**Install Node.js**

  * [node.js](http://nodejs.org)

### Install local dependencies via Terminal commands

```bash
npm install -g gulp
npm install -g bower
bower install
npm install
```

## Working

Open a Terminal window and type:

```bash
gulp
```

Your project (the files located in `static`) will now be available at [http://localhost:8000/](http://localhost:8000/) served as if from a static web server.

# Production

Production files are created via another gulp task. Quit the `gulp` task, and in your terminal type:

```bash
gulp production
```

#### Production Viewing

```bash
gulp server:production
```

This will clean and populate a directory called `./dist/` which will have all minified assets and files. This is your production release.

# Design Patterns

**Static Popovers Angular.js Directive:**

```html
<div static-popover='News &amp; Events'></div>
```

_**Creates:**_

```html
<div class="static-popover-style-bg ng-isolate-scope" static-popover="Save Energy &amp; Money">
  <div class="static-popover-style-bg-top">
    <h2 ng-bind="title" class="ng-binding">Save Energy &amp; Money</h2>
  </div>
  <div class="static-popover-style-bg-bottom">
    <i class="glyphicon glyphicon-play"></i>
  </div>
</div>
```

_**Rendered:**_

![Static Popover](https://s3.amazonaws.com/f.cl.ly/items/2S151W471q393N3o080r/Screen%20Shot%202015-01-20%20at%205.08.07%20PM.png)

# Publishing to Sites

This publish task takes the files in the distribution directory and populate a Sites install with assets that mirrors the files in that folder.

Assets created have predictable identifiers and they start at 900000000000 for the parent asset. So for a given file under the dist folder, it will always be mapped to the same asset id in whichever Sites install it is run against.

The gulp task is the **pubilsh** task.

To run the build and populate your JSK, run

    NODE_ENV=jsk gulp publish

This assumes that your JSK is available at localhost:9080, and the user fwadmin is available with the default password. 

The JSK is the default option, so you do not need to specify that explicitly. For other environments (e.g. dev), use the NODE_ENV environment variable.

To remove all previously published assets, run

    gulp publish:clean

## Configuration File

You can include a sitesconfig.json in your home directory or in the project directory (do not check this in) to override certain default values for this project; the latter file takes priority if both are present. 

An example of sitesconfig.json:


    {
      "jsk": {
        "host": "myserver:9080",
        "username": "john.doe",
        "password": "password"
      }
    }

There are 3 options that you can override. You may omit any of the options in your sitesconfig.json file, the missing options will be read from the defaults. 

Flag | Description 
-- | :--
host | Hostname and port of the Sites install, Default: localhost:9080
username | Login user name. Default: fwadmin
password | Password for the login user. Default: xceladmin

## Command Line Arguments

There are 2 options that you can specify. Similar to command line options for Linux, use the double dash for long options and the single dash for short ones.

Flag | Legal Values | Description 
-- | -- | :--
mode | sync, dry-run | Default is sync. Specify dry-run to build but not publish to Sites.
f | | Name of the file relative to the dist directory. Specify multiple 'f' options for multiple files.

For example, to simulate publishing the index.html and build js files, run

    gulp publish --mode=dry-run -f=index.html -f=js/build.min.js

## Debugging

Set the log level in the environment variable LOG_LEVEL as your run the pubilsh to get more details into the build process. For example,

    LOG_LEVEL=debug gulp publish
    
## Support

For any questions on publishing to Sites, please email Matthew Soh at <matthew.soh@swgas.com>. 

sh to get more details into the build process. For example,

    LOG_LEVEL=debug gulp publish
    
## Support

For any questions on publishing to Sites, please email Matthew Soh at <matthew.soh@swgas.com>. 

