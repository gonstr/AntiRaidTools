luaunit = require("Tests/luaunit")

AntiRaidTools = {}

require("Tests/JsonParserTest")
require("Tests/Base64ParserTest")
require("Tests/ImportParserTest")
require("Tests/ImportValidatorTest")
require("Tests/ImportTest")
require("Tests/UtilsTest")

os.exit(luaunit.LuaUnit.run())
