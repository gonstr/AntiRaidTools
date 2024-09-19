local addonName, addon = ...

addon.BarFramePrototype = {}

local BarFrame = addon.BarFramePrototype
BarFrame.__index = BarFrame

function BarFrame:New()
    local instance = setmetatable({}, self)

    instance.frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    instance.frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true,
        tileSize = 16,
        edgeSize = 16
    })
    instance.frame:SetBackdropColor(0, 0, 0, 0.4)
    instance.frame:Hide()

    instance.frame.bar = CreateFrame("StatusBar", nil, instance.frame)
    instance.frame.bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")

    return instance
end

-- Color should be an rgb object
function BarFrame:SetData(left, color, duration)
    self.left = left
    self.color = color
    self.duration = duration

    self:Update()
end

function BarFrame:GetFrame()
    return self.frame
end

function BarFrame:OnAcquire()
    addon:Debug("EventFrame:OnAcquire")

    self.frame:Show()
end

function BarFrame:OnRelease()
    addon:Debug("EventFrame:OnRelease")

    addon.animations:Cancel(self.frame)

    self.frame:Hide()
end

function BarFrame:Update()
    self.frame.bar:SetAlpha(1)

    self.frame.bar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)
    self.frame.bar:SetSize(self.frame:GetWidth(), self.frame:GetHeight())

    self.frame.bar:ClearAllPoints()
    self.frame.bar:SetPoint(self.left and "LEFT" or "RIGHT", 0, 0)

    addon.animations:AnimateFrameWidth(self.frame.bar, self.frame.bar:GetWidth(), 0, self.duration)
    addon.animations:AnimateFrameAlpha(self.frame.bar, 1, 0, self.duration, "STEP")
end
