local addonName, addon = ...

addon.EventFramePrototype = {}

local EventFrame = addon.EventFramePrototype
EventFrame.__index = EventFrame

function EventFrame:New()
    local instance = setmetatable({}, self)

    instance.frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    instance.frame:SetBackdrop({
        bgFile = "Interface\\Cooldown\\LoC-ShadowBG",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    instance.frame:SetBackdropColor(1, 0, 0, 0.6)
    instance.frame:SetBackdropBorderColor(0, 0, 0, 0)
    instance.frame:SetSize(300, 60)
    instance.frame:Hide()

    instance.frame.text = instance.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    instance.frame.text:SetFont("Fonts\\FRIZQT__.TTF", 14)
    instance.frame.text:SetTextColor(1, 1, 1, 1)
    instance.frame.text:SetPoint("TOPLEFT", 25, -15)

    instance.frame.countdown = instance.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    instance.frame.countdown:SetFont("Fonts\\FRIZQT__.TTF", 14)
    instance.frame.countdown:SetTextColor(1, 1, 1, 1)
    instance.frame.countdown:SetPoint("TOPRIGHT", -25, -15)

    instance.frame.bar = addon.frameFactory:AcquireFrame("bar")
    instance.frame.bar:GetFrame():SetParent(instance.frame)
    instance.frame.bar:GetFrame():SetSize(250, 2)
    instance.frame.bar:GetFrame():SetPoint("BOTTOM", 0, 15)

    return instance
end

function EventFrame:SetData(event, ctx)
    self.event = addon.utils:DeepClone(event)
    self.ctx = ctx
    
    self.event.name = addon.utils:StringInterpolate(event.name, ctx)

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

    addon.animations:Cancel(self.frame)
    addon.animations:Cancel(self.frame.countdown)

    self.frame:Hide()
end

function EventFrame:Update()
    if self.event.highlight then
        addon.animations:AnimateFrame(self.frame, function(val)
            self.frame:SetBackdropBorderColor(1, 0, 0, val)
        end, 0.4, 1, 0.5, true, "PULSE")
    else
        addon.animations:Cancel(self.frame)
        self.frame:SetBackdropBorderColor(0, 0, 0, 0)
    end

    self.frame.text:SetText(self.event.name)

    if self.ctx.trigger.countdown and self.ctx.trigger.countdown > 0 then
        self.frame.bar:GetFrame():Show()

        local barColor = { r = 1, g = 1, b = 1 }
        self.frame.bar:SetData(true, barColor, self.ctx.trigger.countdown)

        addon.animations:AnimateTextTime(self.frame.countdown, self.ctx.trigger.countdown, 0)
    else
        self.frame.bar:GetFrame():Hide()
    end
end
