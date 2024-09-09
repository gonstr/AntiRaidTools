luaunit = require("Tests/luaunit")

addonName, addon = "AntiRaidTools", {}

loadfile("Parsers/Base64.lua")(addonName, addon)
loadfile("Parsers/JSON.lua")(addonName, addon)
loadfile("Parsers/Import.lua")(addonName, addon)
loadfile("Import.lua")(addonName, addon)
loadfile("ImportValidator.lua")(addonName, addon)
loadfile("Utils.lua")(addonName, addon)

addon.utils = addon.UtilsPrototype:New()
addon.jsonParser = addon.JsonParserPrototype:New()
addon.base64Parser = addon.Base64ParserPrototype:New()
addon.importParser = addon.ImportParserPrototype:New()
addon.importValidator = addon.ImportValidatorPrototype:New()
addon.import = addon.ImportPrototype:New()

-- Polyfills
function GetBuildInfo()
    return "9.0.2", "36665", "Nov 17 2020", 40002
end

require("Tests/JsonParserTest")
require("Tests/Base64ParserTest")
require("Tests/ImportParserTest")
require("Tests/ImportValidatorTest")
require("Tests/ImportTest")
require("Tests/UtilsTest")

os.exit(luaunit.LuaUnit.run())
