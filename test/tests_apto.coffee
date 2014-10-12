fs = require("fs")
util = require("util")
path = require("path")
assert = require("assert")

println = console.log
# typechecking
`var type = {}; type["isArray"] = Array.prototype.isArray || function(obj) { return Object.prototype.toString.call(obj) == '[object Array]'; }; type["isObject"] = function(obj) { return obj === Object(obj); }; ['Arguments', 'Function', 'String', 'Number', 'Date', 'RegExp'].map(function(name) { type["is" + name] = function(obj) { return toString.call(obj) == '[object ' + name + ']'; }; });`

apto = require("../lib/apto")
Site = apto.Site
FileResponse = apto.FileResponse
validate_site = apto.validate_site
route = apto.route
build_static = apto.build_static
build = apto.build
write_file = apto.write_file
call_route_fn = apto.call_route_fn
find_route = apto.find_route
extract_parameters = apto.extract_parameters
route_to_RegExp = apto.route_to_RegExp
test = (desc, fn) -> fn()

wrench = require("wrench")

########## test sites
site = Site.create({
  build_path: path.join(process.cwd(), "/test/test_project/build"),
  
  handler: (file) -> return
  
  constructor: () ->
    this.route(/\/(.*)+\/(.*)+\/?/, this.handler)
    
})

site_with_static = Site.create({
  build_path: path.join(process.cwd(), "/test/test_project/build"),
  static_path: path.join(process.cwd(), "/test/test_project/static")
    
  handler: (file) -> return
  
  constructor: () ->
    this.route(/\/(.*)+\/(.*)+\/?/, this.handler)
})

site_with_static_relative = Site.create({
  build_path: "../test/test_project/build",
  static_path: "../test/test_project/static"

  constructor: () ->
    this.route(/\/(.*)+\/(.*)+\/?/, this.handler)
    
  handler: (file) -> return
})

handler = () -> return
  
site_with_fn = Site.create({
  build_path: path.join(process.cwd(), "/test/test_project/build"),
  static_path: path.join(process.cwd(), "/test/test_project/static")
  
  constructor: () ->
    this.route(/\/(.*)+\/(.*)+\/?/, handler)
    
})

test("create", () ->
  # should throw
  assert.throws(
    () ->
      Site.create({})
    , Error))


########## validation tests

test("validate_site", () ->
  
  ########## these should throw
  assert.throws(
    () ->
      validate_site({})
    , Error)
  
  ######### these should validate
  validate_site({
    build_path: path.join(process.cwd(), "/test/test_project/build"),
    
    handler: (file) ->
      file.write("hello world")
      
    constructor: () ->
      this.route(/\/(.*)+\/(.*)+\/?/, this.handler)
  })
  
  validate_site({
    build_path: path.join(process.cwd(), "/test/test_project/build"),
    static_path: path.join(process.cwd(), "/test/test_project/static"),
    
    handler: (file) ->
      file.write("hello world")
      
    constructor: () ->
      this.route(/\/(.*)+\/(.*)+\/?/, this.handler)
  }))


######### route tests

test("extract parameters", () ->
  assert.ok(
    extract_parameters(/\/(.*)+\/(.*)+\/?/, "/page/1")) == ["page", "1"])
  
# TODO more tests
test("route_to_RegExp", () ->
  assert.ok(route_to_RegExp("/page/1").toString()  == "/^/page/1$/")
  assert.ok(route_to_RegExp("/:page/:id").toString() == "/^/([^/]+)/([^/]+)$/"))
    
test("route function", () ->
  # test route
  _route = /\/(.*)+\/(.*)+\/?/
  route.call(site, "/test", site.handler)
  _site = route.call(site, _route, site.handler)
  assert.ok(_site.routes[2].route == _route))
  
test("find route", () ->
  assert.ok(find_route(site, "/page/1") == site.routes[0]))

test("call_route_fn", () ->
  call_route_fn(site, "/page/1"))

test("route not matching any routes", () ->  
  _site = Site.create({
    build_path: "build",
    handler: (file) -> return
    constructor: () ->
      this.route(/\/(.*)+\/(.*)+\/?/, this.handler)
      
  })
  
  assert.throws(
    () ->
      call_route_fn(_site, "/index.html")
    , Error))
    
test("passing params to route functions", () ->  
  _site = Site.create({
    build_path: "build",
    
    handler: (file, page, id) ->
      assert.ok(page == "page")
      assert.ok(id == "1")
      
    constructor: () ->
      this.route(/\/(.*)+\/(.*)+\/?/, this.handler)
  })
  
  call_route_fn(_site, "/page/1"))
  
test("test routing", () ->
  site = Site.create({
    build_path: path.join(process.cwd(), "/test/test_project/build"),
    
    home_handler: (file, param) ->
      assert.ok(param == undefined)
      
    page_handler: (file, article, id) ->
      assert.ok(article != "index.html")
      return
      
    main_handler: (file, page) ->
      assert.ok(page == "index")
      assert.ok(page != "page")
      return
      
    constructor: () ->
      this.route("/home", this.home_handler)
      this.route(/\/(.*)+.html/, this.main_handler)
      this.route(/\/(.*)+\/(.*)+\/?/, this.page_handler)
  })
  
  site.build("/index.html")
  site.build("/page/1")
  site.build("/home"))

test("test pretty string routing", () ->
  site = Site.create({
    build_path: path.join(process.cwd(), "/test/test_project/build"),
    
    home_handler: (file, param) ->
      assert.ok(param == undefined)
      
    page_handler: (file, article, id) ->
      assert.ok(article != "index.html")
      return
      
    main_handler: (file, page) ->
      assert.ok(page == "index")
      assert.ok(page != "page")
      return
      
    constructor: () ->
      this.route("/home", this.home_handler)
      this.route("/:page.html", this.main_handler)
      this.route("/:article/:id", this.page_handler)
  })
  
  site.build("/index.html")
  site.build("/page/1")
  site.build("/home"))

  
######### build tests

test("write file", () ->
  filename = path.join(site.build_path, "/page/1")
  file_content = "page data"
  write_file(filename, file_content)
  
  # test correct content
  assert.ok(
    fs.readFileSync(filename).toString() \
      == file_content))

test("FileResponse Type", () ->
  file = FileResponse.create(site, "/page/test.html")
  
  assert.ok(type.isObject(file))
  assert.ok(type.isString(file.path))
  assert.ok(type.isFunction(file.write)))
  
test("FileResponse end function", () ->
  content = "page data"
  _site = Site.create({
    build_path: path.join(process.cwd(), "/test/test_project/build"),
    
    handler: (file, page, id) ->
      file.write(content)
      
    constructor: () ->
      this.route(/\/(.*)+\/(.*)+\/?/, this.handler)
  })
  
  call_route_fn(_site, "/page/1.html")
  
  # test correct content
  assert.ok(
    fs.readFileSync(
      path.join(_site.build_path, "/page/1.html")).toString() \
      == content))
  
test("build", () ->
  assert.throws(
    () ->
      build.call(site, null)
    , Error)
    
  # test String param  
  build.call(site, "/page/1")
  
  # test Array param
  build.call(site, ["/page/1", "/page/2"])
  
  # test function outside of object site
  build.call(site_with_fn, "/page/1"))
  
test("build_static", () ->    
  # file should not exist
  assert.throws(
    () ->
      fs.statSync(site.build_path + "/static")
    ,Error)
    
  # doesn't have static prop
  build_static.call(site)
  
  # full call
  build_static.call(site_with_static)
  
  # relative call
  build_static.call(site_with_static)
  
  # static dir should be there
  fs.statSync(site.build_path + "/static"))

test("chaining", () ->
  site
    .build("/page/1")
    .build("/page/1")
    .build_static())
     
# clean up
wrench.rmdirSyncRecursive(site.build_path)