local addonName, addon = ...

addon.IconFramePrototype = {}

local IconFrame = addon.IconFramePrototype
IconFrame.__index = IconFrame

function IconFrame:New()
    local instance = setmetatable({}, self)

    instance.frame = CreateFrame("Frame", nil, UIParent)
    instance.frame:SetSize(16, 16)

    instance.frame.cooldown = CreateFrame("Cooldown", nil, instance.frame, "CooldownFrameTemplate")
    instance.frame.cooldown:SetAllPoints()

    instance.frame.icon = instance.frame:CreateTexture(nil, "ARTWORK")
    instance.frame.icon:SetAllPoints()
    instance.frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    return instance
end

function IconFrame:SetData(icon, duration, expirationTime)
    self.icon = icon
    self.duration = duration
    self.expirationTime = expirationTime

    self:Update()
end

function IconFrame:GetFrame()
    return self.frame
end

function IconFrame:OnAcquire()
    addon:Debug("IconFrame:OnAcquire")

    self.frame:Show()
end

function IconFrame:OnRelease()
    addon:Debug("IconFrame:OnRelease")

    self.frame:Hide()
end

function IconFrame:Update()
    self.frame.cooldown:Clear()
    
    if self.duration and self.expirationTime then
        self.frame.cooldown:SetCooldown(self.expirationTime - self.duration, self.duration)

        self:ScheduleRelease(self.expirationTime - GetTime())
    end

    self.frame.icon:SetTexture(self.icon)
end
