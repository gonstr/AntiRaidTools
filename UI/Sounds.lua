local addonName, addon = ...

local insert = table.insert

local AceEvent = LibStub("AceEvent-3.0")

addon.SoundsPrototype = {}

local Sounds = addon.SoundsPrototype
Sounds.__index = Sounds

function Sounds:New(db)
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

function Sounds:Stop()
    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterMessage("ART_TRIGGER")
end

function Sounds:Reset()
    addon:Debug("Sounds:Reset")

    self.triggerCache = {}
end

function Sounds:ENCOUNTER_START(_, encounterId)
    addon:Debug("Sounds:ENCOUNTER_START", encounterId)

    self:Reset()

    -- Populate cache
    for _, pack in pairs(self.db.profile.v1.packs) do
        for _, item in ipairs(pack.items) do
            if item.type == "SOUND" and item.encounter == encounterId then
                if not self.triggerCache[item.trigger] then
                    self.triggerCache[item.trigger] = {}
                end

                insert(self.triggerCache[item.trigger], item)
            end
        end
    end
end

function Sounds:ENCOUNTER_END()
    addon:Debug("Sounds:ENCOUNTER_END")

    self:Reset()
end

function Sounds:ART_TRIGGER(_, trigger)
    addon:Debug("Sounds:ART_TRIGGER", trigger)

    local sounds = self.triggerCache[trigger.id]

    if sounds then
        for _, sound in ipairs(sounds) do
            if addon.utils:InterpolateIf(sound, trigger.ctx) then
                if not trigger.untrigger then
                    if sound.file then
                        PlaySoundFile(sound.file, "Master")
                    end
        
                    if sound.tts then
                        local voice = C_VoiceChat.GetTtsVoices()[2].voiceID
                        C_VoiceChat.SpeakText(voice, sound.tts, 1, 0, 100)
                    end
                end
            end
        end
    end
end
