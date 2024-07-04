local AntiRaidTools = AntiRaidTools

local MIN_HEIGHT = 200

function AntiRaidTools:InitOverview()
    local container = CreateFrame("Frame", "AntiRaidToolsOverview", UIParent, "BackdropTemplate")
    container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    container:SetSize(200, MIN_HEIGHT)
    container:SetBackdrop({
        bgFile = "Interface\\Addons\\AntiRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    container:SetBackdropColor(0, 0, 0, 0.4)
    container:SetMovable(true)
    container:EnableMouse(true)
    container:SetUserPlaced(true)
    container:SetClampedToScreen(true)
    container:RegisterForDrag("LeftButton")
    container:SetScript("OnDragStart", function(self) self:StartMoving() end)
    container:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    local popup = CreateFrame("Frame", "AntiRaidToolsOverviewPopup", UIParent, "BackdropTemplate")
    popup:SetSize(200, 50)
    popup:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
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
        if InCombatLockdown() or AntiRaidTools:RaidAssignmentsInEncounter() then
            return
        end

        local encounters = AntiRaidTools.db.profile.data.encounters

        for _, encounters in pairs(encounters) do
            local scale = UIParent:GetEffectiveScale()
            local x, y = GetCursorPosition()
            x, y = x / scale, y / scale

            popup:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", x, y)

            popup:Show()

            break
        end
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

    local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerText:SetFont("Fonts\\FRIZQT__.TTF", 10)
    headerText:SetPoint("TOPLEFT", 10, -5)
    headerText:SetShadowOffset(1, -1)
    headerText:SetShadowColor(0, 0, 0, 1)

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
    headerButton:Hide()

    local main = CreateFrame("Frame", "AntiRaidToolsOvervieMain", container, "BackdropTemplate")
    main:SetPoint("TOPLEFT", 0, -20)
    main:SetPoint("TOPRIGHT", 0, -20)
    main:SetPoint("BOTTOMLEFT", 0, 0)
    main:SetPoint("BOTTOMRIGHT", 0, 0)

    self.overviewFrame = container
    self.overviewPopup = popup
    self.overviewPopupListItems = {}
    self.overviewHeader = header
    self.overviewHeaderButton = headerButton
    self.overviewHeaderText = headerText
    self.overviewMain = main
    self.overviewMainHeaders = {}
    self.overviewMainRaidAssignmentGroups = {}
end

function AntiRaidTools:OverviewResize()
    local encounters = self.db.profile.data.encounters

    local maxHeight = 0

    for _, encounter in pairs(encounters) do
        -- Overview Header
        local height = 20

        if encounter then
            for _, part in ipairs(encounter) do
                if part.type == "RAID_ASSIGNMENTS" then
                    height = height + 30
                    for _ in ipairs(part.assignments) do
                        height = height + 20
                    end
                end
            end
        end

        if height > maxHeight then
            maxHeight = height
        end
    end

    self.overviewFrame:SetHeight(math.max(MIN_HEIGHT, maxHeight))
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
        local encounterIndexes = {}
        for encounterId in pairs(self.db.profile.data.encounters) do
            table.insert(encounterIndexes, encounterId)
        end
        table.sort(encounterIndexes)

        self.db.profile.overview.selectedEncounterId = encounterIndexes[1]
    end

    self:UpdateOverviewHeaderText()
    self:UpdateOverviewHeaderButton()
    self:UpdateOverviewPopup()
    self:UpdateOverviewMain()
    self:UpdateOverviewSpells()

    self.overviewFrame:Show()
end

function AntiRaidTools:UpdateOverviewHeaderText()
    local encounters = self.db.profile.data.encounters

    local encountersExists = false

    for _ in pairs(encounters) do
        encountersExists = true
        break
    end

    self.overviewHeaderText:SetAlpha(1)

    if encountersExists then
        local encounterName = self:GetEncounters()[self.db.profile.overview.selectedEncounterId]

        if not encounterName then
            encounterName = self.db.profile.overview.selectedEncounterId
        end

        self.overviewHeaderText:SetText(encounterName)
    else
        if self.db.profile.data.encountersProgress then
            self.overviewHeaderText:SetText("Loading Assignments... |cFFFFFFFF" .. string.format("%.1f", self.db.profile.data.encountersProgress) .. "%|r")
        else
            self.overviewHeaderText:SetText("ART |cFFFFFFFF" .. GetAddOnMetadata("AntiRaidTools", "Version") .. "|r")
            self.overviewHeaderText:SetAlpha(0.8)
        end
    end
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
    highlight:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
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

function AntiRaidTools:OverviewSelectEncounter(encounterId)
    self.db.profile.overview.selectedEncounterId = encounterId
    self:UpdateOverview()
end

function AntiRaidTools:UpdateOverviewHeaderButton()
    local hasEncounterData = false

    for _, _ in pairs(self.db.profile.data.encounters) do
        hasEncounterData = true
        break
    end

    if hasEncounterData then
        self.overviewHeaderButton:Show()
    else
        self.overviewHeaderButton:Hide()
    end
end

function AntiRaidTools:UpdateOverviewPopup()
    -- Update list items
    for _, item in pairs(self.overviewPopupListItems) do
        item:Hide()
    end

    local encounterIndexes = {}
    for encounterId in pairs(self.db.profile.data.encounters) do
        table.insert(encounterIndexes, encounterId)
    end
    table.sort(encounterIndexes)

    local index = 1
    for _, encounterId in ipairs(encounterIndexes) do
        local selectFunc = function() self:OverviewSelectEncounter(encounterId) end

        local encounterName = self:GetEncounters()[encounterId]

        if not encounterName then
            encounterName = encounterId
        end

        self:ShowOverviewPopupListItem(index, encounterName, selectFunc)
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
    frame:SetHeight(20)
    frame:SetBackdrop({
        bgFile = "Interface\\Addons\\AntiRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32
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

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.text:SetFont("Fonts\\FRIZQT__.TTF", 10)
    frame.text:SetTextColor(1, 1, 1, 1)
    frame.text:SetPoint("BOTTOMLEFT", 10, 5)

    return frame
end

local function updateOverviewMainHeader(frame, prevFrame, name)
    frame:Show()

    frame:ClearAllPoints()

    if prevFrame then
        frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, -8)
        frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, -8)
    else
        frame:SetPoint("TOPLEFT", 0)
        frame:SetPoint("TOPRIGHT", 0)
    end

    frame.text:SetText(name)
end

local function createOverviewMainGroup(mainFrame, prevFrame)
    local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    frame:SetHeight(20)
    frame:SetBackdrop({
        bgFile = "Interface\\Addons\\AntiRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })

    frame.assignments = {}

    return frame
end

local function createOverviewMainGroupAssignment(parentFrame)
    local frame = CreateFrame("Frame", nil, parentFrame)

    frame.iconFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.iconFrame:SetSize(14, 14)
    frame.iconFrame:SetPoint("BOTTOMLEFT", 10, 3)

    frame.icon = frame.iconFrame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.text:SetFont("Fonts\\FRIZQT__.TTF", 10)
    frame.text:SetTextColor(1, 1, 1, 1)
    frame.text:SetPoint("BOTTOMLEFT", 28, 5)

    return frame
end

local function updateOverviewMainGroupAssignment(frame, assignment, index, total)
    frame:Show()

    frame.player = assignment.player
    frame.spellId = assignment.spell_id

    local _, _, icon = GetSpellInfo(assignment.spell_id)

    frame.icon:SetTexture(icon)
    frame.text:SetText(assignment.player)

    local color = AntiRaidTools:GetSpellColor(assignment.spell_id)

    frame.text:SetTextColor(color.r, color.g, color.b)

    frame:ClearAllPoints()

    if total > 1 then
        if index > 1 then
            frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "BOTTOM")
            frame:SetPoint("TOPRIGHT")
        else
            frame:SetPoint("BOTTOMLEFT")
            frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOP")
        end
    else
        frame:SetPoint("BOTTOMLEFT")
        frame:SetPoint("TOPRIGHT")
    end
end

local function updateOverviewMainGroup(frame, prevFrame, group, uuid, index)
    frame:Show()

    frame.uuid = uuid
    frame.index = index

    frame:SetBackdropColor(0, 0, 0, 0)

    frame:ClearAllPoints()
    
    if prevFrame then
        frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, index == 1 and -2 or 0)
        frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, index == 1 and -2 or 0)
    else
        frame:SetPoint("TOPLEFT", 0)
        frame:SetPoint("TOPRIGHT", 0)
    end

    for _, cd in pairs(frame.assignments) do
        cd:Hide()
    end
    
    for i, assignment in ipairs(group) do
        if not frame.assignments[i] then
            frame.assignments[i] = createOverviewMainGroupAssignment(frame)
        end

        updateOverviewMainGroupAssignment(frame.assignments[i], assignment, i, #group)
    end
end

function AntiRaidTools:UpdateOverviewMain()
    for _, header in pairs(self.overviewMainHeaders) do
        header:Hide()
    end

    for _, group in pairs(self.overviewMainRaidAssignmentGroups) do
        group:Hide()
    end

    local selectedEncounterId = self.db.profile.overview.selectedEncounterId
    local encounter = self.db.profile.data.encounters[selectedEncounterId]

    if encounter then
        local headerIndex = 1
        local groupIndex = 1
        local prevFrame = nil
        for _, part in pairs(encounter) do
            if part.type == "RAID_ASSIGNMENTS" then
                -- Update header
                if not self.overviewMainHeaders[headerIndex] then
                    self.overviewMainHeaders[headerIndex] = createOverviewMainHeader(self.overviewMain)
                end
    
                local frame = self.overviewMainHeaders[headerIndex]

                local headerText

                if part.metadata.spell_id then
                    local name = GetSpellInfo(part.metadata.spell_id)
                    headerText = name
                else
                    headerText = part.metadata.name
                end

                updateOverviewMainHeader(frame, prevFrame, headerText)
                
                prevFrame = frame
                headerIndex = headerIndex + 1

                -- Update assignment groups
                for i, group in ipairs(part.assignments) do
                    if not self.overviewMainRaidAssignmentGroups[groupIndex] then
                        self.overviewMainRaidAssignmentGroups[groupIndex] = createOverviewMainGroup(self.overviewMain)
                    end

                    local frame = self.overviewMainRaidAssignmentGroups[groupIndex]

                    updateOverviewMainGroup(frame, prevFrame, group, part.uuid, i)

                    prevFrame = frame
                    groupIndex = groupIndex + 1
                end
            end
        end
    end

    self:OverviewResize()
end

function AntiRaidTools:UpdateOverviewActiveGroups()
    for _, groupFrame in ipairs(self.overviewMainRaidAssignmentGroups) do
        local selectedEncounterId = self.db.profile.overview.selectedEncounterId
        local encounter = self.db.profile.data.encounters[selectedEncounterId]


        if encounter then
            for _, part in ipairs(encounter) do
                if part.uuid == groupFrame.uuid and part.strategy.type == 'BEST_MATCH' then
                    local activeGroups = self:GetActiveGroups(groupFrame.uuid)

                    if activeGroups then
                        for _, index in ipairs(activeGroups) do
                            if index == groupFrame.index then
                                groupFrame:SetBackdropColor(1, 1, 1, 0.6)
                            else
                                groupFrame:SetBackdropColor(0, 0, 0, 0)
                            end
                        end
                    else
                        groupFrame:SetBackdropColor(0, 0, 0, 0)
                    end
                    break
                end
            end
        end
    end    
end

function AntiRaidTools:UpdateOverviewSpells()
    for _, groupFrame in pairs(self.overviewMainRaidAssignmentGroups) do
        for _, assignmentFrame in pairs(groupFrame.assignments) do
            if self:IsSpellActive(assignmentFrame.player, assignmentFrame.spellId) then
                ActionButton_ShowOverlayGlow(assignmentFrame.iconFrame)
                assignmentFrame:SetAlpha(1)
            else
                ActionButton_HideOverlayGlow(assignmentFrame.iconFrame)

                if self:IsSpellReady(assignmentFrame.player, assignmentFrame.spellId) then
                    assignmentFrame:SetAlpha(1)
                else
                    assignmentFrame:SetAlpha(0.4)
                end
            end
        end
    end
end
