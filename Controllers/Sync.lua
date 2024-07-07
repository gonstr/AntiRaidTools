local insert = table.insert

local AntiRaidTools = AntiRaidTools

-- seconds
local SYNC_WAIT_TIME = 120

local lastSyncTime = 0
local syncTimer = nil

local clientVersions = {}

function AntiRaidTools:SyncSchedule()
    if IsEncounterInProgress() or not self:IsPlayerRaidLeader() then
        return
    end

    if not syncTimer then
        local timeSinceLastSync = GetTime() - lastSyncTime
        local waitTime = math.max(0, SYNC_WAIT_TIME - timeSinceLastSync)

        if self.DEBUG then print("[ART] Scheduling raid sync in", waitTime, "seconds") end

        syncTimer = C_Timer.NewTimer(waitTime, function()
            lastSyncTime = GetTime()

            local data = {

                encountersId = self.db.profile.data.encountersId,
                encounters = self.db.profile.data.encounters
            }

            if self.DEBUG then print("[ART] Sending raid sync") end

            AntiRaidTools:SendRaidMessage("SYNC", data, self.PREFIX_SYNC, "BULK", function(_, sent, total)
                if sent == total then
                    syncTimer = nil
                end

                local progressData = {
                    encountersId = data.encountersId,
                    progress = sent / total * 100,
                }

                AntiRaidTools:SendRaidMessage("SYNC_PROG", progressData, self.PREFIX_SYNC_PROGRESS)
            end)
        end)
    end
end

function AntiRaidTools:SyncReqVersions()
    self:SendRaidMessage("SYNC_REQ_VERSIONS", self.PREFIX_SYNC)
end

function AntiRaidTools:SyncSendVersion()
    -- Send empty message
    self:SendRaidMessage()
end

function AntiRaidTools:SyncSendStatus()
    if IsEncounterInProgress() or not IsInRaid() or self:IsPlayerRaidLeader() then
        return
    end

    local data = {
        encountersId = self.db.profile.data.encountersId,
    }

    self:SendRaidMessage("SYNC_STATUS", data, self.PREFIX_SYNC)
end

function AntiRaidTools:SyncHandleStatus(data)
    if IsEncounterInProgress() or not self:IsPlayerRaidLeader() then
        return
    end

    if self.db.profile.data.encountersId ~= data.encountersId then
        self:SyncSchedule()
    end
end

function AntiRaidTools:SyncSetClientVersion(player, version)
    clientVersions[player] = version
end

function AntiRaidTools:SyncGetClientVersions()
    local versions = {}

    for player, version in pairs(clientVersions) do
        if not versions[version] then
            versions[version] = {}
        end

        insert(versions[version], player)
    end

    return versions
end
