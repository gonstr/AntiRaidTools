AntiRaidTools = LibStub("AceAddon-3.0"):NewAddon("AntiFrames", "AceConsole-3.0", "AceEvent-3.0")

function AntiRaidTools:OnInitialize()
    self:InitDB() 
    self:InitOptions()
end

function AntiRaidTools:OnEnable()
    self:RegisterEvent("ENCOUNTER_START")
end

function AntiRaidTools:OnDisable()
    self:UnregisterEvent("ENCOUNTER_START")
end

function AntiRaidTools:InitDB()
    self.db = LibStub("AceDB-3.0"):New("AntiRaidTools", self.defaults)
end

function AntiRaidTools:PLAYER_LOGIN(event, isInitialLogin, isReloadingUi)
    --self:Print("Anti Raid Tools loaded. open options with /art")
end

function AntiRaidTools:ENCOUNTER_START()
    self:ResetCooldowns()
end
