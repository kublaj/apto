fs = require("fs")
util = require("util")
path = require("path")

println = console.log
map = Array.prototype.map
filter = Array.prototype.filter
indexOf = Array.prototype.indexOf
concat = Array.prototype.concat
slice = Array.prototype.slice;   
toString = Object.prototype.toString
push = Array.prototype.push
# typechecking
`var type = {}; type["isArray"] = Array.prototype.isArray || function(obj) { return Object.prototype.toString.call(obj) == '[object Array]'; }; type["isObject"] = function(obj) { return obj === Object(obj); }; ['Arguments', 'Function', 'String', 'Number', 'Date', 'RegExp'].map(function(name) { type["is" + name] = function(obj) { return toString.call(obj) == '[object ' + name + ']'; }; });`

wrench = require("wrench")


########### Validating

# validates site object, if fails throws error
validate_site = (obj) ->
  if not type.isObject(obj) \
     or not obj.build_path
    throw new Error("Object site did not validate.")


########### Routing

# Returns array of params exctracted by regex from the route string based on the path
extract_parameters = (route, inroute) ->
  if not type.isRegExp(route) then throw new Error("String route required")
  if not type.isString(inroute) then throw new Error("String inroute required")
  
  slice.call(route.exec(inroute), 1)
    
# taken from backbone.js for pretty string routing. backbonejs.org/
# Returns a regular expression object given a string or /:page/:id type string route
optionalParam = /\((.*?)\)/g;
namedParam    = /(\(\?)?:\w+/g;
splatParam    = /\*\w+/g;
escapeRegExp  = /[\-{}\[\]+?.,\\\^$|#\s]/g;
route_to_RegExp = (route) ->
  route = route
    .replace(escapeRegExp, '\\$&')
    .replace(optionalParam, '(?:$1)?')
    .replace(namedParam, (match, optional) ->
      if optional then match else '([^\/]+)')
    .replace(splatParam, '(.*?)')
  new RegExp('^' + route + '$')
   
# Returns site, sets the route to the routes object
route = (route, fn) ->
  site = this
  if not type.isFunction(fn) then throw new Error("hello")
  
  # route is a string: parse it and convert it to a regex
  if type.isString(route)
    route = route_to_RegExp(route)

  push.call(site.routes, { route: route, fn: fn }) # add the route to the routes array
  return site
      
# Returns the first object in the routes array, where the incoming route matches the route regex
find_route = (site, inroute) ->
  validate_site(site)
  if not type.isString(inroute) then throw new Error("String inroute required")
  
  # iterate site routes, if regex matches the inroute, return the route
  for obj in site.routes
    if obj.route.exec(inroute)
      return obj
  throw new Error("Route not found")

  
# Returns route functions return value
call_route_fn = (site, inroute) ->
  validate_site(site)
  if not type.isString(inroute) then throw new Error("String site required")
  
  # get the route object from the array of route and create arguments to pass to route function
  route_obj = find_route(site, inroute)
  args = concat.call(
    [FileResponse.create(site, inroute)], # create FileResponse Type
    extract_parameters(route_obj.route, inroute)) # extract the route parameters
    
  route_obj.fn.apply(site, args) # call function
  
  
########## Building

# writes file to outfile path, will make directories to the file if needed
write_file = (outfile, data) ->
  if not type.isString(outfile) then throw new Error("String outfile required")
  
  dirname = path.dirname(outfile) # get the dir of the file
  wrench.mkdirSyncRecursive(dirname, 0o777) # write dir
  fs.writeFileSync(outfile, data) # write file 

###
Returns site instance, builds inroute, calls route function, file is written with response object

{String or Array} inroute: route or routes to build

Example:
  mysite.build(["page/one.html", "page/two.html", "page/three.html"])
  mysite.build("page/one.html")
###
build = (route_or_routes) ->
  site = this
  if not type.isString(route_or_routes)
    if not type.isArray(route_or_routes)
      throw new Error("Route or Routes required.")
  
  # handle Array param
  if type.isArray(route_or_routes)
    return (call_route_fn(site, route) \
      for route in route_or_routes)
  call_route_fn(site, route_or_routes) # call the route function
  return site
  
###
Returns site instance, builds static directory

Example:
  mysite.build_static()
###
build_static = () ->
  site = this
  if not (site.static_path) then return
  
  # copy static directory recursively
  wrench.copyDirSyncRecursive(
    site.static_path,
    path.join(site.build_path, "/static"))
  return site
  
###
Site Type

{Object} obj:  
  * {String} build_path: where files build (save) to.  
  * {String} static_path: static path for static files to be copied over with build_static().  
  * {Fn} constructor
  
Example:
Site.create({
  build_path: "build",
  
  constructor: function() {
    this.route("page/:name", this.page);
  },
  
  page: function(file, name) {
    file.write("Page " + name);
  },
  
})
###
Site = (obj) ->
  validate_site(obj)
  
  this.routes = [] # set routes array
  this[key] = obj[key] for key in Object.keys(obj) # add keys from site object
  this.constructor.apply(this, arguments) # call constructor
  return this
  
Site.prototype = {  
  route: route
  build: build
  build_static: build_static
  
  constructor: () -> return

}

# So I don't screw up and forget new
# This is so ugly, just hanging at the end here
Site.create = (site) ->
   return new Site(site)


###
FileResponse Type
Passed to the route function to write async to the build file

{String} path: filepath to write to.
{Fn} write

Example:
route_fn: function(file) {
  file.write(data);
  file.path;
}
###
FileResponse = (site, inroute) ->
  validate_site(site)
  if not type.isString(inroute) then throw new Error("String inroute required")
  
  this.path = path.join(site.build_path, inroute)  
  return this
  
FileResponse.prototype = {
  # lazy function that writes file for async route funcctions
  write: (data) ->
    file_type = this
    write_file(file_type.path, data)
}
  
# So I don't screw up and forget new
FileResponse.create = (site, inroute) ->
   return new FileResponse(site, inroute)
   
   
############# exports
module.exports.validate_site = validate_site

module.exports.extract_parameters = extract_parameters
module.exports.route_to_RegExp = route_to_RegExp
module.exports.route = route
module.exports.find_route = find_route
module.exports.call_route_fn = call_route_fn

module.exports.write_file = write_file
module.exports.build = build
module.exports.build_static = build_static

module.exports.Site = Site
module.exports.FileResponse = FileResponse
