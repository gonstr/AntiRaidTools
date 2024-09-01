local addonName, addon = ...

local insert = table.insert
local sort = table.sort

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

function EventsFrame:SetData(db)
    self.db = db
end

function EventsFrame:GetFrame()
    return self.frame
end

function EventsFrame:OnAcquire()
    addon:Debug("EventsFrame:OnAcquire", encounterId)

    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
    self:RegisterMessage("ART_TRIGGER")

    self.frame:Show()
end

function EventsFrame:OnRelease()
    addon:Debug("EventsFrame:OnRelease", encounterId)

    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterMessage("ART_TRIGGER")

    self.frame:Hide()
end

function EventsFrame:Reset()
    addon:Debug("EventsFrame:Reset", encounterId)

    self.eventsCache = {}

    if not self.events then
        self.events = {}
    end

    for _, event in ipairs(self.events) do
        event:Release()
    end
end

function EventsFrame:ENCOUNTER_START(_, encounterId)
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
    self:Reset()
end

function EventsFrame:ART_TRIGGER(_, trigger)
    local events = self.eventsCache[trigger.id]

    if events then
        for _, event in pairs(events) do
            insert(self.events, {
                triggerTime = GetTime(),
                event = addon.frameFactory:AcquireFrame("event")
            })
        end
    end

    self:DoLayout()
end

function EventsFrame:DoLayout()
    sort(self.events, function(a, b) return a.triggerTime - b.triggerTime end)

    for i, event in ipairs(self.events) do
        event:SetPoint("BOTTOM", (i - 1) * event:GetFrame():GetHeight())
    end
end
