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
        minimap = {},
        overview = {
            selectedEncounterId = nil,
            show = true
        }
    },
}

function AntiRaidTools:OnInitialize()
    self:InitDB() 
    self:InitOptions()
    self:InitMinimap()
    self:InitOverview()
end

function AntiRaidTools:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    self:RegisterMessage("ART_WA_EVENT")

    self:RegisterChatCommand("art", "HandleChatCommand")
end

function AntiRaidTools:OnDisable()
    self:UnregisterEvent("PLAYER_LOGIN")
    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    self:UnregisterMessage("ART_WA_EVENT")

    self:UnregisterChatCommand("art")
end

function AntiRaidTools:InitDB()
    self.db = LibStub("AceDB-3.0"):New("AntiRaidTools", self.defaults)
end

function AntiRaidTools:PLAYER_LOGIN(event, isInitialLogin, isReloadingUi)
    self:InitEncounters()
    self:UpdateOverview()
end

function AntiRaidTools:ENCOUNTER_START(encounterId)
    self:OverviewSelectEncounter(encounterId)
    self:RaidCooldownsStartEncounter(encounterId)
end

function AntiRaidTools:ENCOUNTER_END()
    self:RaidCooldownsEndEncounter()
    self:ResetCooldowns()
end

function AntiRaidTools:COMBAT_LOG_EVENT_UNFILTERED()
    local inInstance, instanceType = IsInInstance()

    if inInstance and instanceType == "raid" then
        local _, subEvent, _,_, sourceName, _, _,_, destName, _, _,spellId = CombatLogGetCurrentEventInfo()
        self:HandleCombatLog(subEvent, sourceName, destName, spellId)
    end
end

function AntiRaidTools:HandleCombatLog(subEvent, sourceName, destName, spellId)
    if subEvent == "SPELL_CAST_START" or subEvent == "SPELL_CAST_SUCCESS" then
        self:RegisterSpellCast(sourceName, spellId)
    end
end

function AntiRaidTools:ART_WA_EVENT(event, ...)
    --TODO
end
