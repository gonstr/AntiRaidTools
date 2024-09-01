local addonName, addon = ...

local LibDataBroker = LibStub:GetLibrary("LibDataBroker-1.1")
local LibDBIcon = LibStub:GetLibrary("LibDBIcon-1.0")

addon.MinimapPrototype = {}

local Minimap = addon.MinimapPrototype
Minimap.__index = Minimap

function Minimap:New(db)
    local instance = setmetatable({}, self)

    instance.broker = LibDataBroker:NewDataObject("AntiRaidTools", {
        type = "data source",
        text = "AntiRaidTools",
        icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
        OnClick = function(_, button)
            if button == "LeftButton" then
                InterfaceOptionsFrame_OpenToCategory("Anti Raid Tools")
            else
                addon:SendMessage(addon.MESSAGES.ART_TOGGLE_FRAME_LOCK) 
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Anti Raid Tools")
            tooltip:AddLine("|cFFFFFFFFleft click|r to open configuration")
            tooltip:AddLine("|cFFFFFFFFright click|r to toggle frame lock")
        end,
    })
    
    LibDBIcon:Register("AntiRaidTools", instance.broker, db.profile.v1.minimap)

    return instance
end
