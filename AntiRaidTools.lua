local addonName, addon = ...

local insert = table.insert
local remove = table.remove

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceConsole-3.0", "AceEvent-3.0")

addon.VERSION = GetAddOnMetadata("AntiRaidTools", "Version")
addon.IS_DEV = addon.VERSION == '\@project-version\@'
addon.DEBUG = false

addon.MESSAGES = {
    ART_TOGGLE_FRAME_LOCK = "ART_TOGGLE_FRAME_LOCK",
    ART_TRIGGER = "ART_TRIGGER"
}

-- AceDB defaults
addon.defaults = {
    profile = {
        v1 = {
            options = {
                import = "",
                -- notifications = {
                --     showOnlyOwnNotifications = false,
                --     mute = false
                -- }
                
            },
            packOptions = {},
            packs = {}
        }
        -- data = {
        --     encountersProgress = nil,
        --     encountersId = nil,
        --     encounters = {}
        -- },
        -- minimap = {},
        -- overview = {
        --     selectedEncounterId = nil,
        --     locked = false,
        --     show = true
        -- }
    },
}

function addon:OnInitialize()
    self.db = self.db or LibStub("AceDB-3.0"):New(addonName, self.defaults)

    self.utils = self.UtilsPrototype:New()
    self.jsonParser = self.JsonParserPrototype:New()
    self.base64Parser = self.Base64ParserPrototype:New()
    self.importParser = self.ImportParserPrototype:New()
    self.importValidator = self.ImportValidatorPrototype:New()
    self.import = self.ImportPrototype:New()
    self.options = self.OptionsPrototype:New(self.db)
    self.minimap = self.MinimapPrototype:New(self.db)
    self.frameFactory = self.FrameFactoryPrototype:New()
    self.animations = self.AnimationBuilderPrototype:New()
end

function addon:OnEnable()
    self.ui = {
        eventsContainer = self.frameFactory:AcquireFrame("container", "ARTEventsFrame"),
        specialsContainer = self.frameFactory:AcquireFrame("container", "ARTSpecialsFrame"),
        events = self.frameFactory:AcquireFrame("events")
    }

    self.ui.eventsContainer:SetData("Events", 300, 190, "CENTER", 0, 160)
    self.ui.specialsContainer:SetData("Boss Specials", 300, 100, "TOP", 0, -60)

    self.ui.events:SetData(self.db)
    self.ui.events:GetFrame():SetAllPoints(self.ui.eventsContainer:GetFrame())

    self.controllers = {
        encounter = self.EncounterControllerPrototype:New(self.db),
        sounds = self.SoundsPrototype:New(self.db),
        comms = self.CommsPrototype:New(self.db),
        unitFrames = self.UnitFramesPrototype:New(self.db)
    }
    
    self:RegisterMessage(self.MESSAGES.ART_TOGGLE_FRAME_LOCK)

    self:RegisterChatCommand("art", "HandleChatCommand")
end

function addon:OnDisable()
    for _, frame in pairs(self.ui) do
        frame:Release()
    end

    for _, controller in pairs(self.controllers) do
        controller:Stop()
    end

    self:UnregisterMessage(self.MESSAGES.ART_TOGGLE_FRAME_LOCK)

    self:UnregisterChatCommand("art")
end

function addon:ART_TOGGLE_FRAME_LOCK()
    -- Just get the lock state of one of the frames
    local areFramesLocked = self.ui.eventsContainer:IsFrameLocked()

    self.ui.eventsContainer:SetFrameLock(not areFramesLocked)
    self.ui.specialsContainer:SetFrameLock(not areFramesLocked)
end

function addon:HandleChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory("Anti Raid Tools")
    else
        input = input:trim()

        if input == "debug" then
            self.DEBUG = true
            self:Print("Debug:", self.DEBUG)
        elseif input == "teststart" then
            self:TestStart()
        elseif input == "testend" then
            self:TestEnd()
        end
    end
end

function addon:Debug(name, obj)
    if self.DEBUG then
        self:Print(name .. ":", obj)

        if DevTool then
            DevTool:AddData(obj or name, name)
        end
    end 
end

function addon:TestStart()
    self.controllers.encounter:ENCOUNTER_START(nil, 1035)
    self.controllers.sounds:ENCOUNTER_START(nil, 1035)
    self.controllers.comms:ENCOUNTER_START(nil, 1035)
    self.controllers.unitFrames:ENCOUNTER_START(nil, 1035)
    self.ui.events:ENCOUNTER_START(nil, 1035)

    C_Timer.After(2, function()
        self.controllers.encounter:HandleSpellCast("SPELL_CAST_START", 77679, nil, "Maloriak", nil, "Anticipâte")
    end)

    C_Timer.After(4, function()
        self.controllers.encounter:HandleSpellCast("SPELL_CAST_START", 78225, nil, "Maloriak", nil, "Mage")
    end)

    C_Timer.After(5, function()
        self.controllers.encounter:HandleSpellCast("SPELL_CAST_START", 78225, nil, "Maloriak", nil, "Mage")
    end)

    C_Timer.After(7, function()
        self.controllers.encounter:HandleSpellCast("SPELL_CAST_START", 77679, nil, "Maloriak", nil, "Rayemental")
    end)

    -- C_Timer.After(4, function()
    --     self.controllers.encounter:RAID_BOSS_EMOTE(nil, "throws a |cff5599FFdark|r magic into the cauldron!")
    -- end)
end

function addon:TestEnd()
    self.controllers.encounter:ENCOUNTER_END()
    self.controllers.sounds:ENCOUNTER_END()
    self.controllers.comms:ENCOUNTER_END()
    self.controllers.unitFrames:ENCOUNTER_END()
    self.ui.events:ENCOUNTER_END()
end
