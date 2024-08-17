local AntiRaidTools = AntiRaidTools

local AceGUI = LibStub("AceGUI-3.0")

local Type, Version = "AntiRaidToolsImport", 1

local function Constructor()
    -- Create a basic frame
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(200, 100)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })

    -- Create buttons
    local button1 = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button1:SetPoint("TOPLEFT", 10, -10)
    button1:SetSize(80, 22)

    local button2 = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button2:SetPoint("TOPLEFT", button1, "TOPRIGHT", 10, 0)
    button2:SetSize(80, 22)

    -- Define the widget object
    local widget = {
        frame = frame,
        button1 = button1,
        button2 = button2,
        type = Type,
    }

    -- Set methods required by AceGUI
    widget["OnAcquire"] = function(self)
        -- Called when the widget is acquired from the widget pool
        local data = self:GetUserData("arg")  -- Get the data passed via the `arg` field
        self:SetData(data)  -- Use the SetData method to apply the data to the widget
    end

    widget["OnRelease"] = function(self)
        -- Called when the widget is released back to the widget pool
    end

    widget["SetText"] = function(self)
        -- Called when the widget is released back to the widget pool
    end

    -- Method to handle the passed data
    widget["SetData"] = function(self, data)
        DevTool:AddData(self, "self")
        DevTool:AddData(data, "data")
        if data then
            self.button1:SetText(data.button1Text or "Button 1")
            self.button2:SetText(data.button2Text or "Button 2")

            -- You can also attach handlers or other data here
            if data.onClick1 then
                self.button1:SetScript("OnClick", data.onClick1)
            end
            if data.onClick2 then
                self.button2:SetScript("OnClick", data.onClick2)
            end
        end
    end

    -- Register the widget
    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
