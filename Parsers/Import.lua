local addonName, addon = ...

local insert = table.insert

addon.ImportParserPrototype = {}

local ImportParser = addon.ImportParserPrototype
ImportParser.__index = ImportParser

function ImportParser:new(jsonParser, base64Parser)
    local instance = setmetatable({}, self)

    instance.jsonParser = jsonParser or addon.JsonParserPrototype:new()
    instance.base64Parser = base64Parser or addon.Base64ParserPrototype:new()

    return instance
end

function ImportParser:import(str)
    if self.base64Parser:isBase64Encoded(str) then
        return self.jsonParser:decode(self.base64Parser:decode(str))
    end

    return self.jsonParser:decode(str)
end
