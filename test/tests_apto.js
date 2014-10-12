// Generated by CoffeeScript 1.4.0
(function() {
  var FileResponse, Site, apto, assert, build, build_static, call_route_fn, extract_parameters, find_route, fs, handler, path, println, route, route_to_RegExp, site, site_with_fn, site_with_static, site_with_static_relative, test, util, validate_site, wrench, write_file;

  fs = require("fs");

  util = require("util");

  path = require("path");

  assert = require("assert");

  println = console.log;

  var type = {}; type["isArray"] = Array.prototype.isArray || function(obj) { return Object.prototype.toString.call(obj) == '[object Array]'; }; type["isObject"] = function(obj) { return obj === Object(obj); }; ['Arguments', 'Function', 'String', 'Number', 'Date', 'RegExp'].map(function(name) { type["is" + name] = function(obj) { return toString.call(obj) == '[object ' + name + ']'; }; });;


  apto = require("../lib/apto");

  Site = apto.Site;

  FileResponse = apto.FileResponse;

  validate_site = apto.validate_site;

  route = apto.route;

  build_static = apto.build_static;

  build = apto.build;

  write_file = apto.write_file;

  call_route_fn = apto.call_route_fn;

  find_route = apto.find_route;

  extract_parameters = apto.extract_parameters;

  route_to_RegExp = apto.route_to_RegExp;

  test = function(desc, fn) {
    return fn();
  };

  wrench = require("wrench");

  site = Site.create({
    build_path: path.join(process.cwd(), "/test/test_project/build"),
    handler: function(file) {},
    constructor: function() {
      return this.route(/\/(.*)+\/(.*)+\/?/, this.handler);
    }
  });

  site_with_static = Site.create({
    build_path: path.join(process.cwd(), "/test/test_project/build"),
    static_path: path.join(process.cwd(), "/test/test_project/static"),
    handler: function(file) {},
    constructor: function() {
      return this.route(/\/(.*)+\/(.*)+\/?/, this.handler);
    }
  });

  site_with_static_relative = Site.create({
    build_path: "../test/test_project/build",
    static_path: "../test/test_project/static",
    constructor: function() {
      return this.route(/\/(.*)+\/(.*)+\/?/, this.handler);
    },
    handler: function(file) {}
  });

  handler = function() {};

  site_with_fn = Site.create({
    build_path: path.join(process.cwd(), "/test/test_project/build"),
    static_path: path.join(process.cwd(), "/test/test_project/static"),
    constructor: function() {
      return this.route(/\/(.*)+\/(.*)+\/?/, handler);
    }
  });

  test("create", function() {
    return assert.throws(function() {
      return Site.create({});
    }, Error);
  });

  test("validate_site", function() {
    assert.throws(function() {
      return validate_site({});
    }, Error);
    validate_site({
      build_path: path.join(process.cwd(), "/test/test_project/build"),
      handler: function(file) {
        return file.write("hello world");
      },
      constructor: function() {
        return this.route(/\/(.*)+\/(.*)+\/?/, this.handler);
      }
    });
    return validate_site({
      build_path: path.join(process.cwd(), "/test/test_project/build"),
      static_path: path.join(process.cwd(), "/test/test_project/static"),
      handler: function(file) {
        return file.write("hello world");
      },
      constructor: function() {
        return this.route(/\/(.*)+\/(.*)+\/?/, this.handler);
      }
    });
  });

  test("extract parameters", function() {
    return assert.ok(extract_parameters(/\/(.*)+\/(.*)+\/?/, "/page/1")) === ["page", "1"];
  });

  test("route_to_RegExp", function() {
    assert.ok(route_to_RegExp("/page/1").toString() === "/^/page/1$/");
    return assert.ok(route_to_RegExp("/:page/:id").toString() === "/^/([^/]+)/([^/]+)$/");
  });

  test("route function", function() {
    var _route, _site;
    _route = /\/(.*)+\/(.*)+\/?/;
    route.call(site, "/test", site.handler);
    _site = route.call(site, _route, site.handler);
    return assert.ok(_site.routes[2].route === _route);
  });

  test("find route", function() {
    return assert.ok(find_route(site, "/page/1") === site.routes[0]);
  });

  test("call_route_fn", function() {
    return call_route_fn(site, "/page/1");
  });

  test("route not matching any routes", function() {
    var _site;
    _site = Site.create({
      build_path: "build",
      handler: function(file) {},
      constructor: function() {
        return this.route(/\/(.*)+\/(.*)+\/?/, this.handler);
      }
    });
    return assert.throws(function() {
      return call_route_fn(_site, "/index.html");
    }, Error);
  });

  test("passing params to route functions", function() {
    var _site;
    _site = Site.create({
      build_path: "build",
      handler: function(file, page, id) {
        assert.ok(page === "page");
        return assert.ok(id === "1");
      },
      constructor: function() {
        return this.route(/\/(.*)+\/(.*)+\/?/, this.handler);
      }
    });
    return call_route_fn(_site, "/page/1");
  });

  test("test routing", function() {
    site = Site.create({
      build_path: path.join(process.cwd(), "/test/test_project/build"),
      home_handler: function(file, param) {
        return assert.ok(param === void 0);
      },
      page_handler: function(file, article, id) {
        assert.ok(article !== "index.html");
      },
      main_handler: function(file, page) {
        assert.ok(page === "index");
        assert.ok(page !== "page");
      },
      constructor: function() {
        this.route("/home", this.home_handler);
        this.route(/\/(.*)+.html/, this.main_handler);
        return this.route(/\/(.*)+\/(.*)+\/?/, this.page_handler);
      }
    });
    site.build("/index.html");
    site.build("/page/1");
    return site.build("/home");
  });

  test("test pretty string routing", function() {
    site = Site.create({
      build_path: path.join(process.cwd(), "/test/test_project/build"),
      home_handler: function(file, param) {
        return assert.ok(param === void 0);
      },
      page_handler: function(file, article, id) {
        assert.ok(article !== "index.html");
      },
      main_handler: function(file, page) {
        assert.ok(page === "index");
        assert.ok(page !== "page");
      },
      constructor: function() {
        this.route("/home", this.home_handler);
        this.route("/:page.html", this.main_handler);
        return this.route("/:article/:id", this.page_handler);
      }
    });
    site.build("/index.html");
    site.build("/page/1");
    return site.build("/home");
  });

  test("write file", function() {
    var file_content, filename;
    filename = path.join(site.build_path, "/page/1");
    file_content = "page data";
    write_file(filename, file_content);
    return assert.ok(fs.readFileSync(filename).toString() === file_content);
  });

  test("FileResponse Type", function() {
    var file;
    file = FileResponse.create(site, "/page/test.html");
    assert.ok(type.isObject(file));
    assert.ok(type.isString(file.path));
    return assert.ok(type.isFunction(file.write));
  });

  test("FileResponse end function", function() {
    var content, _site;
    content = "page data";
    _site = Site.create({
      build_path: path.join(process.cwd(), "/test/test_project/build"),
      handler: function(file, page, id) {
        return file.write(content);
      },
      constructor: function() {
        return this.route(/\/(.*)+\/(.*)+\/?/, this.handler);
      }
    });
    call_route_fn(_site, "/page/1.html");
    return assert.ok(fs.readFileSync(path.join(_site.build_path, "/page/1.html")).toString() === content);
  });

  test("build", function() {
    assert.throws(function() {
      return build.call(site, null);
    }, Error);
    build.call(site, "/page/1");
    build.call(site, ["/page/1", "/page/2"]);
    return build.call(site_with_fn, "/page/1");
  });

  test("build_static", function() {
    assert.throws(function() {
      return fs.statSync(site.build_path + "/static");
    }, Error);
    build_static.call(site);
    build_static.call(site_with_static);
    build_static.call(site_with_static);
    return fs.statSync(site.build_path + "/static");
  });

  test("chaining", function() {
    return site.build("/page/1").build("/page/1").build_static();
  });

  wrench.rmdirSyncRecursive(site.build_path);

}).call(this);