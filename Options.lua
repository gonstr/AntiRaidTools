
local insert = table.insert

local AntiRaidTools = AntiRaidTools

local SharedMedia = LibStub("LibSharedMedia-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

AntiRaidTools.OptionsPrototype = {}

local Options = AntiRaidTools.OptionsPrototype
Options.__index = Options

function Options:new(import, utils)
    local instance = setmetatable({}, self)

    self.import = import or AntiRaidTools.ImportPrototype:new()
    self.utils = utils or AntiRaidTools.UtilsPrototype:new()

    return instance
end

local function mainOptions(db)
    local options = {
        name = "Anti Raid Tools " .. AntiRaidTools.VERSION,
        type = "group",
        args =  {
            buttonGroup = {
                type = "group",
                inline = true,
                name = "",
                order = 1,
                args = {
                    joinDiscord = {
                        type = "execute",
                        name = "Join Discord",
                        desc = "Join Discord",
                        func = function()
                            if not InCombatLockdown() then
                                -- TODO
                            end
                        end,
                        order = 1,
                    },
                    toggleAnchors = {
                        type = "execute",
                        name = "Toggle Anchors",
                        desc = "Toggle UI Anchors visibility",
                        func = function()
                            if not InCombatLockdown() then
                                -- TODO
                            end
                        end,
                        order = 2,
                    },
                    toggleTestMode = {
                        type = "execute",
                        name = "Toggle Test Mode",
                        desc = "Toggle Test Mode",
                        func = function()
                            if not InCombatLockdown() then
                                -- TODO
                            end
                        end,
                        order = 3,
                    },
                },
            },
            importGroup = {
                type = "group",
                inline = true,
                name = "",
                order = 2,
                args = {}
            }
        },
    }

    local importIndex = 1

    for _, import in ipairs(db.profile.v1.imports) do
        options.args.importGroup.args["import" .. importIndex] = {
            type = "execute",
            dialogControl = "AntiRaidToolsImport",
            name = import.name or "",
            width = "full",
            order = importIndex,
            arg = {
                improt = import
            }
        }

        importIndex = importIndex + 1
    end
    
    return options
end

local importDescription = [[
Paste import data below:
]]

local function importOptions(db, import, utils)
    return {
        name = "Import",
        type = "group",
        args = {
            description = {
                type = "description",
                name = importDescription,
                fontSize = "medium",
                order = 1,
            },
            import = {
                type = "input",
                name = "Import",
                desc = "Paste your import data here.",
                multiline = 25,
                width = "full",
                order = 2,
                get = function() return db.profile.v1.options.import end,
                set = function(_, val)
                    if val then
                        val = val:trim()
                    end

                    if val and not AntiRaidTools.Base64ParserPrototype:new():isBase64Encoded(val) then
                        db.profile.v1.options.import = val
                    else
                        db.profile.v1.options.import = nil
                    end

                    AntiRaidTools:SendMessage(AntiRaidTools.EVENTS.IMPORT_LOADED, val)
                end,
                validate = function(_, val)            
                    if val then
                        val = val:trim()
                    end
                    
                    if not val or val == "" then
                        return true
                    end
            
                    local ok, result = pcall(function() return import:import(val) end)
        
                    if not ok then
                        return utils:stripErrorFileAndLine(result)
                    end
            
                    return true
                end
            },
        },
    }
end

function Options:init(db)
    AceConfigRegistry:RegisterOptionsTable("AntiRaidTools", mainOptions(db))
    AceConfigDialog:AddToBlizOptions("AntiRaidTools", "Anti Raid Tools")
    
    AceConfigRegistry:RegisterOptionsTable("AntiRaidTools Import", importOptions(db, self.import, self.utils))
    AceConfigDialog:AddToBlizOptions("AntiRaidTools Import", "Import", "Anti Raid Tools")

    AceConfigRegistry:RegisterOptionsTable("AntiRaidTools Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(db))
    AceConfigDialog:AddToBlizOptions("AntiRaidTools Profiles", "Profiles", "Anti Raid Tools")
end

function Options:notifyChange()
    AceConfigRegistry:NotifyChange("AntiRaidTools")
end
