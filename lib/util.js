// Generated by CoffeeScript 1.6.1
(function() {
  var concat, delay, filter, fs, indexOf, listfilesSync, map, path, println, util, watch, wrench;

  fs = require("fs");

  util = require("util");

  path = require("path");

  println = console.log;

  map = Array.prototype.map;

  filter = Array.prototype.filter;

  indexOf = Array.prototype.indexOf;

  concat = Array.prototype.concat;

  delay = setTimeout;

  var type = {}; type["isArray"] = Array.prototype.isArray || function(obj) { return Object.prototype.toString.call(obj) == '[object Array]'; }; type["isObject"] = function(obj) { return obj === Object(obj); }; ['Arguments', 'Function', 'String', 'Number', 'Date', 'RegExp'].map(function(name) { type["is" + name] = function(obj) { return toString.call(obj) == '[object ' + name + ']'; }; });;

  wrench = require("wrench");

  /*
  Watches directories recursively, calls callback on changes
  note: uses delay to tackle nodejs calling change multiple times
  
  {Array} watch_dirs: array of file directories to watch
  {Fn} callback
  
  Example:
  watch(["page", "static"], function(filename) {
    // do stuff
  })
  */


  watch = function(watch_dirs, callback) {
    if (!type.isArray(watch_dirs)) {
      throw new Error("String watch_dirs required");
    }
    if (!type.isFunction(callback)) {
      throw new Error("Function callback required");
    }
    return map.call(watch_dirs, function(watch_dir) {
      var delay_timeout, files_arr, files_arr_fullpaths;
      files_arr = filter.call(wrench.readdirSyncRecursive(watch_dir), function(filename) {
        var filepath;
        filepath = path.join(watch_dir, filename);
        return !filepath.match(".git");
      });
      files_arr_fullpaths = concat.call(map.call(files_arr, function(filename) {
        return path.join(watch_dir, filename);
      }), watch_dir);
      delay_timeout = null;
      return map.call(files_arr_fullpaths, function(filepath) {
        return fs.watch(filepath, function(event, filename) {
          clearTimeout(delay_timeout);
          return delay_timeout = delay(function() {
            return callback(filename);
          }, 25);
        });
      });
    });
  };

  /*
  list only files from a directory , recur for recursiveness
  
  {String} filepath
  {Object} options:
    {Boolean} recur: read dir recursively
  
  Example:
  listfilesSync("page", { recur: true })
  */


  listfilesSync = function(filepath, options) {
    var files_arr;
    if (!type.isString(filepath)) {
      throw new Error("String filepath required");
    }
    options = options || {};
    if (options.recur) {
      files_arr = wrench.readdirSyncRecursive(filepath);
    } else {
      files_arr = fs.readdirSync(filepath);
    }
    return filter.call(files_arr, function(filename) {
      var filenamepath;
      filenamepath = path.join(filepath, filename);
      return fs.statSync(filenamepath).isFile();
    });
  };

  module.exports.watch = watch;

  module.exports.listfilesSync = listfilesSync;

}).call(this);
