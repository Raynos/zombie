if process.version >= "v0.5.0"
  Util = require("util")
else
  Util = require("sys")

formatRegExp = /%[sdj]/g

format = Util.format || (f) ->
  util = require("util")
  if typeof f isnt "string"
    objects = []
    i = 0

    while i < arguments.length
      objects.push util.inspect(arguments[i])
      i++
    return objects.join(" ")
  i = 1
  args = arguments
  str = String(f).replace(formatRegExp, (x) ->
    switch x
      when "%s"
        String args[i++]
      when "%d"
        Number args[i++]
      when "%j"
        JSON.stringify args[i++]
      else
        x
  )
  len = args.length
  x = args[i]

  while i < len
    if x is null or typeof x isnt "object"
      str += " " + x
    else
      str += " " + util.inspect(x)
    x = args[++i]
  str

Browser = require("./browser")


# ### zombie.visit(url, callback)
# ### zombie.visit(url, options, callback)
#
# Creates a new Browser, opens window to the URL and calls the callback when
# done processing all events.
#
# For example:
#     zombie = require("zombie")
#
#     vows.describe("Brains").addBatch(
#       "seek":
#         topic: ->
#           zombie.browse "http://localhost:3000/brains", @callback
#       "should find": (browser)->
#         assert.ok browser.html("#brains")[0]
#     ).export(module);
#
# * url -- URL of page to open
# * options -- Initialize the browser with these options
# * callback -- Called with error, browser
visit = (url, options, callback)->
  new Browser(options).visit(url, options, callback)


# ### listen port, callback
# ### listen socket, callback
# ### listen callback
#
# Ask Zombie to listen on the specified port for requests.  The default
# port is 8091, or you can specify a socket name.  The callback is
# invoked once Zombie is ready to accept new connections.
listen = (port, callback)->
  require("./zombie/protocol").listen(port, callback)


# console.log(browser) pukes over the terminal, so we apply some sane
# defaults.  You can override these:
# console.depth -       How many time to recurse while formatting the
#                       object (default to zero)
# console.showHidden -  True to show non-enumerable properties (defaults
#                       to false)
console.depth = 0
console.showHidden = false
console.log = ->
  formatted = ((if typeof arg == "string" then arg else Util.inspect(arg, console.showHidden, console.depth)) for arg in arguments)
  if typeof format == 'function'
    process.stdout.write format.apply(this, formatted) + "\n"
  else
    process.stdout.write formatted.join(" ") + "\n"


Browser.listen  = listen
Browser.visit   = visit

# Default to debug mode if environment variable `DEBUG` is set.
Browser.debug = !!process.env.DEBUG
Browser.Browser = Browser

# Export the globals from browser.coffee
module.exports = Browser
