local AntiRaidTools = AntiRaidTools

function AntiRaidTools:InitRaidNotification()
    local container = CreateFrame("Frame", "AntiRaidToolsNotification", UIParent, "BackdropTemplate")
    container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    container:SetSize(200, 50)
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
    container.frameLockText:SetText("Raid Notifications Anchor")
    container.frameLockText:Hide()

    local contentFrame = CreateFrame("Frame", nil, container)
    contentFrame:SetAllPoints()

    contentFrame.headerText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    contentFrame.headerText:SetFont("Fonts\\FRIZQT__.TTF", 14)
    contentFrame.headerText:SetTextColor(1, 1, 1, 1)
    contentFrame.headerText:SetPoint("TOP", 0, -10)

    contentFrame.headerIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    contentFrame.headerIcon:SetSize(14, 14)
    contentFrame.headerIcon:SetPoint("RIGHT", container.headerText, "LEFT", -10, 0)
    contentFrame.headerIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    contentFrame.headerCountdown = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    contentFrame.headerCountdown:SetFont("Fonts\\FRIZQT__.TTF", 14)
    contentFrame.headerCountdown:SetTextColor(1, 1, 1, 1)
    contentFrame.headerCountdown:SetPoint("LEFT", contentFrame.headerText, "RIGHT", 10, 0)

    self.notificationFrame = container
    self.notificationContentFrame = contentFrame
end

function AntiRaidTools:RaidNotificationsToggleFrameLock(lock)
    if lock or self.notificationFrame:IsMovable() then
        self.notificationFrame:SetMovable(false)
        self.notificationFrame:EnableMouse(false)
        self.notificationFrame:SetBackdropColor(0, 0, 0, 0)
        self.notificationFrame.frameLockText:Hide()
        self.notificationContentFrame:Show()
        self.notificationFrame:Show()
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
        self.notificationContentFrame:Hide()
        self.notificationFrame:Hide() 
    end
end

function AntiRaidTools:RaidNotificationsUpdateHeader(text, icon)
    self.notificationContentFrame.headerText:SetText(text)
    self.notificationContentFrame.headerIcon:SetTexture(icon)
end

function AntiRaidTools:RaidNotificationsShowRaidAssignment(raidAssignment)
    self:RaidNotificationsToggleFrameLock(true)

    local headerText = raidAssignment.metadata.name
    local headerIcon = raidAssignment.metadata.icon

    if raidAssignment.metadata.spell_id then
        local name, _, icon = GetSpellInfo(raidAssignment.spell_id)
        headerText = name
        headerIcon = icon
    end

    self:RaidNotificationsUpdateHeader(text, icon)

    self.notificationFrame:Show()

    C_Timer.After(5 + raidAssignment.trigger.duration or 0, function()
        AntiRaidTools.notificationFrame:Hide()
    end)
end
