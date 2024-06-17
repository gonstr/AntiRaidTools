local AntiRaidTools = AntiRaidTools
local insert = table.insert

local AceGUI = LibStub("AceGUI-3.0")

do
    local Type = "ImportMultiLineEditBox"
    local Version = 1

    local function Constructor()
        local widget = AceGUI:Create("MultiLineEditBox")
        widget.button:Disable()

        -- Error label
        -- TODO: Improve this.
        -- This error label is floating beneth the windows.
        -- Only works if there's nothing below the input.
        local errorLabel = widget.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        errorLabel:SetPoint("TOPLEFT", widget.frame, "BOTTOMLEFT", 0, -2)
        errorLabel:SetPoint("TOPRIGHT", widget.frame, "BOTTOMRIGHT", 0, -2)
        errorLabel:SetHeight(20)
        errorLabel:SetJustifyH("LEFT")
        errorLabel:SetJustifyV("TOP")
        errorLabel:SetTextColor(1, 0, 0) -- Red
        errorLabel:SetText("")
        widget.errorLabel = errorLabel

        function widget:Validate()
            local text = self:GetText()

            if text == nil or text == "" then
                return true
            end

            local ok, result = AntiRaidTools:ImportYAML(text)

            if not ok then
                self.errorLabel:SetText(result)
                return false
            end

            self.errorLabel:SetText("")
            return true
        end

        -- Validate on text changed
        widget.editBox:HookScript("OnTextChanged", function(_, userInput)
            if userInput then
                if widget:Validate() then
                    widget.button:Enable()
                else
                    widget.button:Disable()
                end
            end
        end)

        return widget
    end

    AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

local mainOptions = {
    name = "Anti Raid Tools v1-beta",
    type = "group",
    args = {
        weakAuraHeader = {
            type = "header",
            name = "Anti Raid Tools Helper WeakAura",
            order = 1,
        },
        weakAuraText = {
            type = "description",
            name = "Certain features of Anti Raid Tools require the use of a Helper WeakAura. This WeakAura is required if you are the Raid Leader and set up assignments that are activated by other WeakAuras, such as Fojji timers.",
            order = 2,
        },
        separator = {
            type = "description",
            name = " ",
            order = 3,
        },
        weakAurasNotInstalledError = {
            type = "description",
            fontSize = "medium",
            name = "|cffff0000WeakAuras is not installed.|r",
            order = 4,
            hidden = function() return AntiRaidTools:IsWeakAurasInstalled() end
        },
        helperWeakAuraInstalledMessage = {
            type = "description",
            fontSize = "medium",
            name = "|cff00ff00Anti Raid Tools Helper WeakAura Installed.|r",
            order = 5,
            hidden = function() return not AntiRaidTools:IsHelperWeakauraInstalled() end
        },
        installWeakAuraButton = {
            type = "execute",
            name = "Install WeakAura",
            desc = "Install the Anti Raid Tools Helper WeakAura.",
            func = function() AntiRaidTools:InstallHelperWeakAura(function()
                LibStub("AceConfigRegistry-3.0"):NotifyChange("AntiRaidTools")
            end) end,
            order = 6,
            hidden = function() return not AntiRaidTools:IsWeakAurasInstalled() or AntiRaidTools:IsHelperWeakauraInstalled() end
        },
    },
}

local importDescription = [[
Paste your raid assignments and other import data below. The import should be valid YAML.

Example import:

]]

local importCodeExample = [[
type: RAID_CDS
encounter: 1030
trigger: { type: FOJJI_NUMEN_TIMER, key: HALFUS_PROTO_BREATH }
spell_id: 83707
strategy: BEST_MATCH
assignments:
- [{ player: Anticipâte, spell_id: 31821 }, { player: Kondec, spell_id: 62618 }]
- [{ player: Venmir, spell_id, 98008 }]
---
type: RAID_CDS
encounter: 1024
trigger: { type: UNIT_HEALTH, unit: boss1, percentage: 35 }
strategy: CD_CHAIN
assignments:
- [{ player: Anticipâte, spell_id: 31821 }]
- [{ player: Kondec, spell_id: 62618 }]
- [{ player: Venmir, spell_id: 98008 }]
]]

local importOptions = {
    name = "Import",
    type = "group",
    args = {
        description = {
            type = "description",
            name = importDescription,
            fontSize = "medium",
            order = 1,
        },
        codeExample = {
            type = "description",
            name = importCodeExample,
            fontSize = "small",
            order = 2,
        },
        import = {
            type = "input",
            name = "Import",
            desc = "Paste your import data here.",
            multiline = true,
            width = "full",
            dialogControl = "ImportMultiLineEditBox",
            order = 3,
            get = function() return AntiRaidTools.db.profile.options.import end,
            set = function(_, val)
                AntiRaidTools.db.profile.options.import = val

                AntiRaidTools.db.profile.data.encounters = {}

                if val ~= nil and val ~= "" then
                    local _, result = AntiRaidTools:ImportYAML(val)
                    AntiRaidTools.db.profile.data.encounters = AntiRaidTools:GroupImportByEncounter(result)
                end

                AntiRaidTools:OnImport()
            end,
        },
    },
}

function AntiRaidTools:InitOptions()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("AntiRaidTools", mainOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AntiRaidTools", "Anti Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("AntiRaidTools Import", importOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AntiRaidTools Import", "Import", "Anti Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("AntiRaidTools Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AntiRaidTools Profiles", "Profiles", "Anti Raid Tools")
end

function AntiRaidTools:ToggleFrameLock(lock) end

function AntiRaidTools:OnConfigChanged()
    AntiRaidTools:UpdatePartyFramesVisibility(self.db.profile.hideBlizPartyFrame)
    AntiRaidTools:UpdateArenaFramesVisibility(self.db.profile.hideBlizArenaFrame)
    AntiRaidTools:UpdateAuraDurationsVisibility()
end

AntiRaidTools:RegisterChatCommand("art", function()
    LibStub("AceConfigDialog-3.0"):Open("AntiRaidTools")
end)
