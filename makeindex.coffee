
fs = require 'fs'
coffee = require 'coffee-script'

source = 'app.coffee' # source file name.

# Check version.
[majver, minver] = coffee.VERSION.split('.')
if majver < 1 or minver < 6
    throw new Error "Coffee-script should be version >=1.6 to generate maps."

# 1. Compile coffeescript with maps.
coffeeSource = fs.readFileSync(source, "utf8")
{js, v3SourceMap} = coffee.compile coffeeSource,
    bare: true
    sourceMap: true
    filename: source

# 2. Include original coffee file as a sourcesContent in the map.
v3SourceMap = JSON.parse(v3SourceMap)
v3SourceMap.sourcesContent = [fs.readFileSync(source, "utf8")]
v3SourceMap = JSON.stringify(v3SourceMap)

# 3. Append data/base64 encoded map.
js = """
#{js}
//@ sourceMappingURL=data:application/json;base64,#{new Buffer(v3SourceMap).toString('base64')}
//@ sourceURL=#{source.replace('.coffee', '.js')}
"""

# 3. Make index.html
fs.writeFileSync 'index.html', fs.readFileSync('index.html.in', 'utf8').replace("%JSSOURCE%", JSON.stringify(js))

console.log "Wrote index.html. Now open it in browser."
