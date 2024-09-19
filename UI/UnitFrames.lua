local addonName, addon = ...

local insert = table.insert

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

    self.triggerCache = {}
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

function UnitFrames:ART_TRIGGER(_, trigger)
    addon:Debug("UnitFrames:ART_TRIGGER", trigger)

    local items = self.triggerCache[trigger.id]

    if items then
        for _, item in ipairs(items) do
            if item.type == "UNIT_FRAME_GLOW" then
                local unitId = trigger.ctx.trigger.unitId
                local destName = trigger.ctx.trigger.destName

                if not unitId and destName then
                    unitId = addon.utils:GetUnitIDByName(destName)
                end

                if unitId then
                    local frame = LGF.GetFrame(unitId)

                    if frame then
                        if item.glow == "AUTOCAST" then
                            LCG.AutoCastGlow_Start(frame, item.color)
                        elseif item.glow == "BUTTON" then
                            LCG.ButtonGlow_Start(frame, item.color)
                        elseif item.glow == "PIXEL" then
                            LCG.PixelGlow_Start(frame, item.color)
                        end

                        C_Timer.After(5, function()
                            LCG.AutoCastGlow_Stop(frame)
                            LCG.ButtonGlow_Stop(frame)
                            LCG.PixelGlow_Stop(frame)
                        end)
                    end
                end
            end
        end
    end
end
