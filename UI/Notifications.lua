local insert = table.insert

local AntiRaidTools = AntiRaidTools

local SONAR_SOUND_FILE = "Interface\\AddOns\\AntiRaidTools\\Media\\PowerAuras_Sounds_Sonar.mp3"

function AntiRaidTools:NotificationsInit()
    local container = CreateFrame("Frame", "AntiRaidToolsNotification", UIParent, "BackdropTemplate")
    container:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    container:SetSize(250, 50)
    container:SetBackdrop({
        bgFile = "Interface\\Addons\\AntiRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    container:SetBackdropColor(0, 0, 0, 0)
    container:SetMovable(true)
    container:SetUserPlaced(true)
    container:SetClampedToScreen(true)
    container:RegisterForDrag("LeftButton")
    container:SetScript("OnDragStart", function(self) self:StartMoving() end)
    container:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    container.frameLockText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    container.frameLockText:SetFont("Fonts\\FRIZQT__.TTF", 14)
    container.frameLockText:SetTextColor(1, 1, 1, 0.4)
    container.frameLockText:SetPoint("CENTER", 0, 0)
    container.frameLockText:SetText("ART Notifications Anchor")
    container.frameLockText:Hide()

    local content = CreateFrame("Frame", nil, container)
    content:SetAllPoints()

    content.header = CreateFrame("Frame", nil, content, "BackdropTemplate")
    content.header:SetHeight(20)
    content.header:SetBackdrop({
        bgFile = "Interface\\Addons\\AntiRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32
    })
    content.header:SetBackdropColor(0.12, 0.56, 1, 1)
    content.header:SetPoint("TOPLEFT", 0, 0)
    content.header:SetPoint("TOPRIGHT", 0, 0)

    content.header.text = content.header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    content.header.text:SetFont("Fonts\\FRIZQT__.TTF", 10)
    content.header.text:SetTextColor(1, 1, 1, 1)
    content.header.text:SetPoint("BOTTOMLEFT", 10, 5)

    content.header.countdown = content.header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    content.header.countdown:SetFont("Fonts\\FRIZQT__.TTF", 10)
    content.header.countdown:SetTextColor(1, 1, 1, 1)
    content.header.countdown:SetPoint("BOTTOMRIGHT", -10, 5)
    content.header.countdown:Hide()

    content:Hide()

    local extraInfo = CreateFrame("Frame", nil, content, "BackdropTemplate")
    extraInfo:SetHeight(30)
    extraInfo:SetBackdrop({
        bgFile = "Interface\\Addons\\AntiRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    extraInfo:SetBackdropColor(0, 0, 0, 0.6)
    extraInfo.text = extraInfo:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    extraInfo.text:SetFont("Fonts\\ARIALN.TTF", 12)
    extraInfo.text:SetTextColor(1, 1, 1, 0.8)
    extraInfo.text:SetPoint("BOTTOMLEFT", 32, 8)
    extraInfo.text:SetWidth(200)
    extraInfo.text:SetJustifyH("LEFT")
    extraInfo.text:SetJustifyV("TOP")
    extraInfo.text:SetWordWrap(true)

    extraInfo:Hide()

    self.notificationFrameFadeOut = AntiRaidTools:CreateFadeOut(content, function()
        AntiRaidTools.notificationContentFrame:Hide()
    end)

    self.notificationShowId = ""

    self.notificationRaidAssignmentGroups = {}
    self.notificationsCountdown = 0

    self.notificationFrame = container
    self.notificationContentFrame = content
    self.notificationExtraInfoFrame = extraInfo
end

function AntiRaidTools:NotificationsToggleFrameLock(lock)
    if lock or self.notificationFrame:IsMouseEnabled() then
        self.notificationFrame:EnableMouse(false)
        self.notificationFrame:SetBackdropColor(0, 0, 0, 0)
        self.notificationFrame.frameLockText:Hide()
    else
        self.notificationFrame:EnableMouse(true)
        self.notificationFrame:SetBackdropColor(0, 0, 0, 0.6)
        self.notificationFrame.frameLockText:Show()
        self.notificationContentFrame:Hide()
    end
end

function AntiRaidTools:NotificationsIsFrameLocked()
    return not self.notificationFrame:IsMouseEnabled()
end

function AntiRaidTools:NotificationsUpdateHeader(text)
    self.notificationContentFrame.header.text:SetText(self:StringEllipsis(text, 32))
end

local function createNotificationGroup(mainFrame, prevFrame)
    local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    frame:SetHeight(30)
    frame:SetBackdrop({
        bgFile = "Interface\\Addons\\AntiRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    frame:SetBackdropColor(0, 0, 0, 0.6)

    frame.assignments = {}

    return frame
end

local function createNotificationGroupAssignment(parentFrame)
    local frame = CreateFrame("Frame", nil, parentFrame)

    frame.iconFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.iconFrame:SetSize(16, 16)
    frame.iconFrame:SetPoint("BOTTOMLEFT", 10, 6)

    frame.cooldownFrame = CreateFrame("Cooldown", nil, frame.iconFrame, "CooldownFrameTemplate")
    frame.cooldownFrame:SetAllPoints()

    frame.iconFrame.cooldown = frame.cooldownFrame

    frame.icon = frame.iconFrame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    frame.text:SetTextColor(1, 1, 1, 1)
    frame.text:SetPoint("BOTTOMLEFT", 32, 8)

    return frame
end

local function updateNotificationGroupAssignment(frame, assignment, index, total)
    frame:Show()

    frame.player = assignment.player
    frame.spellId = assignment.spell_id

    local _, _, icon = GetSpellInfo(assignment.spell_id)

    frame.icon:SetTexture(icon)
    frame.text:SetText(assignment.player)

    local color = AntiRaidTools:GetSpellColor(assignment.spell_id)

    frame.text:SetTextColor(color.r, color.g, color.b)

    frame.cooldownFrame:Clear()

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

local function updateNotificationGroup(frame, prevFrame, group, uuid, index)
    frame:Show()

    frame.uuid = uuid
    frame.index = index

    frame:ClearAllPoints()
    
    frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 0)
    frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 0)

    for _, cd in pairs(frame.assignments) do
        cd:Hide()
    end
    
    for i, assignment in ipairs(group) do
        if not frame.assignments[i] then
            frame.assignments[i] = createNotificationGroupAssignment(frame)
        end

        updateNotificationGroupAssignment(frame.assignments[i], assignment, i, #group)
    end
end

local function updateExtraInfo(frame, prevFrame, assignments, activeGroups)
    -- Use BETCH_MATCH recursivly to create list of follow ups. This list might not be
    -- the correct order in which assignments will be selected but its the best
    -- estimation we can do.
    local groups = {}

    local assignmentsClone = AntiRaidTools:ShallowCopy(assignments)

    local bestMatchIndex = AntiRaidTools:RaidAssignmentsSelectBestMatchIndex(assignmentsClone)
    if bestMatchIndex then assignmentsClone[bestMatchIndex] = nil end

    while bestMatchIndex do
        insert(groups, bestMatchIndex)

        bestMatchIndex = AntiRaidTools:RaidAssignmentsSelectBestMatchIndex(assignmentsClone)
        if bestMatchIndex then assignmentsClone[bestMatchIndex] = nil end
    end

    for _, index in ipairs(activeGroups) do
        for i, group in ipairs(groups) do
            if group == index then
                groups[i] = nil
            end
        end
    end

    local playersKeySet = {}

    for _, index in pairs(groups) do
        local group = assignments[index]

        if group then
            for _, assignment in ipairs(group) do
                if assignment.type == "SPELL" and AntiRaidTools:SpellsIsSpellReady(assignment.player, assignment.spell_id) then
                    insert(playersKeySet, assignment.player)
                end
            end
        end
    end

    local players={}

    for _, player in pairs(playersKeySet) do
        insert(players, player)
    end

    if #players > 0 then
        frame:Show()

        frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 0)
        frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 0)

        frame.text:SetText("→ " .. AntiRaidTools:StringJoin(players) .. " follow up.")

        frame:SetHeight(frame.text:GetStringHeight() + 10)
    end
end

local function updateCountdown(_, elapsed)
    AntiRaidTools.notificationsCountdown = AntiRaidTools.notificationsCountdown - elapsed

    if AntiRaidTools.notificationsCountdown > 0 then
        AntiRaidTools.notificationContentFrame.header.countdown:SetText(string.format("%.1fs", AntiRaidTools.notificationsCountdown))
    else
        AntiRaidTools.notificationContentFrame.header.countdown:SetText("0")
        AntiRaidTools.notificationContentFrame:SetScript("OnUpdate", nil)
        AntiRaidTools.notificationContentFrame.header.countdown:Hide()
    end
end

function AntiRaidTools:NotificationsShowRaidAssignment(uuid, countdown)
    local selectedEncounterId = self.db.profile.overview.selectedEncounterId
    local encounter = self.db.profile.data.encounters[selectedEncounterId]

    if self.db.profile.options.notifications.showOnlyOwnNotifications then
        local part = self:GetRaidAssignmentPart(uuid)

        if part then
            if part.strategy.type == "BEST_MATCH" and not self:IsPlayerInActiveGroup(part) then
                return
            end

            if part.strategy.type == "CHAIN" and not self:IsPlayerInAssignments(part.assignments) then
                return
            end
        end
    end

    self.notificationExtraInfoFrame:Hide()

    for _, group in pairs(self.notificationRaidAssignmentGroups) do
        group:Hide()
    end

    if encounter then            
        local groupIndex = 1
        local prevFrame = self.notificationContentFrame.header
        for _, part in pairs(encounter) do
            if part.type == "RAID_ASSIGNMENTS" and part.uuid == uuid then
                local activeGroups = self:GroupsGetActive(uuid)

                if not activeGroups then
                    return
                end
                
                self:NotificationsToggleFrameLock(true)
    
                self.notificationFrameFadeOut:Stop()
                self.notificationContentFrame:Show()
            
                if not self.db.profile.options.notifications.mute then
                    PlaySoundFile(SONAR_SOUND_FILE, "Master")
                end

                -- Update header
                local headerText

                if part.metadata.spell_id then
                    local name = GetSpellInfo(part.metadata.spell_id)
                    headerText = name
                else
                    headerText = part.metadata.name
                end

                self:NotificationsUpdateHeader(headerText)
                        
                if part.trigger.spell_id then
                    local _, _, _, castTime = GetSpellInfo(part.trigger.spell_id)
            
                    if castTime then
                        countdown = castTime / 1000
                    end
                end

                if part.trigger.countdown then
                    countdown = part.trigger.countdown
                end

                if countdown > 0 then
                    self.notificationsCountdown = countdown
                    self.notificationContentFrame.header.countdown:Show()
                    self.notificationContentFrame:SetScript("OnUpdate", updateCountdown)
                end

                local duration = 5

                local showId = self:GenerateUUID()
                self.notificationShowId = showId

                C_Timer.After(duration + countdown, function()
                    if showId == self.notificationShowId then
                        AntiRaidTools.notificationFrameFadeOut:Play()
                    end
                end)

                -- Update groups
                for _, index in ipairs(activeGroups) do
                    if not self.notificationRaidAssignmentGroups[groupIndex] then
                        self.notificationRaidAssignmentGroups[groupIndex] = createNotificationGroup(self.notificationContentFrame)
                    end

                    local frame = self.notificationRaidAssignmentGroups[groupIndex]

                    updateNotificationGroup(frame, prevFrame, part.assignments[index], part.uuid, i)

                    prevFrame = frame
                    groupIndex = groupIndex + 1
                end

                if part.strategy.type == "CHAIN" then
                    updateExtraInfo(self.notificationExtraInfoFrame, prevFrame, part.assignments, activeGroups)
                end

                break
            end
        end
    end
end

function AntiRaidTools:NotificationsUpdateSpells()
    for _, groupFrame in pairs(self.notificationRaidAssignmentGroups) do
        for _, assignmentFrame in pairs(groupFrame.assignments) do
            if self:SpellsIsSpellActive(assignmentFrame.player, assignmentFrame.spellId) then
                local castTimestamp = self:SpellsGetCastTimestamp(assignmentFrame.player, assignmentFrame.spellId)
                local spell = self:SpellsGetSpell(assignmentFrame.spellId)

                if castTimestamp and spell then
                    assignmentFrame.cooldownFrame:SetCooldown(castTimestamp, spell.duration)
                end

                assignmentFrame:SetAlpha(1)
            else
                if self:SpellsIsSpellReady(assignmentFrame.player, assignmentFrame.spellId) then
                    assignmentFrame:SetAlpha(1)
                else
                    assignmentFrame:SetAlpha(0.4)
                end
            end
        end
    end
end
