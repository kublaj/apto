########## utils for apto
fs = require("fs")
util = require("util")
path = require("path")

println = console.log
map = Array.prototype.map
filter = Array.prototype.filter
indexOf = Array.prototype.indexOf
concat = Array.prototype.concat
delay = setTimeout
# typechecking
`var type = {}; type["isArray"] = Array.prototype.isArray || function(obj) { return Object.prototype.toString.call(obj) == '[object Array]'; }; type["isObject"] = function(obj) { return obj === Object(obj); }; ['Arguments', 'Function', 'String', 'Number', 'Date', 'RegExp'].map(function(name) { type["is" + name] = function(obj) { return toString.call(obj) == '[object ' + name + ']'; }; });`

wrench = require("wrench")


############# file watcher

###
Watches directories recursively, calls callback on changes
note: uses delay to tackle nodejs calling change multiple times

{Array} watch_dirs: array of file directories to watch
{Fn} callback

Example:
watch(["page", "static"], function(filename) {
  // do stuff
})
###
watch = (watch_dirs, callback) ->
  if not type.isArray(watch_dirs) then throw new Error("String watch_dirs required");
  if not type.isFunction(callback) then throw new Error("Function callback required");
  
  # iterate watch directories
  map.call(
    watch_dirs,
    (watch_dir) ->
      
      # filter out anything we do not want to watch
      files_arr = filter.call(
        wrench.readdirSyncRecursive(watch_dir),
        (filename) ->
          filepath = path.join(watch_dir, filename)
          # TODO make this universal and not just for .git
          return not filepath.match(".git")) # is a directory and not a .git
                
      # add fullpath to array of files and add base folder to the array
      files_arr_fullpaths = concat.call(map.call(
        files_arr,
        (filename) ->
          path.join(watch_dir, filename)), watch_dir)
                            
      # watch all files and call callback on changes
      delay_timeout = null
      map.call(
        files_arr_fullpaths,
        (filepath) ->
          # start watching
          fs.watch(filepath, (event, filename) ->
            # use a small delay and clear timeout to prevent from firing twice
            clearTimeout(delay_timeout)
            delay_timeout = delay(() ->
              callback(filename) # do callback
            , 25))))


########### File utils

###
list only files from a directory , recur for recursiveness

{String} filepath
{Object} options:
  {Boolean} recur: read dir recursively

Example:
listfilesSync("page", { recur: true })
###
listfilesSync = (filepath, options) ->
  if not type.isString(filepath) then throw new Error("String filepath required");
  options = options or {}
  
  if options.recur
    files_arr = wrench.readdirSyncRecursive(filepath)
  else  
    files_arr = fs.readdirSync(filepath)
    
  # filter only files
  filter.call(
    files_arr,
    (filename) ->
      filenamepath = path.join(filepath, filename)
      fs.statSync(filenamepath).isFile())

 
############# exports
module.exports.watch = watch
module.exports.listfilesSync = listfilesSync
