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

function EventsFrame:SetData(db)
    self.db = db
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
    self:UpdateLayout()
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

function EventsFrame:UpdateLayout()
    addon:Debug("EventsFrame:UpdateLayout")

    local totalFrames = #self.eventFrames

    for i, event in ipairs(self.eventFrames) do
        if event.new then
            -- New event. Animate alpha.
            addon.animations:Animate(event.uuid .. ":Alpha", 0, 1, 0.2, function(val)
                event.frame:GetFrame():SetAlpha(val)
            end, "SINUSOIDAL_IN")

            event.new = false
        end

        local currentOfsy = select(5, event.frame:GetFrame():GetPoint(1)) or 0
        local ofsy = (totalFrames - i) * event.frame:GetFrame():GetHeight() + (totalFrames - i) * 5

        if ofsy == currentOfsy then
            -- Same offset. No need to animate.
            event.frame:GetFrame():SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 0)
        else
            -- New offset. Animate change.
            addon.animations:Animate(event.uuid .. ":Ofsy", currentOfsy, ofsy, 0.1, function(val)
                event.frame:GetFrame():SetPoint("BOTTOM", self.frame, "BOTTOM", 0, val)
            end, "SINUSOIDAL_IN_OUT")
        end
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

function EventsFrame:ART_TRIGGER(_, trigger)
    addon:Debug("EventsFrame:ART_TRIGGER", trigger)

    local events = self.eventsCache[trigger.id]

    if events then
        for _, event in ipairs(events) do
            addon:Debug("EventsFrame:ART_TRIGGER", "Creating Event Frame")

            local eventFrame = addon.frameFactory:AcquireFrame("event")

            local duration = 5
            local countdown = trigger.ctx.castTime or 0
            local expirationTime = GetTime() + duration + countdown

            eventFrame:SetData(event, trigger.ctx)

            insert(self.eventFrames, {
                event = event,
                frame = eventFrame,
                expirationTime = expirationTime,
                uuid = addon.utils:GenerateUUID(),
                new = true
            })

            -- Ensure there is only a maximum of two events
            while #self.eventFrames > 2 do
                table.remove(self.eventFrames, 1)
            end

            C_Timer.After(duration + countdown, function() self:Update() end)
        end
    end

    self:Update()
end
