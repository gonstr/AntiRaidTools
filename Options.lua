local AntiRaidTools = AntiRaidTools

local AceGUI = LibStub("AceGUI-3.0")

do
    local Type = "ImportMultiLineEditBox"
    local Version = 1

    local function Constructor()
        local widget = AceGUI:Create("MultiLineEditBox")
        --widget.frame:SetHeight(400)

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

        -- Validation function
        function widget:Validate()
            local text = self:GetText()

            if text == nil or string.len(text) == 0 then
                return false
            end

            local ok, result = pcall(AntiRaidTools.YAML.evalm, text)

            if not ok then
                self.errorLabel:SetText("ParseError: " .. result or "Invalid import.")
                return false
            end

            for _, part in ipairs(result) do
                if type(part) ~= "table" then
                    self.errorLabel:SetText("ParseError: Invalid import.")
                    return false
                end
            end

            for _, part in ipairs(result) do
                local ok, result = AntiRaidTools:ValidateImports(result)

                if not ok then
                    self.errorLabel:SetText("Invalid import: " .. result) 
                    return false
                end
            end

            self.errorLabel:SetText("")
            return true
        end

        -- Validate on text changed
        widget.editBox:HookScript("OnTextChanged", function()
            if widget.button then
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

-- AceDB defaults
AntiRaidTools.defaults = {
    profile = {},
}

local getOpt, setOpt
do
	function getOpt(info)
		local key = info[#info]
		return AntiRaidTools.db.profile[key]
	end

	function setOpt(info, value)
		local key = info[#info]
		AntiRaidTools.db.profile[key] = value
	end
end

local options = {
    type = 'group',
    args = {
        unlock = {
            type = "execute",
            name = "Toggle Frame Lock",
            desc = "Unlock the Frames to be able to move them around.",
            func = function()
                AntiRaidTools:ToggleFrameLock(false)
            end,
            order = 1,
        },
        importHeader = {
            type = "header",
            name = "Import",
            order = 2,
        },
        importText = {
            type = "input",
            name = "Import Data",
            desc = "Paste your import data here.",
            multiline = true,
            width = "full",
            dialogControl = "ImportMultiLineEditBox",
            order = 3,
            get = getOpt,
            set = setOpt,
        },
    },
}

function AntiRaidTools:InitOptions()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("AntiRaidTools", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AntiRaidTools", "Anti Raid Tools")

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
