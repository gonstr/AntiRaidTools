AntiRaidTools = LibStub("AceAddon-3.0"):NewAddon("AntiRaidTools", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

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
            encountersProgress = nil,
            encountersId = nil,
            encounters = {}
        },
        minimap = {},
        overview = {
            selectedEncounterId = nil,
            locked = false,
            show = true
        }
    },
}

function AntiRaidTools:OnInitialize()
    self.DEBUG = false
    self.TEST = false

    self.PREFIX_SYNC = "ART-S"
    self.PREFIX_SYNC_PROGRESS = "ART-SP"
    self.PREFIX_MAIN = "ART-M"

    self.isInRaid = IsInRaid()

    self:InitDB() 
    self:InitOptions()
    self:InitMinimap()
    self:InitOverview()
    self:InitRaidNotification()

    self:RegisterComm(self.PREFIX_SYNC)
    self:RegisterComm(self.PREFIX_SYNC_PROGRESS)
    self:RegisterComm(self.PREFIX_MAIN)
end

function AntiRaidTools:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

    self:RegisterMessage("ART_WA_EVENT")

    self:RegisterChatCommand("art", "HandleChatCommand")
end

function AntiRaidTools:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:UnregisterEvent("UNIT_HEALTH")
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
    self:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")

    self:UnregisterMessage("ART_WA_EVENT")

    self:UnregisterChatCommand("art")
end

function AntiRaidTools:InitDB()
    self.db = LibStub("AceDB-3.0"):New("AntiRaidTools", self.defaults)
end

function AntiRaidTools:PLAYER_ENTERING_WORLD(_, isInitialLogin, isReloadingUi)
    if isInitialLogin or isReloadingUi then
        self:InitEncounters()
        self:SyncEncountersSendCurrentId()
        self:SyncEncountersScheduleSend()
    end

    self:UpdateOverview()
end

function AntiRaidTools:SendRaidMessage(event, data, prefix, prio, callbackFn)
    if IsInRaid() then
        local payload = {
            event = event,
            data = data,
        }

        if not prefix then
            prefix = self.PREFIX_MAIN
        end

        if not prio then
            prio = "NORMAL"
        end

        self:SendCommMessage(prefix, self:Serialize(payload), "RAID", nil, prio, callbackFn)
    end
end

function AntiRaidTools:OnCommReceived(prefix, message, _, sender)
    if prefix == self.PREFIX_MAIN or prefix == self.PREFIX_SYNC or prefix == self.PREFIX_SYNC_PROGRESS then
        local ok, payload = self:Deserialize(message)
        if ok then
            if payload.event == "ENCOUNTERS_ID" then
                if sender ~= UnitName("player") then
                    if self.DEBUG then print("[ART] Received message ENCOUNTERS_ID:", sender, payload.data) end
                    self:SyncEncountersHandleEncountersId(payload.data)
                end
            elseif payload.event == "ENCOUNTERS_SYNC_PROGRESS" then
                if sender ~= UnitName("player") and payload.data.encountersId ~= self.db.profile.data.encountersId then
                    if self.DEBUG then print("[ART] Received message ENCOUNTERS_SYNC_PROGRESS:", sender, payload.data.progress) end
                    self.db.profile.data.encountersProgress = payload.data.progress
                    self.db.profile.data.encountersId = nil
                    self.db.profile.data.encounters = {}
                    self:UpdateOverview()
                end
            elseif payload.event == "ENCOUNTERS" then
                if sender ~= UnitName("player") then
                    if self.DEBUG then print("[ART] Received message ENCOUNTERS") end
                    self.db.profile.data.encountersProgress = nil
                    self.db.profile.data.encountersId = payload.data.encountersId
                    self.db.profile.data.encounters = payload.data.encounters
                    self:UpdateOverview()
                end
            elseif payload.event == "ACTIVE_GROUPS" then
                if self.DEBUG then print("[ART] Received message ACTIVE_GROUPS") end
                self:SetAllActiveGroups(payload.data)
                self:UpdateOverviewActiveGroups()
            elseif payload.event == "SHOW_NOTIFICATION" then
                if self.DEBUG then print("[ART] Received message SHOW_NOTIFICATION") end
                self:RaidNotificationsShowRaidAssignment(payload.data.uuid, payload.data.countdown)
                self:UpdateNotificationSpells()
            end
        end
    end
end

function AntiRaidTools:ART_WA_EVENT(_, event, ...)
    if event == "WA_NUMEN_TIMER" then
        self:RaidAssignmentsHandleFojjiNumenTimer(...)
    end
end

function AntiRaidTools:ENCOUNTER_START(_, encounterId)
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

function AntiRaidTools:PLAYER_REGEN_ENABLED()
    -- This is just another way of registering an encounter ending
    if not UnitIsDeadOrGhost("player") then
        self:RaidAssignmentsEndEncounter()
        self:ResetSpellsCache()
        self:ResetDeadCache()
        self:UpdateOverviewSpells()
        self:UpdateNotificationSpells()
    end
end

function AntiRaidTools:UNIT_HEALTH(_, unitId)
    local guid = UnitGUID(unitId)

    if self:IsCachedUnitDead(guid) and UnitHealth(unitId) > 0 and not UnitIsGhost(unitId) then
        if self.DEBUG then print("[ART] Handling cached unit coming back to life") end
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

    if IsInRaid() and not self.IsInRaid then
        self.IsInRaid = IsInRaid()
        self:SyncEncountersSendCurrentId()
    end
end

function AntiRaidTools:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subEvent, _,_, sourceName, _, _, destGUID, destName, _, _,spellId = CombatLogGetCurrentEventInfo()
    self:HandleCombatLog(subEvent, sourceName, destGUID, destName, spellId)
end

function AntiRaidTools:CHAT_MSG_RAID_BOSS_EMOTE(_, text)
    self:RaidAssignmentsHandleRaidBossEmote(text)
end

function AntiRaidTools:CHAT_MSG_MONSTER_YELL(_, text)
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

        local spell = self:GetSpell(spellId)
        if spell then
            local AntiRaidTools = self
            C_Timer.NewTimer(spell.duration, function() AntiRaidTools:RaidAssignmentsUpdateGroups() end)
        end
    elseif subEvent == "UNIT_DIED" then
        if self:IsFriendlyRaidMemberOrPlayer(destGUID) then
            self:CacheUnitDied(destGUID)
            self:RaidAssignmentsUpdateGroups()
            self:UpdateOverviewSpells()
            self:UpdateNotificationSpells()
        end
    end
end
