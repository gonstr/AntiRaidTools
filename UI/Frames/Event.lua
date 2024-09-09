local addonName, addon = ...

addon.EventFramePrototype = {}

local EventFrame = addon.EventFramePrototype
EventFrame.__index = EventFrame

function EventFrame:New()
    local instance = setmetatable({}, self)

    instance.frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    instance.frame:SetBackdrop({
        bgFile = "Interface\\Cooldown\\LoC-ShadowBG",
    })
    instance.frame:SetBackdropColor(0, 0, 0, 0.6)
    instance.frame:SetBackdropBorderColor(1, 1, 1, 1)
    instance.frame:SetSize(300, 60)
    instance.frame:Hide()

    instance.frame.text = instance.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    instance.frame.text:SetFont("Fonts\\FRIZQT__.TTF", 14)
    instance.frame.text:SetTextColor(1, 1, 1, 1)
    instance.frame.text:SetPoint("TOPLEFT", 20, -10)

    instance.frame.countdown = instance.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    instance.frame.countdown:SetFont("Fonts\\FRIZQT__.TTF", 14)
    instance.frame.countdown:SetTextColor(1, 1, 1, 1)
    instance.frame.countdown:SetPoint("TOPRIGHT", -20, -10)

    return instance
end

function EventFrame:SetData(event, ctx)
    self.event = addon.utils:DeepClone(event)
    self.ctx = ctx
    
    -- Interpolate event name
    self.event.name = addon.utils:StringInterpolate(self.event.name, { ctx = ctx })

    self:Update()
end

function EventFrame:GetFrame()
    return self.frame
end

function EventFrame:OnAcquire()
    addon:Debug("EventFrame:OnAcquire")

    self.frame:Show()
end

function EventFrame:OnRelease()
    addon:Debug("EventFrame:OnRelease")

    self.frame:Hide()
end

function EventFrame:Update()
    self.frame.text:SetText(self.event.name)
end
