local AceGUI = LibStub("AceGUI-3.0")

local Type, Version = "AntiRaidToolsPlaceholder", 1

local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetHeight(200)
    frame:SetPoint("TOPLEFT", 0, 0)
    frame:SetPoint("TOPRIGHT", 0, 0)
    frame:Hide()

    frame.text = frame:CreateFontString(nil, "ARTWORK")
    frame.text:SetFont("Fonts/FRIZQT__.TTF", 12)
    frame.text:SetPoint("CENTER", 0, 0)

    local widget = {
        frame = frame,
        type = Type,
    }

    widget["OnAcquire"] = function(self)
        frame:Show()
    end

    widget["OnRelease"] = function(self)
        frame:Hide()
    end

    widget["SetFontObject"] = function(self, ...)
        frame.text:SetFontObject(...)
    end

    widget["SetText"] = function(self, text)
        frame.text:SetText(text)
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
