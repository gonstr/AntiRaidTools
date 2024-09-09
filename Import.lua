local addonName, addon = ...

addon.ImportPrototype = {}

local Import = addon.ImportPrototype
Import.__index = Import

function Import:New()
    local instance = setmetatable({}, self)
    return instance
end

function Import:Import(text)
    local ok, result = pcall(function()
        local import = addon.importParser:Import(text)

        addon.importValidator:Validate(import)

        return import
    end)

    if not ok then
        if addon.base64Parser:IsBase64Encoded(text) then
            error("Failed to parse import")
        else
            error(addon.utils:StripErrorFileAndLine(result))
        end
    end

    return result
end
