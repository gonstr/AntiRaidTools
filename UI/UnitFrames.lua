local addonName, addon = ...

local insert = table.insert
local remove = table.remove

local AceEvent = LibStub("AceEvent-3.0")
local LGF = LibStub("LibGetFrame-1.0")
local LCG = LibStub("LibCustomGlow-1.0")

addon.UnitFramesPrototype = {}

local UnitFrames = addon.UnitFramesPrototype
UnitFrames.__index = UnitFrames

function UnitFrames:New(db)
    local instance = setmetatable({}, self)

    instance.db = db

    AceEvent:Embed(instance)

    instance:RegisterEvent("ENCOUNTER_START")
    instance:RegisterEvent("ENCOUNTER_END")
    instance:RegisterMessage("ART_TRIGGER")

    -- key = unitId, values = list of icons/glows
    instance.frameIcons = {}
    instance.frameGlows = {}

    instance.triggerCache = {}

    instance:Reset()

    LGF:ScanForUnitFrames()

    return instance
end

function UnitFrames:Stop()
    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterMessage("ART_TRIGGER")
end

function UnitFrames:Reset()
    addon:Debug("Sounds:Reset")

    for _, icons in pairs(self.frameIcons) do
        for _, icon in ipairs(icons) do
            icon.expirationTime = 0
        end
    end

    for _, glows in pairs(self.frameGlows) do
        for _, glow in ipairs(glows) do
            glow.expirationTime = 0
        end
    end

    self:Update()

    self.triggerCache = {}
end

function UnitFrames:Update()
    -- Icons, pass 1
    for _, icons in pairs(self.frameIcons) do
        for i, icon in ipairs(icons) do
            if icon.frame and icon.expirationTime <= GetTime() then
                icon.frame:Release()

                remove(icons, i)
            else
                if not icon.frame then
                    -- Only create frame once
                    icon.frame = addon.frameFactory:AcquireFrame("icon")
                end

                local unitFrame = LGF.GetFrame(icon.unitId)

                if unitFrame then
                    icon.frame:GetFrame():SetParent(unitFrame)
                    icon.frame:GetFrame():SetFrameLevel(10000)
                end

                if icon.duration and icon.icon then
                    if icon.hideCooldown then
                        icon.frame:SetData(icon.icon)
                    else
                        icon.frame:SetData(icon.icon, icon.duration, icon.expirationTime)
                    end
                else
                    -- No duration set, try finding aura by spellId
                    if icon.spellId then
                        local aura = addon.utils:GetUnitAuraBySpellId(icon.unitId, icon.spellId)

                        if aura then
                            if icon.hideCooldown then
                                icon.frame:SetData(aura.icon)
                            else
                                icon.frame:SetData(aura.icon, aura.duration, aura.expirationTime)
                            end
                            icon.expirationTime = aura.expirationTime
                        end
                    end
                end

                if icon.updateFunc then
                    icon.updateFunc:Cancel()
                end

                icon.updateFunc = C_Timer.After(icon.expirationTime - GetTime(), function() self:Update() end)
            end
        end
    end

    -- Icons, pass 2 (Positioning)
    for unitId, icons in pairs(self.frameIcons) do
        local unitFrame = LGF.GetFrame(unitId)

        if unitFrame then
            addon.utils:SetGridOffsets(addon.utils:TableMap(icons, function(icon) return icon.frame:GetFrame() end), unitFrame, 2)
        end
    end

    -- Glows
    for _, glows in pairs(self.frameGlows) do
        for i, glow in ipairs(glows) do
            if glow.unitFrame and glow.expirationTime <= GetTime() then
                if glow.glow == "AUTOCAST" then
                    LCG.AutoCastGlow_Stop(glow.unitFrame)
                elseif glow.glow == "BUTTON" then
                    LCG.ButtonGlow_Stop(glow.unitFrame)
                elseif glow.glow == "PIXEL" then
                    LCG.PixelGlow_Stop(glow.unitFrame)
                end

                remove(glows, i)
            else
                glow.unitFrame = LGF.GetFrame(glow.unitId)
            
                if not glow.autocastGlowActive and glow.glow == "AUTOCAST" then
                    LCG.AutoCastGlow_Start(glow.unitFrame, glow.color)
                    glow.autocastGlowActive = true
                elseif not glow.buttonGlowActive and glow.glow == "BUTTON" then
                    LCG.ButtonGlow_Start(glow.unitFrame, glow.color)
                    glow.buttonGlowActive = true
                elseif not glow.pixelGlowActive and glow.glow == "PIXEL" then
                    LCG.PixelGlow_Start(glow.unitFrame, glow.color)
                    glow.pixelGlowActive = true
                end

                if not glow.duration then
                    -- No duration set, try finding aura by spellId
                    if glow.spellId then
                        local aura = addon.utils:GetUnitAuraBySpellId(glow.unitId, glow.spellId)

                        if aura then
                            glow.expirationTime = aura.expirationTime
                        end
                    end
                end

                if glow.updateFunc then
                    glow.updateFunc:Cancel()
                end

                glow.updateFunc = C_Timer.After(glow.expirationTime - GetTime(), function() self:Update() end)
            end
        end
    end
end

function UnitFrames:ENCOUNTER_START(_, encounterId)
    addon:Debug("UnitFrames:ENCOUNTER_START", encounterId)

    self:Reset()

    -- Populate cache
    for _, pack in pairs(self.db.profile.v1.packs) do
        for _, item in ipairs(pack.items) do
            if addon.utils:TableContains({ "UNIT_FRAME_ICON", "UNIT_FRAME_GLOW" }, item.type) and item.encounter == encounterId then
                if not self.triggerCache[item.trigger] then
                    self.triggerCache[item.trigger] = {}
                end

                insert(self.triggerCache[item.trigger], item)
            end
        end
    end
end

function UnitFrames:ENCOUNTER_END()
    addon:Debug("UnitFrames:ENCOUNTER_END")

    self:Reset()
end

function UnitFrames:GetUnitIdByCtx(ctx)
    addon:Debug("UnitFrames:GetUnitIdByCtx", ctx)

    if ctx.trigger.unitId then
        return ctx.trigger.unitId
    end

    if ctx.trigger.destName then
        return addon.utils:GetUnitIDByName(ctx.trigger.destName) 
    end
end

function UnitFrames:FindFrameIcon(unitId, fields)
    addon:Debug("UnitFrames:FindFrameIcon", { unitId = unitId, fields = fields })

    if unitId then
        local icons = self.frameIcons[unitId]

        if icons then
            for _, icon in ipairs(icons) do
                local fieldsMatch = true
                
                for k, v in pairs(fields) do
                    if icon[k] ~= v then
                        fieldsMatch = false
                        break
                    end
                end

                if fieldsMatch then
                    return icon
                end
            end
        end
    end
end

function UnitFrames:ART_TRIGGER(_, trigger)
    addon:Debug("UnitFrames:ART_TRIGGER", trigger)

    local items = self.triggerCache[trigger.id]

    if items then
        for _, item in ipairs(items) do
            if addon.utils:InterpolateIf(item, trigger.ctx) then
                if trigger.untrigger then
                    -- Untrigger
                    local unitId = self:GetUnitIdByCtx(trigger.ctx)

                    if unitId then
                        if item.type == "UNIT_FRAME_GLOW" then
                            local glows = self.frameGlows[unitId]

                            if glows then
                                for _, glow in ipairs(glows) do
                                    if glow.glow == item.glow then
                                        glow.expirationTime = 0
                                    end
                                end
                            end
                        elseif item.type == "UNIT_FRAME_ICON" then
                            local icons = self.frameIcons[unitId]

                            if icons then
                                for _, icon in ipairs(icons) do
                                    if icon.spellId == trigger.ctx.trigger.spellId then
                                        icon.expirationTime = 0
                                    end
                                end
                            end
                        end
                    end
                else
                    -- Trigger
                    local unitId = self:GetUnitIdByCtx(trigger.ctx)

                    if unitId then
                        if item.type == "UNIT_FRAME_GLOW" then
                            if not self.frameGlows[unitId] then
                                self.frameGlows[unitId] = {}
                            end

                            insert(self.frameGlows[unitId], {
                                type = item.type,
                                unitId = unitId,
                                spellId = trigger.ctx.trigger.spellId,
                                glow = item.glow,
                                color = item.color,
                                duration = trigger.duration,
                                expirationTime = GetTime() + (trigger.duration or 5),
                            })
                        elseif item.type == "UNIT_FRAME_ICON" then
                            local existingIconEffect = self:FindFrameIcon(unitId, {
                                type = "UNIT_FRAME_ICON",
                                spellId = trigger.ctx.trigger.spellId
                            })

                            if existingIconEffect then
                                existingIconEffect.duration = 5
                                existingIconEffect.expirationTime = GetTime() + 5
                            else
                                if not self.frameIcons[unitId] then
                                    self.frameIcons[unitId] = {}
                                end

                                insert(self.frameIcons[unitId], {
                                    type = item.type,
                                    unitId = unitId,
                                    spellId = trigger.ctx.trigger.spellId,
                                    duration = 5,
                                    hideCooldown = item.hideCooldown,
                                    icon = item.icon,
                                    expirationTime = GetTime() + 5,
                                })

                                -- Ensure there is only a maximum of four icons
                                while #self.frameIcons[unitId] > 4 do
                                    self.frameIcons[unitId][1].expirationTime = 0
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    self:Update()
end
