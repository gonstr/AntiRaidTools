local addonName, addon = ...

local insert = table.insert

addon.ImportParserPrototype = {}

local ImportParser = addon.ImportParserPrototype
ImportParser.__index = ImportParser

function ImportParser:New()
    local instance = setmetatable({}, self)
    return instance
end

function ImportParser:Import(str)
    if addon.base64Parser:IsBase64Encoded(str) then
        return addon.jsonParser:Decode(addon.base64Parser:Decode(str))
    end

    return addon.jsonParser:Decode(str)
end
