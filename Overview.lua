local AntiRaidTools = AntiRaidTools

function AntiRaidTools:InitOverview()
    local container = CreateFrame("Frame", "AntiRaidToolsOverview", UIParent, "BackdropTemplate")
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
    container:SetResizeBounds(200, 200, 400, 600)
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
    --popup:SetPoint("TOPRIGHT", headerButton, "CENTER", 0, 0)
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
    headerButton:SetSize(14, 14)
    headerButton:SetPoint("TOPRIGHT", -10, -3)
    headerButton:SetNormalTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetHighlightTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetPushedTexture("Gamepad_Ltr_Menu_32")

    headerButton:SetScript("OnClick", function()
        showPopup()
    end)
    headerButton:RegisterForClicks("AnyDown", "AnyUp")

    self.overviewFrame = container
    self.overviewPopup = popup
    self.overviewPopupListItems = {}
    self.overviewHeader = header
    self.overvieweHeaderText = encounterName
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
        return
    end

    local selectedEncounterIdFound = false

    for encounterId, _ in pairs(encounters) do
        if self.db.profile.overview.selectedEncounterId == encounter_id then
            selectedEncounterId = true
        end
    end

    if not selectedEncounterIdFound then
        for encounterId, _ in pairs(encounters) do
            self.db.profile.overview.selectedEncounterId = encounterId
            break
        end
    end

    self:UpdateOverviewHeaderText()
    self:UpdateOverviewPopup()
    self.overviewFrame:Show()
end

function AntiRaidTools:UpdateOverviewHeaderText()
    self.overvieweHeaderText:SetText(self:GetEncounters()[self.db.profile.overview.selectedEncounterId])
end

local function createPopupListItem(popupFrame, text, onClick)
    local item = CreateFrame("Frame", nil, popupFrame, "BackdropTemplate")

    local highlight
    item:SetHeight(20)
    item:EnableMouse(true)
    item:SetScript("OnEnter", function() highlight:Show() end)
    item:SetScript("OnLeave", function() highlight:Hide() end)
    item:EnableMouse(true)
    item:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if item.onClick then item.onClick() end
            popupFrame:Hide()
        end
    end)
    
    highlight = item:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetPoint("TOPLEFT", 10, 0)
    highlight:SetPoint("BOTTOMRIGHT", -10, 0)
    highlight:SetTexture("Interface/Buttons/UI-Listbox-Highlight")
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.5)
    highlight:Hide()

    item.text = item:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    item.text:SetFont("Fonts\\FRIZQT__.TTF", 10)
    item.text:SetTextColor(1, 1, 1)
    item.text:SetPoint("BOTTOMLEFT", 15, 5)
    item.text:SetText(text)

    item.onClick = onClick

    return item
end

function AntiRaidTools:ShowOverviewPopupListItem(index, text, onClick, finalItem)
    if not self.overviewPopupListItems[index] then
        self.overviewPopupListItems[index] = createPopupListItem(self.overviewPopup)
    end

    local item = self.overviewPopupListItems[index]

    local yOfs = -10 - (20 * (index -1))

    if finalItem then
        yOfs = yOfs - 10
    end

    item:SetPoint("TOPLEFT", 0, yOfs)
    item:SetPoint("TOPRIGHT", 0, yOfs)

    item.text:SetText(text)
    item.onClick = onClick

    item:Show()

    return yOfs
end

function AntiRaidTools:UpdateOverviewPopup()
    -- Update list items
    for _, item in pairs(self.overviewPopupListItems) do
        item:Hide()
    end

    local index = 1
    for encounterId, encounter in pairs(self.db.profile.data.encounters) do
        local selectEncounter = function()
            AntiRaidTools.db.profile.overview.selectedEncounterId = encounterId
            AntiRaidTools:OnOverviewSelectedEncounter()
        end

        self:ShowOverviewPopupListItem(index, self:GetEncounters()[encounterId], selectEncounter)
        index = index + 1
    end

    local yOfs = self:ShowOverviewPopupListItem(index, "Close", nil, true)

    local popupHeight = math.abs(yOfs) + 30

    -- Update popup size
    self.overviewPopup:SetHeight(popupHeight)
end
