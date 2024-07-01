local AntiRaidTools = AntiRaidTools

-- seconds
local ENCOUNTERS_SEND_WAIT_TIME = 45

local lastEncountersSendTime = 0
local encountersSendTimer = nil

function AntiRaidTools:SyncEncountersScheduleSend()
    if IsEncounterInProgress() then
        return
    end

    if self:IsPlayerRaidLeader() then
        if not encountersSendTimer then
            local timeSinceLastSend = GetTime() - lastEncountersSendTime
            local waitTime = math.max(0, ENCOUNTERS_SEND_WAIT_TIME - timeSinceLastSend)

            encountersSendTimer = C_Timer.NewTimer(waitTime, function()
                encountersSendTimer = nil
                lastEncountersSendTime = GetTime()

                local data = {
                    encountersId = AntiRaidTools.db.profile.data.encountersId,
                    encounters = AntiRaidTools.db.profile.data.encounters
                }

                AntiRaidTools:SendRaidMessage("ENCOUNTERS", data, self.PREFIX_SYNC, "BULK", function(_, sent, total)
                    local progress = sent / 100

                    local progressData = {
                        encountersId = data.encountersId,
                        progress = progress,
                    }

                    AntiRaidTools:SendRaidMessage("ENCOUNTERS_SYNC_PROGRESS", progressData, self.PREFIX_SYNC_PROGRESS)
                end)
            end)
        end
    end
end

function AntiRaidTools:SyncEncountersSendCurrentId()
    if IsEncounterInProgress() then
        return
    end

    if not self:IsPlayerRaidLeader() then
        self:SendRaidMessage("ENCOUNTERS_ID", self.db.profile.data.encountersId, self.PREFIX_SYNC)
    end
end

function AntiRaidTools:SyncEncountersHandleEncountersId(id)
    if IsEncounterInProgress() then
        return
    end

    if self:IsPlayerRaidLeader() then
        if self.db.profile.data.encountersId ~= id then
            self:SyncEncountersScheduleSend()
        end
    end
end
