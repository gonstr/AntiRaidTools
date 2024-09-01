local addonName, addon = ...

addon.ContainerFramePrototype = {}

local ContainerFrame = addon.ContainerFramePrototype
ContainerFrame.__index = ContainerFrame

-- Movable container frame
function ContainerFrame:New(frameName)
    local instance = setmetatable({}, self)

    instance.frame = CreateFrame("Frame", frameName, UIParent, "BackdropTemplate")
    instance.frame:SetBackdrop({
        bgFile = "Interface\\Addons\\AntiRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    instance.frame:SetBackdropColor(0, 0, 0, 0)
    instance.frame:SetMovable(true)
    instance.frame:SetUserPlaced(true)
    instance.frame:SetClampedToScreen(true)
    instance.frame:RegisterForDrag("LeftButton")
    instance.frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    instance.frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    instance.frame:Hide()

    instance.frame.name = instance.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    instance.frame.name:SetFont("Fonts\\FRIZQT__.TTF", 14)
    instance.frame.name:SetTextColor(1, 1, 1, 0.4)
    instance.frame.name:SetPoint("CENTER", 0, 0)
    instance.frame.name:Hide()

    return instance
end

function ContainerFrame:SetData(name, w, h, anchor, x, y)
    self.frame:SetPoint(anchor, x, y)
    self.frame:SetSize(w, h)
    self.frame.name:SetText(name)
end

function ContainerFrame:ToggleFrameLock()
    self:SetFrameLock(self.frame:IsMouseEnabled())
end

function ContainerFrame:SetFrameLock(lock)
    if lock then
        self.frame:EnableMouse(false)
        self.frame:SetBackdropColor(0, 0, 0, 0)
        self.frame.name:Hide()
    else
        self.frame:EnableMouse(true)
        self.frame:SetBackdropColor(0, 0, 0, 0.6)
        self.frame.name:Show()
    end
end

function ContainerFrame:IsFrameLocked()
    return not self.frame:IsMouseEnabled()
end

function ContainerFrame:GetFrame()
    return self.frame
end

function ContainerFrame:OnAcquire()
    self.frame:Show()
end

function ContainerFrame:OnRelease()
    self.frame:Hide()
end
