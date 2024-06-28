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

        DevTool:AddData(widget, "widget")

        --widget.frame.height = 300
        --widget:SetNumLines(50)
        --widget:SetHeight(400)
        --widget.scrollFrame:SetHeight(400)
        --widget.scrollFrame:SetNumLines(50)
        --widget.editBox:SetNumLines(30)
        --widget.scrollFrame:SetNumLines(30)

        function widget:Validate()
            local text = self:GetText()

            if text then
                text = text:trim()
            end
            
            if not text or text == "" then
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
    args =  {
        buttonGroup = {
            type = "group",
            inline = true,
            name = "",
            order = 1,
            args = {
                button1 = {
                    type = "execute",
                    name = "Toggle Overview",
                    desc = "Toggle the Overview visiblity.",
                    func = function()
                        AntiRaidTools.db.profile.overview.show = not AntiRaidTools.db.profile.overview.show
                        AntiRaidTools:UpdateOverview()
                    end,
                    order = 1,
                },
                button2 = {
                    type = "execute",
                    name = "Toggle Framelock",
                    desc = "Toggle framelock of the Notifications Anchor.",
                    func = function()
                        AntiRaidTools:RaidNotificationsToggleFrameLock()
                    end,
                    order = 2,
                },
            },
        },
        enableFeatureCheckbox = {
            type = "toggle",
            name = "Limit Raid Assignment Notificaions",
            desc = "Show only raid notifications that apply to you.",
            width = "full",
            order = 2,
            get = function() return AntiRaidTools.db.profile.options.notifications.showOnlyOwnNotifications end,
            set = function(_, value) AntiRaidTools.db.profile.options.notifications.showOnlyOwnNotifications = value end,
        },
        enableFeatureDescription = {
            type = "description",
            name = "Show only Raid Assignment Notifications that apply to you.",
            order = 3,
        },
    },
    -- args = {
    --     weakAuraHeader = {
    --         type = "header",
    --         name = "Anti Raid Tools Helper WeakAura",
    --         order = 1,
    --     },
    --     weakAuraText = {
    --         type = "description",
    --         name = "Certain features of Anti Raid Tools require the use of a Helper WeakAura. This WeakAura is required if you are the Raid Leader and set up assignments that are activated by other WeakAuras, such as Fojji timers.",
    --         order = 2,
    --     },
    --     separator = {
    --         type = "description",
    --         name = " ",
    --         order = 3,
    --     },
    --     weakAurasNotInstalledError = {
    --         type = "description",
    --         fontSize = "medium",
    --         name = "|cffff0000WeakAuras is not installed.|r",
    --         order = 4,
    --         hidden = function() return AntiRaidTools:IsWeakAurasInstalled() end
    --     },
    --     helperWeakAuraInstalledMessage = {
    --         type = "description",
    --         fontSize = "medium",
    --         name = "|cff00ff00Anti Raid Tools Helper WeakAura Installed.|r",
    --         order = 5,
    --         hidden = function() return not AntiRaidTools:IsHelperWeakauraInstalled() end
    --     },
    --     installWeakAuraButton = {
    --         type = "execute",
    --         name = "Install WeakAura",
    --         desc = "Install the Anti Raid Tools Helper WeakAura.",
    --         func = function() AntiRaidTools:InstallHelperWeakAura(function()
    --             LibStub("AceConfigRegistry-3.0"):NotifyChange("AntiRaidTools")
    --         end) end,
    --         order = 6,
    --         hidden = function() return not AntiRaidTools:IsWeakAurasInstalled() or AntiRaidTools:IsHelperWeakauraInstalled() end
    --     },
    -- },
}

local importDescription = [[
Paste your raid assignments and other import data below. The import should be valid YAML.

For the full Import API spec, visit https://github.com/gonstr/AntiRaidTools.
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
        import = {
            type = "input",
            name = "Import",
            desc = "Paste your import data here.",
            multiline = 25,
            width = "full",
            dialogControl = "ImportMultiLineEditBox",
            order = 2,
            get = function() return AntiRaidTools.db.profile.options.import end,
            set = function(_, val)
                if val then
                    val = val:trim()
                end

                AntiRaidTools.db.profile.options.import = val

                AntiRaidTools.db.profile.data.encounters = {}

                if val ~= nil and val ~= "" then
                    local _, result = AntiRaidTools:ImportYAML(val)
                    AntiRaidTools.db.profile.data.encounters = AntiRaidTools:GroupImportByEncounter(result)
                end

                if AntiRaidTools:IsPlayerRaidLeader() then
                    AntiRaidTools:SendRaidMessage("ENCOUNTERS", AntiRaidTools.db.profile.data.encounters)
                end

                -- Update overview after import
                AntiRaidTools:UpdateOverview()
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
