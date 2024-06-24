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
    self:RegisterEvent("UNIT_HEALTH")

    self:RegisterChatCommand("art", "HandleChatCommand")
end

function AntiRaidTools:OnDisable()
    self:UnregisterEvent("PLAYER_LOGIN")
    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:UnregisterEvent("UNIT_HEALTH")

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
    self:ResetSpellsCache()
    self:ResetDeadCache()
    self:UpdateOverviewSpells()
end

function AntiRaidTools:UNIT_HEALTH(_, unitId)
    local guid = UnitGUID(unitId)

    if self:IsCachedUnitDead(guid) and UnitHealth(unitId) > 0 and not UnitIsGhost(unitId) then
        self:ClearCachedUnitDead(guid)
        self:RaidCooldownsProcessGroups()
        self:UpdateOverviewSpells()
    end
end

function AntiRaidTools:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subEvent, _,_, sourceName, _, _, destGUID, destName, _, _,spellId = CombatLogGetCurrentEventInfo()
    self:HandleCombatLog(subEvent, sourceName, destGUID, destName, spellId)
end

function AntiRaidTools:HandleCombatLog(subEvent, sourceName, destGUID, destName, spellId)
    if subEvent == "SPELL_CAST_SUCCESS" then
        self:CacheSpellCast(sourceName, spellId, function() self:UpdateOverviewSpells() end)
        self:RaidCooldownsProcessGroups()
    elseif subEvent == "UNIT_DIED" then
        if self:IsFriendlyRaidMemberOrPlayer(destGUID) then
            self:CacheUnitDied(destGUID)
            self:RaidCooldownsProcessGroups()
            self:UpdateOverviewSpells()
        end
    end
end
