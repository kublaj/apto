############ Command line manager for the project
path = require("path")

swig  = require("swig")
express = require('express')
apto = require("apto")


swig.init({
  cache: false,
  root: "."
})

# apto Site
site = apto.Site.create({
  build_path: "build",
  static_path: "static",
  
  constructor: () ->
    this.route(":page", this.page)
    
  page: (file, page) ->
    pages = apto.util.listfilesSync("page", { recur: true })
    file.write(
      swig.compileFile(path.join("page/", page)).render({ pages: pages}))
      
  buildall: () ->
    pages = apto.util.listfilesSync("page", { recur: true })
    site.build(pages)
    site.build_static()
    
})


# command line interface
module.exports.main = () ->
  command = process.argv[2]
  option1 = process.argv[3]
  
  switch command
    when "build"
      site.buildall()
    # build site, watch files for changes, serve build dir
    when "serve"
      port = option1 or 8000
      console.log("development server started at localhost: " + port)
      site.buildall()
      apto.util.watch(["page", "static", "layout"], (filename) ->
        site.buildall())
      express().use(express.static(site.build_path)).listen(port)
    else
      console.log("""
      
        Usage: site [serve|build]
      
          serve  <port>   Start an development server, auto reloads changes for you.
          build           Build site.
      
      
      """)
  
