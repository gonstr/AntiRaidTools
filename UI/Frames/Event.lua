local addonName, addon = ...

addon.EventFramePrototype = {}

local EventFrame = addon.EventFramePrototype
EventFrame.__index = EventFrame

function EventFrame:New()
    local instance = setmetatable({}, self)

    instance.frame = CreateFrame("Frame", nil, UIParent, "BackdropTempalte")
    instance.frame:SetBackdrop({ bgFile = "Interface\\Cooldown\\LoC-ShadowBG" })
    instance.frame:SetBackdropColor(0, 0, 0, 0.6)
    instance.frame:SetSize(200, 100)
    instance.frame:Hide()

    return instance
end

function EventFrame:GetFrame()
    return self.frame
end

function EventFrame:OnAcquire()
    self.frame:Show()
end

function EventFrame:OnRelease()
    self.frame:Hide()
end



-- local triggers = encounterItems(addon.db.profile.v1.packs, "TRIGGER", encounterId)

-- if #triggers > 0 then
--     self.encounter = addon.EncounterControllerPrototype:New(self.utils, triggers) 
-- end

-- self.ui.events:SetData(encounterItems(self.db.profile.v1.packs, "EVENT", encounterId))