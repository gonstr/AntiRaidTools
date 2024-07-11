AntiRaidTools = LibStub("AceAddon-3.0"):NewAddon("AntiRaidTools", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

AntiRaidTools.DEBUG = false
AntiRaidTools.TEST = false

AntiRaidTools.PREFIX_SYNC = "ART-S"
AntiRaidTools.PREFIX_SYNC_PROGRESS = "ART-SP"
AntiRaidTools.PREFIX_MAIN = "ART-M"

AntiRaidTools.VERSION = GetAddOnMetadata("AntiRaidTools", "Version")
AntiRaidTools.IS_DEV = AntiRaidTools.VERSION == '\@project-version\@'

-- AceDB defaults
AntiRaidTools.defaults = {
    profile = {
        options = {
            import = "",
            notifications = {
                showOnlyOwnNotifications = false,
                mute = false
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
    self:DBInit() 
    self:OptionsInit()
    self:MinimapInit()
    self:OverviewInit()
    self:NotificationsInit()

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

    self:RegisterChatCommand("art", "ChatHandleCommand")
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

function AntiRaidTools:DBInit()
    self.db = LibStub("AceDB-3.0"):New("AntiRaidTools", self.defaults)
end

function AntiRaidTools:PLAYER_ENTERING_WORLD(_, isInitialLogin, isReloadingUi)
    if isInitialLogin or isReloadingUi then
        self:EncountersInit()
        self:SyncSendStatus()
        self:SyncSchedule()
    end

    self:OverviewUpdate()
end

function AntiRaidTools:SendRaidMessage(event, data, prefix, prio, callbackFn)
    if IsInRaid() then
        local payload = {
            v = self.VERSION,
            e = event,
            d = data,
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
            self:SyncSetClientVersion(sender, payload.v)

            if payload.e == "SYNC_REQ_VERSIONS" then
                if self.DEBUG then print("[ART] Received message SYNC_REQ_VERSIONS:", sender) end
                self:SyncSendVersion()
            elseif payload.e == "SYNC_STATUS" then
                if sender ~= UnitName("player") then
                    if self.DEBUG then print("[ART] Received message SYNC_STATUS:", sender) end
                    self:SyncHandleStatus(payload.d)
                end
            elseif payload.e == "SYNC_PROG" then
                if sender ~= UnitName("player") and payload.d.encountersId ~= self.db.profile.data.encountersId then
                    if self.DEBUG then print("[ART] Received message SYNC_PROG:", sender, payload.d.progress) end
                    self.db.profile.data.encountersProgress = payload.d.progress
                    self.db.profile.data.encountersId = nil
                    self.db.profile.data.encounters = {}
                    self:OverviewUpdate()
                end
            elseif payload.e == "SYNC" then
                if sender ~= UnitName("player") then
                    if self.DEBUG then print("[ART] Received message SYNC") end
                    self.db.profile.data.encountersProgress = nil
                    self.db.profile.data.encountersId = payload.d.encountersId
                    self.db.profile.data.encounters = payload.d.encounters
                    self:OverviewUpdate()
                end
            elseif payload.e == "ACT_GRPS" then
                if self.DEBUG then print("[ART] Received message ACT_GRPS") end
                self:GroupsSetAllActive(payload.d)
                self:OverviewUpdateActiveGroups()
            elseif payload.e == "TRIGGER" then
                if self.DEBUG then print("[ART] Received message TRIGGER") end
                self:TriggersSetTriggered(payload.d.uuid, payload.d.countdown)
                self:NotificationsUpdate()
            elseif payload.e == "UNTRIGGER" then
                if self.DEBUG then print("[ART] Received message UNTRIGGER") end
                self:TriggersSetUntriggered(payload.d.uuid, payload.d.countdown)
                self:NotificationsUpdate()
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
    self:SpellsResetCache()
    self:UnitsResetDeadCache()
    self:OverviewUpdateSpells()
    self:NotificationsUpdateSpells()
end

function AntiRaidTools:PLAYER_REGEN_ENABLED()
    -- This is just another way of registering an encounter ending
    if not UnitIsDeadOrGhost("player") then
        self:RaidAssignmentsEndEncounter()
        self:SpellsResetCache()
        self:UnitsResetDeadCache()
        self:OverviewUpdateSpells()
        self:NotificationsUpdateSpells()
    end
end

function AntiRaidTools:UNIT_HEALTH(_, unitId)
    local guid = UnitGUID(unitId)

    if self:UnitsIsDead(guid) and UnitHealth(unitId) > 0 and not UnitIsGhost(unitId) then
        if self.DEBUG then print("[ART] Handling cached unit coming back to life") end
        self:UnitsClearDead(guid)
        self:RaidAssignmentsUpdateGroups()
        self:OverviewUpdateSpells()
        self:NotificationsUpdateSpells()
    end

    self:RaidAssignmentsHandleUnitHealth(unitId)
end

function AntiRaidTools:GROUP_ROSTER_UPDATE()
    self:OverviewUpdateSpells()
    self:NotificationsUpdateSpells()

    if IsInRaid() and not self.sentRaidSync then
        self.sentRaidSync = true
        self:SyncSendStatus()
    else
        self.sentRaidSync = false
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
        self:SpellsCacheCast(sourceName, spellId, function()
            self:OverviewUpdateSpells()
            self:NotificationsUpdateSpells()
        end)
        self:RaidAssignmentsHandleSpellCast(subEvent, spellId)
        self:RaidAssignmentsUpdateGroups()

        local spell = self:SpellsGetSpell(spellId)
        if spell then
            local AntiRaidTools = self
            C_Timer.NewTimer(spell.duration, function() AntiRaidTools:RaidAssignmentsUpdateGroups() end)
        end
    elseif subEvent == "SPELL_AURA_APPLIED" then
        self:RaidAssignmentsHandleSpellAura(subEvent, spellId)
    elseif subEvent == "UNIT_DIED" then
        if self:IsFriendlyRaidMemberOrPlayer(destGUID) then
            self:UnitsSetDead(destGUID)
            self:RaidAssignmentsUpdateGroups()
            self:OverviewUpdateSpells()
            self:NotificationsUpdateSpells()
        end
    end
end
