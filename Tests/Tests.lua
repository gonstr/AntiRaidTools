luaunit = require("Tests/luaunit")

addonName, addon = "AntiRaidTools", {}

loadfile("Parsers/Base64.lua")(addonName, addon)
loadfile("Parsers/JSON.lua")(addonName, addon)
loadfile("Parsers/Import.lua")(addonName, addon)
loadfile("Import.lua")(addonName, addon)
loadfile("ImportValidator.lua")(addonName, addon)
loadfile("Utils.lua")(addonName, addon)

require("Tests/JsonParserTest")
require("Tests/Base64ParserTest")
require("Tests/ImportParserTest")
require("Tests/ImportValidatorTest")
require("Tests/ImportTest")
require("Tests/UtilsTest")

os.exit(luaunit.LuaUnit.run())
