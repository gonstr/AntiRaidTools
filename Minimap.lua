local AntiRaidTools = AntiRaidTools

local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LDI = LibStub:GetLibrary("LibDBIcon-1.0")

function AntiRaidTools:InitMinimap()
    local broker = LDB:NewDataObject("AntiRaidTools", {
        type = "data source",
        text = "AntiRaidTools",
        icon = "Interface\\Icons\\Spell_Nature_ElementalPrecision_1",
        OnClick = function(self, button)
            if button == "LeftButton" then
                AntiRaidTools.db.profile.overview.show = not AntiRaidTools.db.profile.overview.show
                AntiRaidTools:UpdateOverview()
            else
                InterfaceOptionsFrame_OpenToCategory("Anti Raid Tools")
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Anti Raid Tools")
            tooltip:AddLine("Left click to toggle visibility")
            tooltip:AddLine("Right click to open options")
        end,
    })
    
    LDI:Register("AntiRaidTools", broker, self.db.profile.minimap)
end
