AntiRaidTools = LibStub("AceAddon-3.0"):NewAddon("AntiRaidTools", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

local ADDON_PREFIX = "AntiRaidTools"

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

    self:RegisterComm(ADDON_PREFIX)
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
end

function AntiRaidTools:SendRaidMessage(event, data)
    if IsInRaid() then
        local payload = {
            event = event,
            data = data,
        }

        self:SendCommMessage(ADDON_PREFIX, self:Serialize(payload), "RAID")
    end
end

function AntiRaidTools:OnCommReceived(prefix, message, _, sender)
    if prefix == ADDON_PREFIX then
        local ok, payload = self:Deserialize(message)
        if ok then
            if payload.event == "ENCOUNTERS" then
                if sender ~= UnitName("player") then
                    -- For encounter events we don't need to handle messages sent by ourselves
                    self:InitEncounters()
                    self.db.profile.data.encounters = payload.data
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
    end
end

function AntiRaidTools:ENCOUNTER_START(encounterId)
    self:OverviewSelectEncounter(encounterId)
    self:RaidAssignmentsStartEncounter(encounterId)
end

function AntiRaidTools:ENCOUNTER_END()
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

    if self:IsPlayerRaidLeader() then
        self:SendRaidMessage("ENCOUNTERS", self.db.profile.data.encounters)
    end
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
