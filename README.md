# Apto

Apto is a easy to use, straight-forward static site generator / builder for Node.js.

Uses:
* Build a static site/blog.
* Build out site pages on a server.
* Build certain files whenever you do a write to the database.

## Download
```shell
npm install apto
```

## Quick Example

```javascript
var apto = require("apto");

var mysite = apto.Site.create({
  build_path: "build",
  
  constructor: function() {
    this.route("page/:name", this.page);
  },
  
  page: function(file, name) {
    file.write("Page " + name);
  },
  
});

// build some routes
mysite.build(["page/one.html", "page/two.html", "page/three.html"]);

```

## Quick Start
Download an static site generator example from /examples.

```shell
cd examples/swig_blog
npm install
./manage.js serve
```

## Documentation

* [Site](#Site)
* [build](#build)
* [build_static](#build_static)    
* [FileResponse](#FileResponse)

#### util
* [watch](#watch)  
* [listfilesSync](#listfilesSync)  
 
<br />

<a name="Site" />
### Site(obj)

{Object} obj:  
  * {String} build_path: where files build (save) to.  
  * {String} static_path: static path for static files to be copied over with build_static().  
  * {Fn} constructor
  
Example:
```js
Site.create({
  build_path: "build",
  
  constructor: function() {
    this.route("page/:name", this.page);
  },
  
  page: function(file, name) {
    file.write("Page " + name);
  },
  
});
```
---------------------------------------

<a name="build" />
### build(route_or_routes)
Returns site instance, builds inroute, calls route function, file is written with response object

{String or Array} inroute: route or routes to build

Example:
```js
mysite.build(["page/one.html", "page/two.html", "page/three.html"]);
mysite.build("page/one.html");
```
---------------------------------------

<a name="build_static" />
### build_static()
Returns site instance, builds static directory

Example:
```js
mysite.build_static();
```
---------------------------------------

<a name="FileResponse" />
### FileResponse
FileResponse Type
Passed to the route function to write async to the build file

Properties:
* {String} path: filepath to write to.  
* {Fn} write

Example:
```js
route_fn: function(file) {
  file.write(data);
  file.path;
}
```
---------------------------------------

<a name="listfilesSync" />
### listfilesSync(filepath, options)
list only files from a directory , recur for recursiveness

{String} filepath  
{Object} options:
  * {Boolean} recur: read dir recursively

Example:
```js
listfilesSync("page", { recur: true });
```
---------------------------------------

<a name="watch" />
### watch((watch_dirs, callback))
Watches directories recursively, calls callback on changes  
note: uses delay to tackle nodejs calling change multiple times

{Array} watch_dirs: array of file directories to watch  
{Fn} callback

Example:
```js
watch(["page", "static"], function(filename) {
  // do stuff
});
```
---------------------------------------

## License
(The MIT License)

Copyright (c) 2013 Austin Brown

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
