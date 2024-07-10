local AntiRaidTools = AntiRaidTools

local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LDI = LibStub:GetLibrary("LibDBIcon-1.0")

function AntiRaidTools:MinimapInit()
    local broker = LDB:NewDataObject("AntiRaidTools", {
        type = "data source",
        text = "AntiRaidTools",
        icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
        OnClick = function(self, button)
            if button == "LeftButton" then
                InterfaceOptionsFrame_OpenToCategory("Anti Raid Tools")
            else
                if IsShiftKeyDown() then
                    AntiRaidTools:NotificationsToggleFrameLock()
                else
                    AntiRaidTools.db.profile.overview.show = not AntiRaidTools.db.profile.overview.show
                    AntiRaidTools:OverviewUpdate()
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Anti Raid Tools")
            tooltip:AddLine("|cFFFFFFFFleft click|r to open configuration")
            tooltip:AddLine("|cFFFFFFFFright click|r to toggle overview visibility")
            tooltip:AddLine("|cFFFFFFFFshift + right click|r to show/hide anchors")
        end,
    })
    
    LDI:Register("AntiRaidTools", broker, self.db.profile.minimap)
end
