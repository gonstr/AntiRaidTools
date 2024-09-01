local addonName, addon = ...

addon.ImportPrototype = {}

local Import = addon.ImportPrototype
Import.__index = Import

function Import:New(utils, importParser, base64Parser, importValidator)
    local instance = setmetatable({}, self)

    instance.utils = utils or addon.UtilsPrototype:New()
    instance.importParser = importParser or addon.ImportParserPrototype:New()
    instance.base64Parser = base64Parser or addon.Base64ParserPrototype:New()
    instance.importValidator = importValidator or addon.ImportValidatorPrototype:New()

    return instance
end

function Import:Import(text)
    local _self = self

    local ok, result = pcall(function()
        local import = _self.importParser:Import(text)

        _self.importValidator:Validate(import)

        return import
    end)

    if not ok then
        if self.base64Parser:IsBase64Encoded(text) then
            error("Failed to parse import")
        else
            error(self.utils:StripErrorFileAndLine(result))
        end
    end

    return result
end
