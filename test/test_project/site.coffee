############ Command line manager for the project
path = require("path")

swig  = require("swig")
express = require('express')
apto = require("../apto") # TODO this needs to be an actual module


# swig config, sets template directory and caching
swig.init({
  cache: false,
  root: "."
})

# apto site
site = apto.Site.create({
  build_path: "build",
  static_path: "static",
  
  routes: {
    "(.*)+/?": "page"
  }
  
  page: (file, name) ->
    pages = apto.util.listfilesSync("page", { recur: true })
    file.write(
      swig.compileFile(path.join("page/", name)).render({ pages: pages}))
      
  buildall: () ->
    pages = apto.util.listfilesSync("page", { recur: true })
    site.build(pages)
    site.build_static()
    
})


# command line interface
main = () ->
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
      
        Commands:
      
          serve  <port>   Start an development server, auto reloads changes for you.
          build           Build site.
      
      
      """)


main()
  
