local AntiRaidTools = AntiRaidTools

function AntiRaidTools:InitOverview()
    local container = CreateFrame("Frame", "AntiRaidToolsOverview", UIParent, "BackdropTemplate")
    container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    container:SetSize(300, 400)
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
    })
    container:SetBackdropColor(0, 0, 0, 1)
    container:SetMovable(true)
    container:EnableMouse(true)
    container:SetUserPlaced(true)
    container:SetClampedToScreen(true)
    container:RegisterForDrag("LeftButton")
    container:SetResizable(true)
    container:SetClipsChildren(true)
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
    popup:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = {
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
        tileSize = 16,
    })
    header:SetBackdropColor(0, 0, 0, 0.8)
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

    local main = CreateFrame("Frame", "AntiRaidToolsOvervieMain", container, "BackdropTemplate")
    main:SetPoint("TOPLEFT", 0, -20)
    main:SetPoint("TOPRIGHT", 0, -20)
    main:SetPoint("BOTTOMLEFT", 0, 0)
    main:SetPoint("BOTTOMRIGHT", 0, 0)

    self.overviewFrame = container
    self.overviewPopup = popup
    self.overviewPopupListItems = {}
    self.overviewHeader = header
    self.overvieweHeaderText = encounterName
    self.overviewMain = main
    self.overviewMainHeaders = {}
    self.overviewMainRaidCDGroups = {}
end

function AntiRaidTools:UpdateOverview()
    local encounters = self.db.profile.data.encounters

    local show = self.db.profile.overview.show
    
    if not show then
        self.overviewFrame:Hide()
        return
    end

    local selectedEncounterIdFound = false

    for encounterId, _ in pairs(encounters) do
        if self.db.profile.overview.selectedEncounterId == encounterId then
            selectedEncounterIdFound = true
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
    self:UpdateOverviewMain()
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

function AntiRaidTools:ShowOverviewPopupListItem(index, text, onClick, extraOffset)
    if not self.overviewPopupListItems[index] then
        self.overviewPopupListItems[index] = createPopupListItem(self.overviewPopup)
    end

    local item = self.overviewPopupListItems[index]

    local yOfs = -10 - (20 * (index -1))

    if extraOffset then
        yOfs = yOfs - 10
    end

    item:SetPoint("TOPLEFT", 0, yOfs)
    item:SetPoint("TOPRIGHT", 0, yOfs)

    item.text:SetText(text)
    item.onClick = onClick

    item:Show()

    return yOfs
end

local function selectEncounter(encounterId)
    AntiRaidTools.db.profile.overview.selectedEncounterId = encounterId
    AntiRaidTools:OnOverviewSelectedEncounter()
end

function AntiRaidTools:UpdateOverviewPopup()
    -- Update list items
    for _, item in pairs(self.overviewPopupListItems) do
        item:Hide()
    end

    local index = 1
    for encounterId, encounter in pairs(self.db.profile.data.encounters) do
        local selectFunc = function() selectEncounter(encounterId) end
        self:ShowOverviewPopupListItem(index, self:GetEncounters()[encounterId], selectFunc)
        index = index + 1
    end

    -- Add extra offset if we have list items above the close item
    local extraOffset = index > 1
    local yOfs = self:ShowOverviewPopupListItem(index, "Close", nil, extraOffset)

    local popupHeight = math.abs(yOfs) + 30

    -- Update popup size
    self.overviewPopup:SetHeight(popupHeight)
end

local function createOverviewMainHeader(mainFrame, prevFrame)
    local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    frame:SetHeight(30)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = true,
        tileSize = 16
    })
    frame:SetBackdropColor(0.12, 0.56, 1, 1)

    -- Anchor to main frame or previous row if it exists
    if prevFrame then
        frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0)
        frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0)
    else
        frame:SetPoint("TOPLEFT", 0)
        frame:SetPoint("TOPRIGHT", 0)
    end

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetSize(22, 22)
    frame.icon:SetPoint("BOTTOMLEFT", 10, 4)
    frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    frame.text:SetPoint("BOTTOMLEFT", 38, 9)

    return frame
end

local function updateOverviewMainHeader(frame, prevFrame, icon, name)
    frame:Show()

    frame:ClearAllPoints()

    if prevFrame then
        frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0)
        frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0)
    else
        frame:SetPoint("TOPLEFT", 0)
        frame:SetPoint("TOPRIGHT", 0)
    end

    frame.icon:SetTexture(icon)
    frame.text:SetText(name)
end

local function createOverviewMainCDGroup(mainFrame, prevFrame)
    local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    frame:SetHeight(20)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = true,
        tileSize = 16
    })

    frame.cds = {}

    return frame
end

local function createOverviewMainCDGroupAssignment(parentFrame)
    local frame = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = true,
        tileSize = 16
    })
    frame:SetBackdropColor(0, 0, 0, 0)

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetSize(12, 12)
    frame.icon:SetPoint("BOTTOMLEFT", 10, 4)
    frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.text:SetFont("Fonts\\FRIZQT__.TTF", 10)
    frame.text:SetPoint("BOTTOMLEFT", 26, 4)

    return frame
end

local function updateOverviewMainCDGroupAssignment(frame, assignment, index, total)
    frame:Show()

    local _, _, icon = GetSpellInfo(assignment.spell_id)

    frame.icon:SetTexture(icon)
    frame.text:SetText(assignment.player)

    frame:ClearAllPoints()

    if total > 1 then
        if index > 1 then
            frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "BOTTOM")
            frame:SetPoint("TOPRIGHT", 0)
        else
            frame:SetPoint("BOTTOMLEFT", 0)
            frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOP")
        end
    else
        frame:SetPoint("BOTTOMLEFT", 0)
        frame:SetPoint("TOPRIGHT", 0)
    end
end

local function updateOverviewMainCDGroup(frame, prevFrame, assignments, even)
    frame:Show()

    frame:SetBackdropColor(0, 0, 0, even and 0.6 or 0.2)

    frame:ClearAllPoints()
    
    if prevFrame then
        frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0)
        frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0)
    else
        frame:SetPoint("TOPLEFT", 0)
        frame:SetPoint("TOPRIGHT", 0)
    end

    for _, cd in pairs(frame.cds) do
        cd:Hide()
    end

    local index = 1
    
    for _, assignment in pairs(assignments) do
        if not frame.cds[index] then
            frame.cds[index] = createOverviewMainCDGroupAssignment(frame)
        end

        updateOverviewMainCDGroupAssignment(frame.cds[index], assignment, index, #assignments)

        index = index + 1
    end
end

function AntiRaidTools:UpdateOverviewMain()
    for _, header in pairs(self.overviewMainHeaders) do
        header:Hide()
    end

    for _, group in pairs(self.overviewMainRaidCDGroups) do
        group:Hide()
    end

    local selectedEncounterId = self.db.profile.overview.selectedEncounterId
    local encounter = self.db.profile.data.encounters[selectedEncounterId]

    if encounter then
        local hIndex = 1
        local rcdIndex = 1
        local prevFrame = nil
        for _, part in pairs(encounter) do
            if part.type == "RAID_CDS" then
                -- Update header
                if not self.overviewMainHeaders[hIndex] then
                    self.overviewMainHeaders[hIndex] = createOverviewMainHeader(self.overviewMain)
                end
    
                local frame = self.overviewMainHeaders[hIndex]
                local name, _, icon = GetSpellInfo(part.spell_id)

                updateOverviewMainHeader(frame, prevFrame, icon, name)
                
                prevFrame = frame
                hIndex = hIndex + 1

                -- Update assignments
                for _, assignment in pairs(part.assignments) do
                    if not self.overviewMainRaidCDGroups[rcdIndex] then
                        self.overviewMainRaidCDGroups[rcdIndex] = createOverviewMainCDGroup(self.overviewMain)
                    end

                    local frame = self.overviewMainRaidCDGroups[rcdIndex]

                    updateOverviewMainCDGroup(frame, prevFrame, assignment, rcdIndex % 2 == 0)

                    prevFrame = frame
                    rcdIndex = rcdIndex + 1
                end
            end
        end
    end
end
