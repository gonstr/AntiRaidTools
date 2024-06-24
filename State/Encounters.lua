local AntiRaidTools = AntiRaidTools
local insert = table.insert

local encounters = {}

function AntiRaidTools:InitEncounters()
    local instance_index = 1
    local instance_id = EJ_GetInstanceByIndex(instance_index, true)

    while instance_id do
        EJ_SelectInstance(instance_id)
        local instance_name, _, _, _, _, _, dungeonAreaMapID = EJ_GetInstanceInfo(instance_id)

        local ej_index = 1
        local boss, _, _, _, _, _, encounter_id = EJ_GetEncounterInfoByIndex(ej_index, instance_id)

        while boss do
            encounters[encounter_id] = boss

            ej_index = ej_index + 1
            boss, _, _, _, _, _, encounter_id = EJ_GetEncounterInfoByIndex(ej_index, instance_id)
        end

        instance_index = instance_index + 1
        instance_id = EJ_GetInstanceByIndex(instance_index, true)
    end
end

function AntiRaidTools:GetEncounters()
    return encounters
end

function AntiRaidTools:EncounterExists(encounterId)
    return encounters[encounterId] and true or false
end