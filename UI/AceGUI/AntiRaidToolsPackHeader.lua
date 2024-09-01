local AceGUI = LibStub("AceGUI-3.0")

local Type, Version = "AntiRaidToolsPackHeader", 1

local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetHeight(100)
    frame:SetPoint("TOPLEFT", 0, 0)
    frame:SetPoint("TOPRIGHT", 0, 0)
    frame:SetBackdrop({
        bgFile = nil,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
        edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    local inner = CreateFrame("Frame", nil, frame)
    inner:SetPoint("TOPLEFT", 4, -4)
    inner:SetPoint("BOTTOMRIGHT", -4, 4)

    inner.texture = inner:CreateTexture()
    inner.texture:SetVertexColor(0.5, 0.5, 0.5)
    inner.texture:SetAllPoints(inner)

    inner.header = inner:CreateFontString(nil, "ARTWORK")
    inner.header:SetFont("Fonts/FRIZQT__.TTF", 16)
    inner.header:SetPoint("TOPLEFT", 10, -10)

    inner.version = inner:CreateFontString(nil, "ARTWORK")
    inner.version:SetAlpha(0.6)
    inner.version:SetFont("Fonts/FRIZQT__.TTF", 12)
    inner.version:SetPoint("TOPLEFT", 10, -30)

    inner.author = inner:CreateFontString(nil, "ARTWORK")
    inner.author:SetFont("Fonts/FRIZQT__.TTF", 12)
    inner.author:SetPoint("BOTTOMLEFT", 10, 10)

    frame:Hide()

    local widget = {
        frame = frame,
        type = Type,
    }

    widget["OnAcquire"] = function(self)
        C_Timer.After(0, function()
            local user = self:GetUserDataTable()
    
            if user and user.option and user.option.arg then
                local arg = user.option.arg

                if arg.headerTexture then
                    inner.texture:SetTexture(arg.headerTexture)
                end
                
                if arg.headerTexCords then
                    inner.texture:SetTexCoord(unpack(arg.headerTexCords))                    
                end

                if arg.header then
                    inner.header:SetText(arg.header)
                end

                if arg.version then
                    inner.version:SetText(arg.version)
                end

                if arg.author then
                    inner.author:SetText("by " .. arg.author)
                end
            end
        end)

        frame:Show()
    end

    widget["OnRelease"] = function(self)
        frame:Hide()
    end

    widget["SetText"] = function()
       -- Do nothing
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
