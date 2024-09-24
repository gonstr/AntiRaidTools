local addonName, addon = ...

local insert = table.insert

local AceEvent = LibStub("AceEvent-3.0")

addon.CommsPrototype = {}

local Comms = addon.CommsPrototype
Comms.__index = Comms

function Comms:New(db)
    local instance = setmetatable({}, self)

    instance.db = db

    AceEvent:Embed(instance)

    instance:RegisterEvent("ENCOUNTER_START")
    instance:RegisterEvent("ENCOUNTER_END")
    instance:RegisterMessage("ART_TRIGGER")

    instance.triggerCache = {}
    
    instance:Reset()

    return instance
end

function Comms:Reset()
    addon:Debug("Comms:Reset")

    self.triggerCache = {}
end

function Comms:Stop()
    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterMessage("ART_TRIGGER")
end

function Comms:ENCOUNTER_START(_, encounterId)
    addon:Debug("Comms:ENCOUNTER_START", encounterId)

    self:Reset()

    -- Populate cache
    for _, pack in pairs(self.db.profile.v1.packs) do
        for _, item in ipairs(pack.items) do
            if item.type == "COMM" and item.encounter == encounterId then
                if not self.triggerCache[item.trigger] then
                    self.triggerCache[item.trigger] = {}
                end

                insert(self.triggerCache[item.trigger], item)
            end
        end
    end
end

function Comms:ENCOUNTER_END()
    addon:Debug("Comms:ENCOUNTER_END")

    self:Reset()
end

function Comms:ART_TRIGGER(_, trigger)
    addon:Debug("Comms:ART_TRIGGER", trigger)

    -- Say and Yell are blocked outside of instances
    if IsInInstance() then
        local comms = self.triggerCache[trigger.id]

        if comms then
            for _, comm in ipairs(comms) do
                if addon.utils:InterpolateIf(comm, trigger.ctx) then
                    if not trigger.untrigger then
                        pcall(function() SendChatMessage(addon.utils:StringInterpolate(comm.text, trigger.ctx), comm.channel) end)
                    end
                end
            end
        end
    end
end
