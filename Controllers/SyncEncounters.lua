local AntiRaidTools = AntiRaidTools

-- seconds
local ENCOUNTERS_SEND_WAIT_TIME = 120

local lastEncountersSendTime = 0
local encountersSendTimer = nil

function AntiRaidTools:SyncEncountersScheduleSend()
    if IsEncounterInProgress() or not self:IsPlayerRaidLeader() then
        return
    end

    if not encountersSendTimer then
        local timeSinceLastSend = GetTime() - lastEncountersSendTime
        local waitTime = math.max(0, ENCOUNTERS_SEND_WAIT_TIME - timeSinceLastSend)

        print("[ART] Scheduling Raid Sync in", waitTime, "seconds")

        encountersSendTimer = C_Timer.NewTimer(waitTime, function()
            lastEncountersSendTime = GetTime()

            local data = {
                encountersId = AntiRaidTools.db.profile.data.encountersId,
                encounters = AntiRaidTools.db.profile.data.encounters
            }

            print("[ART] Sending Raid Encounters to Raid...")

            AntiRaidTools:SendRaidMessage("ENCOUNTERS", data, self.PREFIX_SYNC, "BULK", function(_, sent, total)
                if sent == total then
                    encountersSendTimer = nil
                end

                local progressData = {
                    encountersId = data.encountersId,
                    progress = sent / total * 100,
                }

                AntiRaidTools:SendRaidMessage("ENCOUNTERS_SYNC_PROGRESS", progressData, self.PREFIX_SYNC_PROGRESS)
            end)
        end)
    end
end

function AntiRaidTools:SyncEncountersSendCurrentId()
    if IsEncounterInProgress() or not IsInRaid() or self:IsPlayerRaidLeader() then
        return
    end

    self:SendRaidMessage("ENCOUNTERS_ID", self.db.profile.data.encountersId, self.PREFIX_SYNC)
end

function AntiRaidTools:SyncEncountersHandleEncountersId(id)
    if IsEncounterInProgress() or not self:IsPlayerRaidLeader() then
        return
    end

    if self.db.profile.data.encountersId ~= id then
        self:SyncEncountersScheduleSend()
    end
end
