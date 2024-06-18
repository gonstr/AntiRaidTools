AntiRaidTools = LibStub("AceAddon-3.0"):NewAddon("AntiRaidTools", "AceConsole-3.0", "AceEvent-3.0")

-- AceDB defaults
AntiRaidTools.defaults = {
    profile = {
        options = {
            import = ""
        },
        data = {
            encounters = {}
        },
        overview = {
            selectedEncounterId = nil
        }
    },
}

function AntiRaidTools:OnInitialize()
    self:InitDB() 
    self:InitOptions()
    self:InitOverview()
end

function AntiRaidTools:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("ENCOUNTER_START")

    self:RegisterMessage("ART_WA_EVENT")
end

function AntiRaidTools:OnDisable()
    self:UnregisterEvent("PLAYER_LOGIN")
    self:UnregisterEvent("ENCOUNTER_START")

    self:UnregisterMessage("ART_WA_EVENT")
end

function AntiRaidTools:InitDB()
    self.db = LibStub("AceDB-3.0"):New("AntiRaidTools", self.defaults)
end

function AntiRaidTools:PLAYER_LOGIN(event, isInitialLogin, isReloadingUi)
    self:InitEncounters()
    self:UpdateOverview()
    --self:Print("Anti Raid Tools loaded. open options with /art")
end

function AntiRaidTools:ENCOUNTER_START()
    self:ResetCooldowns()
end

function AntiRaidTools:ART_WA_EVENT(event, ...)
    --TODO
end

function AntiRaidTools:OnImport()
    self:UpdateOverview()
end

function AntiRaidTools:OnOverviewSelectedEncounter()
    self:UpdateOverviewHeaderText()
end
