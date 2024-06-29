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
                    id = AntiRaidTools.db.profile.data.encountersId,
                    encounters = AntiRaidTools.db.profile.data.encounters
                }

                AntiRaidTools:SendRaidMessage("ENCOUNTERS", data, true)
            end)
        end
    end
end

function AntiRaidTools:SyncEncountersSendCurrentId()
    if IsEncounterInProgress() then
        return
    end

    if not self:IsPlayerRaidLeader() then
        self:SendRaidMessage("ENCOUNTERS_ID", self.db.profile.data.encounterId, true)
    end
end

function AntiRaidTools:SyncEncountersHandleEncountersId(id)
    if IsEncounterInProgress() then
        return
    end

    if self:IsPlayerRaidLeader() then
        if self.db.profile.data.encounterId ~= id then
            self:SyncEncountersScheduleSend()
        end
    end
end
