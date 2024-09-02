local addonName, addon = ...

local insert = table.insert
local remove = table.remove

local AceEvent = LibStub("AceEvent-3.0")

addon.EventsFramePrototype = {}

local EventsFrame = addon.EventsFramePrototype
EventsFrame.__index = EventsFrame

function EventsFrame:New()
    local instance = setmetatable({}, self)

    AceEvent:Embed(instance)

    instance.frame = CreateFrame("Frame", nil, UIParent)
    instance.frame:Hide()

    instance:Reset()

    return instance
end

function EventsFrame:SetData(db, frameFactory)
    self.db = db
    self.frameFactory = frameFactory
end

function EventsFrame:GetFrame()
    return self.frame
end

function EventsFrame:OnAcquire()
    addon:Debug("EventsFrame:OnAcquire")

    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
    self:RegisterMessage("ART_TRIGGER")

    self.frame:Show()
end

function EventsFrame:OnRelease()
    addon:Debug("EventsFrame:OnRelease")

    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterMessage("ART_TRIGGER")

    self.frame:Hide()
end

function EventsFrame:Reset()
    addon:Debug("EventsFrame:Reset")

    self.eventsCache = {}

    if not self.eventFrames then
        self.eventFrames = {}
    end

    for i, event in ipairs(self.eventFrames) do
        event.frame:Release()
        self.eventFrames[i] = nil
    end
end

function EventsFrame:Update()
    addon:Debug("EventsFrame:Update")

    self:ReleaseEvents()
    self:DoLayout()
end

function EventsFrame:ReleaseEvents()
    addon:Debug("EventsFrame:ReleaseEvents")

    for i, event in ipairs(self.eventFrames) do
        if event.expirationTime <= GetTime() then
            event.frame:Release()
            remove(self.eventFrames, i)
        end
    end
end

function EventsFrame:DoLayout()
    addon:Debug("EventsFrame:DoLayout")

    local totalFrames = #self.eventFrames

    for i, event in ipairs(self.eventFrames) do
        local ofsy = (totalFrames - i) * event.frame:GetFrame():GetHeight() + (totalFrames - i) * 5
        event.frame:GetFrame():SetPoint("BOTTOM", self.frame, "BOTTOM", 0, ofsy)
    end
end

function EventsFrame:ENCOUNTER_START(_, encounterId)
    addon:Debug("EventsFrame:ENCOUNTER_START", encounterId)

    self:Reset()

    -- Populate events cache
    for _, pack in pairs(self.db.profile.v1.packs) do
        for _, item in ipairs(pack.items) do
            if item.type == "EVENT" and item.encounter == encounterId then
                if not self.eventsCache[item.trigger] then
                    self.eventsCache[item.trigger] = {}
                end

                insert(self.eventsCache[item.trigger], item)
            end
        end
    end
end

function EventsFrame:ENCOUNTER_END()
    addon:Debug("EventsFrame:ENCOUNTER_END")

    self:Reset()
end

function EventsFrame:TriggerCountdown(trigger)
    if trigger.countdown then
        return trigger.countdown
    end

    if trigger.type == "SPELL_CAST" then
        return select(4, GetSpellInfo(trigger.spellId))
    end

    return 0
end

function EventsFrame:ART_TRIGGER(_, trigger)
    addon:Debug("EventsFrame:ART_TRIGGER", trigger)

    local events = self.eventsCache[trigger.item.id]

    if events then
        for _, event in ipairs(events) do
            addon:Debug("EventsFrame:ART_TRIGGER", "Creating Event Frame")

            local eventFrame = self.frameFactory:AcquireFrame("event")

            local countdown = self:TriggerCountdown(trigger.trigger)
            local duration = 5
            local expirationTime = GetTime() + countdown + duration

            insert(self.eventFrames, {
                event = event,
                frame = eventFrame,
                countdown = countdown,
                duration = duration,
                expirationTime = expirationTime
            })

            C_Timer.After(countdown + duration, function() self:Update() end)
        end
    end

    self:Update()
end
