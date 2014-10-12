fs = require("fs")
assert = require("assert")
map = Array.prototype.map

apto_util = require("../lib/util")

listfilesSync = apto_util.listfilesSync
watch = apto_util.watch
test = (desc, fn) -> fn()

  
test("listfilesSync", () ->
  # test dirs
  listfilesSync("test")
  listfilesSync("test/test_project")
      
  map.call(
    listfilesSync("."),
    (filename) ->
      assert.ok(fs.statSync(filename).isFile()))
  
  # make sure it's just files
  map.call(
    listfilesSync(".", {recur: true}),
    (filename) ->
      assert.ok(fs.statSync(filename).isFile())))
    
test("watch", () ->
  # should throw error for being a String
  assert.throws(
    () ->
      watch("not array", (filename) -> println filename)
  , Error)
  
  watch(["./test", "."], (filename) ->
    println "changed " + filename))