
local addonName, addon = ...

local insert = table.insert

local SharedMedia = LibStub("LibSharedMedia-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

addon.OptionsPrototype = {}

local Options = addon.OptionsPrototype
Options.__index = Options

_G.StaticPopupDialogs["ART_Link"] = {
    text = "Press Ctrl+C to copy the URL to your clipboard",
    hasEditBox = 1,
    button1 = _G.OKAY,
    OnShow = function(self)
        if addon.url then
            local box = getglobal(self:GetName() .. "EditBox")
            if box then
                box:SetWidth(275)
                box:SetText(addon.url)
                box:HighlightText()
                box:SetFocus()
            end
        end
    end,

    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1
}

local listedPackTypes = {
    ["TIMER"] = "Timers",
    ["STATE"] = "State",
    ["EVENT"] = "Events",
    ["RAID_FRAME_ICON"] = "Raid Frame Icons",
    ["SOUND"] = "Sounds"
}

local function packArgs(db, pack, utils, encounters)
    local order = 1    

    local args = {
        header = {
            type = "header",
            --dialogControl = "AntiRaidToolsPackHeader",
            width = "full",
            name = pack.name,
            order = order,
        }
    }

    order = order + 1

    for encounter, items in pairs(utils:groupTable(pack.items, function(item) return item.encounter end)) do
        args["encounter:" .. encounter] = {
            type = "header",
            width = "full",
            name = encounters:get(encounter) or "???",
            order = order
        }

        order = order + 1

        for packType, header in pairs(listedPackTypes) do
            local items = utils:filterTable(items, function(item) return item.type == packType end)
    
            if #items > 0 then
                local typeArgs = {}

                args["items:" .. packType] = {
                    type = "group",
                    inline = true,
                    name = header,
                    order = order,
                    args = typeArgs
                }

                local typeOrder = 1

                for _, item in ipairs(items) do
                    typeArgs["item:" .. item.id] = {
                        type = "toggle",
                        name = item.id,
                        order = typeOrder,
                        get = function()
                            local packOptions = db.profile.v1.options.packOptions[pack.id]

                            if packOptions and packOptions[item.id] ~= nil then
                                return packOptions[item.id]
                            end

                            return true
                        end,
                        set = function(_, val)
                            local packOptions = db.profile.v1.options.packOptions[pack.id]

                            if not packOptions then
                                db.profile.v1.options.packOptions[pack.id] = {}
                            end

                            db.profile.v1.options.packOptions[pack.id][item.id] = val
                        end
                    }
    
                    typeOrder = typeOrder + 1
                end
            end

            order = order + 1
        end
    end

    return args
end

local function packsGroup(db, utils, encounters)
    local group = {
        name = "Packs",
        type = "group",
        order = 4,
        childGroups = "tree",
        args = {}
    }

    local order = 1

    for _, pack in pairs(db.profile.v1.packs) do
        group.args["pack:" .. pack.id] = {
            type = "group",
            name = pack.name,
            order = order,
            args = packArgs(db, pack, utils, encounters)
        }

        order = order + 1
    end

    if order == 1 then
        -- No packs
        group.args["noPacksPlaceholder"] = {
            type = "description",
            width = "full",
            dialogControl = "AntiRaidToolsPlaceholder", 
            name = "Join our discord to download and import addon packs."
        }
    end

    return group
end

local function importGroup(db, utils, import)
    return {
        name = "Import",
        type = "group",
        order = 5,
        args = {
            description = {
                type = "description",
                name = "Paste import data:",
                order = 1,
            },
            import = {
                type = "input",
                name = "",
                multiline = 25,
                width = "full",
                order = 2,
                get = function() return db.profile.v1.options.import end,
                set = function(_, val)
                    if val then
                        val = val:trim()
                    end

                    if val and not addon.Base64ParserPrototype:new():isBase64Encoded(val) then
                        db.profile.v1.options.import = val
                    else
                        db.profile.v1.options.import = nil
                    end

                    addon:SendMessage(addon.EVENTS.IMPORT_LOADED, import:import(val))
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

local function lookAndFeelGroup()
    return {
        name = "Look and Feel",
        type = "group",
        order = 6,
        args = {}
    }
end

local function optionsTable(db, utils, import, encounters)
    return {
        name = "Anti Raid Tools " .. addon.VERSION,
        type = "group",
        childGroups = "tab",
        args =  {
            discordButton = {
                type = "execute",
                name = "Join Discord",
                order = 1,
                func = function()
                    addon.url = "https://discord.gg/antiraidtools"
                    _G.StaticPopup_Show("ART_Link")
                    addon.url = nil
                end
            },
            toggleAnchorsButton = {
                type = "execute",
                name = "Toggle Anchors",
                func = function()
                    if not InCombatLockdown() then
                        -- TODO
                    end
                end,
                order = 2,
            },
            toggleTestModeButton = {
                type = "execute",
                name = "Toggle Test Mode",
                func = function()
                    if not InCombatLockdown() then
                        -- TODO
                    end
                end,
                order = 3,
            },
            packsGroup = packsGroup(db, utils, encounters),
            importGroup = importGroup(db, utils, import),
            lookAndFeelGroup = lookAndFeelGroup(),
            profileGroup = LibStub("AceDBOptions-3.0"):GetOptionsTable(db)
        }
    }
end

function Options:new(utils, import, db, encounters)
    local instance = setmetatable({}, self)

    self.utils = utils or addon.UtilsPrototype:new()
    self.import = import or addon.ImportPrototype:new()
    self.db = assert(db)
    self.encounters = assert(encounters)
    
    AceConfigRegistry:RegisterOptionsTable("AntiRaidTools", function() return optionsTable(self.db, self.utils, self.import, self.encounters) end)
    AceConfigDialog:AddToBlizOptions("AntiRaidTools", "Anti Raid Tools")

    return instance
end

function Options:notifyChange()
    AceConfigRegistry:NotifyChange("AntiRaidTools")
end
