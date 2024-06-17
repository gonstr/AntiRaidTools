local AntiRaidTools = AntiRaidTools

function AntiRaidTools:InitOverview()
    local container = CreateFrame("Frame", "AntiRaidToolsOverview", UIParent, "BackdropTemplate")
    container:SetSize(250, 400)
    container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
    })
    container:SetBackdropColor(0, 0, 0, 0.7) -- 70% opacity
    container:SetMovable(true)
    container:EnableMouse(true)
    container:SetUserPlaced(true)
    container:SetClampedToScreen(true)
    container:RegisterForDrag("LeftButton")
    container:SetResizable(true)
    container:SetScript("OnDragStart", function(self) self:StartMoving() end)
    container:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    local resizeButton = CreateFrame("Button", nil, container)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT")
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    
    resizeButton:SetScript("OnMouseDown", function(self, button)
        self:GetParent():StartSizing("BOTTOMRIGHT")
    end)
    
    resizeButton:SetScript("OnMouseUp", function(self, button)
        self:GetParent():StopMovingOrSizing("BOTTOMRIGHT")
    end)

    local popup = CreateFrame("Frame", "AntiRaidToolsOverviewPopup", UIParent, "BackdropTemplate")
    popup:SetSize(200, 50)
    popup:SetPoint("TOPRIGHT", headerButton, "CENTER", 0, 0)
    popup:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",  -- Background texture
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",    -- Border texture
        tile = true,  -- Tile the background texture
        tileSize = 16,  -- Size of the tiles (if bgFile is tiled)
        edgeSize = 12,  -- Size of the border edges
        insets = {  -- Insets for the background
            left = 2,
            right = 2,
            top = 2,
            bottom = 2,
        },
    })
    popup:SetBackdropColor(0, 0, 0, 1)
    popup:SetFrameStrata("DIALOG")

    local popupClose = CreateFrame("Frame", nil, popup, "BackdropTemplate")
    local popupCloseHighlight
    popupClose:SetPoint("BOTTOMLEFT", 0, 10)
    popupClose:SetPoint("BOTTOMRIGHT", 0, 10)
    popupClose:SetHeight(20)
    popupClose:EnableMouse(true)
    popupClose:SetScript("OnEnter", function() popupCloseHightlight:Show() end)
    popupClose:SetScript("OnLeave", function() popupCloseHightlight:Hide() end)
    popupClose:EnableMouse(true)
    popupClose:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            popup:Hide()
        end
    end)
    
    popupCloseHightlight = popupClose:CreateTexture(nil, "HIGHLIGHT")
    popupCloseHightlight:SetPoint("TOPLEFT", 10, 0)
    popupCloseHightlight:SetPoint("BOTTOMRIGHT", -10, 0)
    popupCloseHightlight:SetTexture("Interface/Buttons/UI-Listbox-Highlight")
    popupCloseHightlight:SetBlendMode("ADD")
    popupCloseHightlight:SetAlpha(0.5)
    popupCloseHightlight:Hide()

    local popupCloseText = popupClose:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    popupCloseText:SetFont("Fonts\\FRIZQT__.TTF", 10)
    popupCloseText:SetPoint("BOTTOMLEFT", 15, 5)
    popupCloseText:SetText("Close")

    popup:Hide() -- Start hidden

    local function showPopup()
        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        x, y = x / scale, y / scale
        
        popup:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", x, y)
        popup:Show()
    end

    local header = CreateFrame("Frame", "AntiRaidToolsOverviewHeader", container, "BackdropTemplate")
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:EnableMouse(true)
    header:SetHeight(20)
    header:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
    })
    header:SetBackdropColor(0, 0, 0, 0.7) -- 70% opacity
    header:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:GetParent():StartMoving()
        elseif button == "RightButton" then
            showPopup()
        end
    end)

    header:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:GetParent():StopMovingOrSizing()
        end
    end)

    local encounterName = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    encounterName:SetFont("Fonts\\FRIZQT__.TTF", 10)
    encounterName:SetPoint("TOPLEFT", 10, -5)
    encounterName:SetShadowOffset(1, -1)
    encounterName:SetShadowColor(0, 0, 0, 1)

    local headerButton = CreateFrame("Button", nil, header)
    headerButton:SetSize(12, 12)
    headerButton:SetPoint("TOPRIGHT", -10, -5)
    headerButton:SetNormalTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetHighlightTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetPushedTexture("Gamepad_Ltr_Menu_32")

    headerButton:SetScript("OnClick", function()
        showPopup()
    end)
    headerButton:RegisterForClicks("AnyDown", "AnyUp")

    self.overviewFrame = container
    self.popup = popup
    self.overviewHeader = header
    self.encounterName = encounterName

    self:UpdateOverview()
end

function AntiRaidTools:UpdateOverview()
    local encounters = self.db.profile.data.encounters

    local hasData = false

    for _, part in pairs(encounters) do
        hasData = true
        break
    end
    
    if not hasData then
        self.overviewFrame:Hide()
    else
        for encounter, part in pairs(encounters) do
            self.encounterName:SetText(AntiRaidTools:GetEncounters()[encounter])
        end

        self.overviewFrame:Show()
    end
end
