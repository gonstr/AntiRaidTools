local AntiRaidTools = AntiRaidTools

AntiRaidTools.ImportPrototype = {}

local Import = AntiRaidTools.ImportPrototype
Import.__index = Import

function Import:new(utils, importParser, base64Parser, importValidator)
    local instance = setmetatable({}, self)

    self.utils = utils or AntiRaidTools.UtilsPrototype:new()
    self.importParser = importParser or AntiRaidTools.ImportParserPrototype:new()
    self.base64Parser = base64Parser or AntiRaidTools.Base64ParserPrototype:new()
    self.importValidator = importValidator or AntiRaidTools.ImportValidatorPrototype:new()

    return instance
end

function Import:import(text)
    local _self = self

    local ok, result = pcall(function()
        local import = _self.importParser:import(text)

        _self.importValidator:validate(import)

        return import
    end)

    if not ok then
        if self.base64Parser:isBase64Encoded(text) then
            error("Failed to parse import")
        else
            error(self.utils:stripErrorFileAndLine(result))
        end
    end

    return result
end
