local addonName, addon = ...

local insert = table.insert

addon.ImportParserPrototype = {}

local ImportParser = addon.ImportParserPrototype
ImportParser.__index = ImportParser

function ImportParser:New(jsonParser, base64Parser)
    local instance = setmetatable({}, self)

    instance.jsonParser = jsonParser or addon.JsonParserPrototype:New()
    instance.base64Parser = base64Parser or addon.Base64ParserPrototype:New()

    return instance
end

function ImportParser:Import(str)
    if self.base64Parser:IsBase64Encoded(str) then
        return self.jsonParser:Decode(self.base64Parser:Decode(str))
    end

    return self.jsonParser:Decode(str)
end
