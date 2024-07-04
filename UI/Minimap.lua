local AntiRaidTools = AntiRaidTools

local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LDI = LibStub:GetLibrary("LibDBIcon-1.0")

function AntiRaidTools:InitMinimap()
    local broker = LDB:NewDataObject("AntiRaidTools", {
        type = "data source",
        text = "AntiRaidTools",
        icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
        OnClick = function(self, button)
            if button == "LeftButton" then
                InterfaceOptionsFrame_OpenToCategory("Anti Raid Tools")
            else
                if IsShiftKeyDown() then
                    AntiRaidTools:RaidNotificationsToggleFrameLock()
                else
                    AntiRaidTools.db.profile.overview.show = not AntiRaidTools.db.profile.overview.show
                    AntiRaidTools:UpdateOverview()
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Anti Raid Tools")
            tooltip:AddLine("Left click to open Configuration")
            tooltip:AddLine("Right click to toggle Overview Visibility")
            tooltip:AddLine("Shift + Right click to toggle Anchors")
        end,
    })
    
    LDI:Register("AntiRaidTools", broker, self.db.profile.minimap)
end
