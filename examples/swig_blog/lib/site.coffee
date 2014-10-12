############ Command line manager for the project
fs = require("fs")
path = require("path")
println = console.log;
concat = Array.prototype.concat;
map = Array.prototype.map;
filter = Array.prototype.filter;
sort = Array.prototype.sort;
indexOf = Array.prototype.indexOf;

swig  = require("swig")
express = require('express')
apto = require("apto") # TODO this needs to be an actual module


# swig config, sets template directory and caching
swig.init({
  cache: false,
  root: "."
})
 
########## post functions
  
# Returns a object of post file parsed
parse_post = (filename) ->
  filepath = path.join("post/", filename)
  file = fs.readFileSync(filepath).toString()
  try
    title = /{%.*?block.*?title.*?%}([\s\S]*?){%.*?endblock.*?%}/m
    .exec(file)[1].trim()
    author = /{%.*?block.*author.*?%}([\s\S]*?){%.*?endblock.*?%}/m
      .exec(file)[1].trim()
    date = /{%.*?block.*?date.*?%}([\s\S]*?){%.*?endblock.*?%}/m
      .exec(file)[1].trim()
    body = /{%.*?block.*?body.*?%}([\s\S]*?){%.*?endblock.*?%}/m
      .exec(file)[1].trim()
    
    return {
      path: filepath,
      title: title,
      author: author,
      date: date,
      body: body
    }
  catch e
    return undefined

# Returns an array of sorted and parsed posts
get_posts =() ->
  filenames = apto.util.listfilesSync("post", { recur: true })
  
  # parse all posts
  posts = map.call(filenames, (filename) ->
    return parse_post(filename))
  
  # filter out failed parses  
  filtered_posts = filter.call(posts, (post) -> post?)
  
  # sort posts by date reversed
  reversed_sorted_posts = sort.call(posts, (a, b) ->
    if a.date < b.date
      return 1
    if a.date > b.date
      return -1
    return 0)
  return reversed_sorted_posts

# Returns generated post template data
make_post_template_data = (route) ->
  try
    template_data = { posts: get_posts() }
    
    # get post index
    post_index = indexOf.call(
      template_data.posts,
      filter.call(
        template_data.posts,
        (post) ->
          route == post.path)[0])
    
    ########## handle previous and next posts 
    if (post_index != 0)
     template_data.previous_post = template_data.posts[post_index - 1] 
    if (post_index != template_data.posts.length - 1)
     template_data.next_post = template_data.posts[post_index + 1]
     
    return template_data 
  return undefined
        
########## Site

# apto site
site = apto.Site.create({
  build_path: "build",
  static_path: "static",
  
  constructor: () ->
    this.route("post/:name", this.post)
    this.route(":page", this.page)
  
  post: (file, name) ->
    filename = path.join("post/", name)
    template_data = make_post_template_data(filename)
    file.write(
      swig.compileFile(filename).render(template_data))
    
  page: (file, page) ->
    template_data = { 
      posts: get_posts()
      pages: apto.util.listfilesSync("page", { recur: true })
    }
    file.write(
      swig.compileFile(path.join("page/", page)).render(template_data))
      
  buildall: () ->
    pages = apto.util.listfilesSync("page", { recur: true })
    posts = (path.join("post/", p) \
      for p in apto.util.listfilesSync("post", { recur: true }))
    site_pages = concat.call(pages, posts)
    site.build(site_pages)
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
      apto.util.watch(["page", "post", "static", "layout"], (filename) ->
        site.buildall())
      express().use(express.static(site.build_path)).listen(port)
    else
      console.log("""
      
        Usage: site [server|build]
      
          serve  <port>   Start an development server, auto reloads changes for you.
          build           Build site.
      
      
      """)
  
