AntiRaidTools = LibStub("AceAddon-3.0"):NewAddon("AntiRaidTools", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

local ADDON_PREFIX_SYNC = "ART-S"
local ADDON_PREFIX_MAIN = "ART-M"

-- AceDB defaults
AntiRaidTools.defaults = {
    profile = {
        options = {
            import = "",
            notifications = {
                showOnlyOwnNotifications = false
            }
        },
        data = {
            encountersId = nil,
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
    self:InitRaidNotification()

    self:RegisterComm(ADDON_PREFIX_SYNC)
    self:RegisterComm(ADDON_PREFIX_MAIN)
end

function AntiRaidTools:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("RAID_BOSS_EMOTE")

    self:RegisterMessage("ART_WA_EVENT")

    self:RegisterChatCommand("art", "HandleChatCommand")
end

function AntiRaidTools:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:UnregisterEvent("UNIT_HEALTH")
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
    self:UnregisterEvent("RAID_BOSS_EMOTE")

    self:UnregisterMessage("ART_WA_EVENT")

    self:UnregisterChatCommand("art")
end

function AntiRaidTools:InitDB()
    self.db = LibStub("AceDB-3.0"):New("AntiRaidTools", self.defaults)
end

function AntiRaidTools:PLAYER_ENTERING_WORLD()
    self:InitEncounters()
    self:UpdateOverview()
    self:SyncEncountersSendCurrentId()
    self:SyncEncountersScheduleSend()
end

function AntiRaidTools:SendRaidMessage(event, data, sync)
    if IsInRaid() then
        local payload = {
            event = event,
            data = data,
        }

        local prefix = ADDON_PREFIX_MAIN
        local prio = "NORMAL"

        if sync then
            prefix = ADDON_PREFIX_SYNC
            prio = "BULK"
        end

        self:SendCommMessage(prefix, self:Serialize(payload), "RAID", nil, prio)
    end
end

function AntiRaidTools:OnCommReceived(prefix, message, _, sender)
    if prefix == ADDON_PREFIX_MAIN or prefix == ADDON_PREFIX_SYNC then
        local ok, payload = self:Deserialize(message)
        if ok then
            if payload.event == "ENCOUNTERS_ID" then
                if sender ~= UnitName("player") then
                    self:SyncEncountersHandleEncountersId(payload.data)
                end
            elseif payload.event == "ENCOUNTERS" then
                if sender ~= UnitName("player") then
                    self:InitEncounters()
                    self.db.profile.data.encounterId = payload.data.id
                    self.db.profile.data.encounters = payload.data.encounters
                    self:UpdateOverview()
                end
            elseif payload.event == "ACTIVE_GROUPS" then
                self:SetAllActiveGroups(payload.data)
                self:UpdateOverviewActiveGroups()
            elseif payload.event == "SHOW_NOTIFICATION" then
                self:RaidNotificationsShowRaidAssignment(payload.data.uuid, payload.data.countdown)
                self:UpdateNotificationSpells()
            end
        end
    end
end

function AntiRaidTools:ART_WA_EVENT(event, waEvent, ...)
    if waEvent == "WA_NUMEN_TIMER" then
        self:RaidAssignmentsHandleFojjiNumenTimer(...)
        self:RaidAssignmentsUpdateGroups()
    end
end

function AntiRaidTools:ENCOUNTER_START(encounterId)
    self:OverviewSelectEncounter(encounterId)
    self:OverviewSetLocked(true)
    self:RaidAssignmentsStartEncounter(encounterId)
end

function AntiRaidTools:ENCOUNTER_END()
    self:OverviewSetLocked(false)
    self:RaidAssignmentsEndEncounter()
    self:ResetSpellsCache()
    self:ResetDeadCache()
    self:UpdateOverviewSpells()
    self:UpdateNotificationSpells()
end

function AntiRaidTools:UNIT_HEALTH(_, unitId)
    local guid = UnitGUID(unitId)

    if self:IsCachedUnitDead(guid) and UnitHealth(unitId) > 0 and not UnitIsGhost(unitId) then
        self:ClearCachedUnitDead(guid)
        self:RaidAssignmentsUpdateGroups()
        self:UpdateOverviewSpells()
        self:UpdateNotificationSpells()
    end

    self:RaidAssignmentsHandleUnitHealth(unitId)
end

function AntiRaidTools:GROUP_ROSTER_UPDATE()
    self:UpdateOverviewSpells()
    self:UpdateNotificationSpells()
    self:SyncEncountersSendCurrentId()
end

function AntiRaidTools:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subEvent, _,_, sourceName, _, _, destGUID, destName, _, _,spellId = CombatLogGetCurrentEventInfo()
    self:HandleCombatLog(subEvent, sourceName, destGUID, destName, spellId)
end

function AntiRaidTools:RAID_BOSS_EMOTE(_, text)
    self:RaidAssignmentsHandleRaidBossEmote(text)
end

function AntiRaidTools:HandleCombatLog(subEvent, sourceName, destGUID, destName, spellId)
    if subEvent == "SPELL_CAST_START" then
        self:RaidAssignmentsHandleSpellCast(subEvent, spellId)
    elseif subEvent == "SPELL_CAST_SUCCESS" then
        self:CacheSpellCast(sourceName, spellId, function()
            self:UpdateOverviewSpells()
            self:UpdateNotificationSpells()
        end)
        self:RaidAssignmentsHandleSpellCast(subEvent, spellId)
        self:RaidAssignmentsUpdateGroups()
    elseif subEvent == "UNIT_DIED" then
        if self:IsFriendlyRaidMemberOrPlayer(destGUID) then
            self:CacheUnitDied(destGUID)
            self:RaidAssignmentsUpdateGroups()
            self:UpdateOverviewSpells()
            self:UpdateNotificationSpells()
        end
    end
end
