
local addonName, addon = ...

local insert = table.insert

local SharedMedia = LibStub("LibSharedMedia-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

addon.OptionsPrototype = {}

local Options = addon.OptionsPrototype
Options.__index = Options

_G.StaticPopupDialogs["ART_LINK"] = {
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

_G.StaticPopupDialogs["ART_DELETE_PACK"] = {
    text = "Are you sure you want to delete this pack?",
    button1 = _G.YES,
    button2 = _G.NO,
    OnShow = function(self)
        self.packId = addon.packId
    end,
    OnHide = function(self)
        self.packId = nil
    end,
    OnAccept = function(self)
        if self.packId then
            addon.db.profile.v1.packs[self.packId] = nil
            addon.options:NotifyChange()
        end
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
}

local listedPackTypes = {
    ["TIMER"] = "Timers",
    ["STATE"] = "State",
    ["EVENT"] = "Events",
    ["RAID_FRAME_ICON"] = "Raid Frame Icons",
    ["SOUND"] = "Sounds"
}

function Options:PackArgs(pack)
    local headerTexture = (pack.options and pack.options.headerTexture) or "interface/questionframe/warboardzonescata"
    local headreTextureCords = (pack.options and pack.options.headerTexCords) or { 0.0009765625, 0.2626953125, 0.001953125, 0.240234375 }

    local args = {
        header = {
            type = "header",
            dialogControl = "AntiRaidToolsPackHeader",
            width = "full",
            name = pack.name,
            order = 1,
            arg = {
                header = pack.name,
                version = pack.packVersion,
                headerTexture = headerTexture,
                headerTexCords = headreTextureCords,
                author = pack.author
            }
        },
        enabled = {
            type = "toggle",
            name = "Enabled",
            order = 2,
            get = function()
                return self.db.profile.v1.packOptions[pack.id].enabled
            end,
            set = function(_, val)
                self.db.profile.v1.packOptions[pack.id].enabled = val
            end
        },
    }

    local order = 3

    if pack.options then
        for groupIndex, group in ipairs(pack.options.groups) do
            args["group:" .. groupIndex] = {
                type = "header",
                width = "full",
                name = group.header,
                order = order
            }
    
            order = order + 1
    
            for itemIndex, item in ipairs(group.items) do
                if item.type == "TOGGLE" then
                    args["item:" .. item.id] = {
                        type = "toggle",
                        width = "full",
                        name = item.name,
                        order = order,
                        get = function()
                            return self.db.profile.v1.packOptions[pack.id]["id:" .. item.id]
                        end,
                        set = function(_, val)
                            self.db.profile.v1.packOptions[pack.id]["id:" .. item.id] = val
                        end
                    }
    
                    order = order + 1
    
                    args["itemDesc:" .. item.id] = {
                        type = "description",
                        width = "full",
                        name = item.description,
                        order = order
                    }
                end
    
                order = order + 1
            end
        end
    end

    args["danger"] = {
        type = "header",
        width = "full",
        name = "Danger",
        order = order
    }

    order = order + 1

    args["delete"] = {
        type = "execute",
        name = "Delete Pack",
        order = order,
        func = function()
            addon.packId = pack.id
            _G.StaticPopup_Show("ART_DELETE_PACK")
            addon.packId = nil
        end
    }

    return args
end

function Options:PacksGroup()
    local group = {
        name = "Packs",
        type = "group",
        order = 4,
        childGroups = "tree",
        args = {}
    }

    local order = 1

    for _, pack in pairs(self.db.profile.v1.packs) do
        group.args["pack:" .. pack.id] = {
            type = "group",
            name = pack.name,
            order = order,
            args = self:PackArgs(pack)
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

function Options:ImportGroup()
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
                get = function() return self.db.profile.v1.options.import end,
                set = function(_, val)
                    if val then
                        val = val:trim()
                    end

                    if val and not addon.Base64ParserPrototype:New():IsBase64Encoded(val) then
                        self.db.profile.v1.options.import = val
                    else
                        self.db.profile.v1.options.import = nil
                    end

                    local pack = self.import:Import(val)[1]

                    self.db.profile.v1.packs[pack.id] = pack

                    local packOptions = self.db.profile.v1.packOptions[pack.id]
                    
                    if not packOptions then
                        self.db.profile.v1.packOptions[pack.id] = {}
                    end

                    self.db.profile.v1.packOptions[pack.id].enabled = true
                
                    if pack.options then
                        for _, group in ipairs(pack.options.groups) do
                            for _, item in ipairs(group.items) do
                                if self.db.profile.v1.packOptions[pack.id]["id:" .. item.id] == nil then
                                    self.db.profile.v1.packOptions[pack.id]["id:" .. item.id] = item.default
                                end
                            end
                        end
                    end

                    self:NotifyChange()
                end,
                validate = function(_, val)            
                    if val then
                        val = val:trim()
                    end
                    
                    if not val or val == "" then
                        return true
                    end
            
                    local ok, result = pcall(function() return self.import:Import(val) end)
        
                    if not ok then
                        return self.utils:StripErrorFileAndLine(result)
                    end
            
                    return true
                end
            },
        },
    }
end

function Options:LookAndFeelGroup()
    return {
        name = "Look and Feel",
        type = "group",
        order = 6,
        args = {}
    }
end


function Options:OptionsTable()
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
                    _G.StaticPopup_Show("ART_LINK")
                    addon.url = nil
                end
            },
            toggleAnchorsButton = {
                type = "execute",
                name = "Toggle Frame Lock",
                func = function()
                    if not InCombatLockdown() then
                        addon:SendMessage(addon.MESSAGES.ART_TOGGLE_FRAME_LOCK) 
                    end
                end,
                order = 2,
            },
            -- toggleTestModeButton = {
            --     type = "execute",
            --     name = "Toggle Test Mode",
            --     func = function()
            --         if not InCombatLockdown() then
            --             -- TODO
            --         end
            --     end,
            --     order = 3,
            -- },
            packsGroup = self:PacksGroup(),
            importGroup = self:ImportGroup(),
            lookAndFeelGroup = self:LookAndFeelGroup(),
            profileGroup = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
        }
    }
end

function Options:New(db, utils, import)
    local instance = setmetatable({}, self)

    instance.utils = utils or addon.UtilsPrototype:New()
    instance.import = import or addon.ImportPrototype:New()
    instance.db = assert(db)
    
    AceConfigRegistry:RegisterOptionsTable("AntiRaidTools", function() return instance:OptionsTable() end)
    AceConfigDialog:AddToBlizOptions("AntiRaidTools", "Anti Raid Tools")

    return instance
end

function Options:NotifyChange()
    AceConfigRegistry:NotifyChange("AntiRaidTools")
end
