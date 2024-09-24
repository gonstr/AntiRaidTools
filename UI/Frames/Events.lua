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

    instance.triggerCache = {}
    instance.eventFrames = {}

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

    self.triggerCache = {}

    for i, event in ipairs(self.eventFrames) do
        event.frame:Release()
        self.eventFrames[i] = nil
    end
end

function EventsFrame:Update()
    addon:Debug("EventsFrame:Update")

    self:Update()
end

function EventsFrame:CreateEvent(event, ctx, duration)
    local frame = addon.frameFactory:AcquireFrame("event")

    local countdown = ctx.castTime or 0
    local expirationTime = GetTime() + duration + countdown

    frame:SetData(event, ctx)

    insert(self.eventFrames, {
        event = event,
        frame = frame,
        expirationTime = expirationTime,
        uuid = addon.utils:GenerateUUID(),
        new = true
    })

    
    C_Timer.After(duration + countdown, function() self:Update() end)
end

function EventsFrame:ReleaseEvent(uuid)
    for i, event in ipairs(self.eventFrames) do
        if event.uuid == uuid then
            event.frame:Release()
            remove(self.eventFrames, i)
        end
    end
end

function EventsFrame:Update()
    addon:Debug("EventsFrame:UpdateLayout")

    local totalFrames = #self.eventFrames

    for i, event in ipairs(self.eventFrames) do
        if event.expirationTime <= GetTime() then
            -- Event should be released
            addon.animations:AnimateFrameAlpha(event.frame:GetFrame(), 1, 0, 0.2)

            C_Timer.After(0.2, function() self:ReleaseEvent(event.uuid) end)
        end

        if event.new then
            -- New event. Animate alpha.
            addon.animations:AnimateFrameAlpha(event.frame:GetFrame(), 0, 1, 0.2)
            event.new = false
        end

        local currentOfsy = select(5, event.frame:GetFrame():GetPoint(1)) or 0
        local ofsy = (totalFrames - i) * event.frame:GetFrame():GetHeight() + (totalFrames - i) * 5

        if ofsy == currentOfsy then
            -- Same offset. No need to animate.
            event.frame:GetFrame():SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 0)
        else
            -- New offset. Animate change.
            addon.animations:AnimateFramePoint(event.frame:GetFrame(), "BOTTOM", self.frame, currentOfsy, ofsy, 0.1)
        end
    end
end

function EventsFrame:ENCOUNTER_START(_, encounterId)
    addon:Debug("EventsFrame:ENCOUNTER_START", encounterId)

    self:Reset()

    -- Populate cache
    for _, pack in pairs(self.db.profile.v1.packs) do
        for _, item in ipairs(pack.items) do
            if item.type == "EVENT" and item.encounter == encounterId then
                if not self.triggerCache[item.trigger] then
                    self.triggerCache[item.trigger] = {}
                end

                insert(self.triggerCache[item.trigger], item)
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

    local events = self.triggerCache[trigger.id]

    if events then
        for _, event in ipairs(events) do
            if addon.utils:InterpolateIf(event, trigger.ctx) then
                if trigger.untrigger then
                    -- Untrigger
                    for _, event in ipairs(self.eventFrames) do
                        if event.event.trigger == trigger.id then
                            event.expirationTime = 0
                            self:Update()
                        end
                    end
                else
                    -- Trigger
                    self:CreateEvent(event, trigger.ctx, trigger.duration or 5)

                    -- Ensure there is only a maximum of three events
                    while #self.eventFrames > 3 do
                        self:ReleaseEvent(self.eventFrames[1].uuid)
                    end
                end
            end
        end
    end

    self:Update()
end
