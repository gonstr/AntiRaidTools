local AntiRaidTools = AntiRaidTools

function AntiRaidTools:InitRaidNotification()
    local container = CreateFrame("Frame", "AntiRaidToolsNotification", UIParent, "BackdropTemplate")
    container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    container:SetSize(200, 100)
    container:SetBackdrop({
        bgFile = "Interface\\Addons\\AntiRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    container:SetBackdropColor(0, 0, 0, 0)

    container.frameLockText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    container.frameLockText:SetFont("Fonts\\FRIZQT__.TTF", 14)
    container.frameLockText:SetTextColor(1, 1, 1, 0.4)
    container.frameLockText:SetPoint("CENTER", 0, 0)
    container.frameLockText:SetText("Raid Notifications")
    container.frameLockText:Hide()

    container.header = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    container.header:SetFont("Fonts\\FRIZQT__.TTF", 14)
    container.header:SetTextColor(1, 1, 1, 1)
    container.header:SetPoint("TOP", 0, -10)
    container.header:SetText()

    self.notificationFrame = container
end

function AntiRaidTools:RaidNotificationsToggleFrameLock(forceLock)
    if forceLock or self.notificationFrame:IsMovable() then
        self.notificationFrame:SetMovable(false)
        self.notificationFrame:EnableMouse(false)
        self.notificationFrame:SetBackdropColor(0, 0, 0, 0)
        self.notificationFrame.frameLockText:Hide()
    else
        self.notificationFrame:SetMovable(true)
        self.notificationFrame:EnableMouse(true)
        self.notificationFrame:SetUserPlaced(true)
        self.notificationFrame:SetClampedToScreen(true)
        self.notificationFrame:RegisterForDrag("LeftButton")
        self.notificationFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
        self.notificationFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        self.notificationFrame:SetBackdropColor(0, 0, 0, 0.8)
        self.notificationFrame.frameLockText:Show()
    end
end

