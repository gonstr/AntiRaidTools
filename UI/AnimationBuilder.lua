local addonName, addon = ...

local insert = table.insert
local remove = table.remove

local AnimationFunctions = {
    LINEAR = function(t) return t end,
    STEP = function(t) return (t >= 1) and 1 or 0 end,

    EASE_IN = function(t) return t * t end,
    EASE_OUT = function(t) return t * (2 - t) end,
    EASE_IN_OUT = function(t) return (t < 0.5) and (2 * t * t) or (-1 + (4 - 2 * t) * t) end,

    CUBIC_EASE_IN = function(t) return t * t * t end,
    CUBIC_EASE_OUT = function(t) return (t - 1) * (t - 1) * (t - 1) + 1 end,
    CUBIC_EASE_IN_OUT = function(t) return (t < 0.5) and (4 * t * t * t) or ((t - 1) * (2 * t - 2) * (2 * t - 2) + 1) end,

    BOUNCE_OUT = function(t)
        if t < (1 / 2.75) then return 7.5625 * t * t
        elseif t < (2 / 2.75) then t = t - (1.5 / 2.75); return 7.5625 * t * t + 0.75
        elseif t < (2.5 / 2.75) then t = t - (2.25 / 2.75); return 7.5625 * t * t + 0.9375
        else t = t - (2.625 / 2.75); return 7.5625 * t * t + 0.984375 end
    end,

    SINUSOIDAL_IN = function(t) return 1 - math.cos((t * math.pi) / 2) end,
    SINUSOIDAL_OUT = function(t) return math.sin((t * math.pi) / 2) end,
    SINUSOIDAL_IN_OUT = function(t) return 0.5 * (1 - math.cos(math.pi * t)) end,

    EXPONENTIAL_IN = function(t) return (t == 0) and 0 or math.pow(2, 10 * (t - 1)) end,
    EXPONENTIAL_OUT = function(t) return (t == 1) and 1 or 1 - math.pow(2, -10 * t) end,
    EXPONENTIAL_IN_OUT = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return (t < 0.5) and 0.5 * math.pow(2, 20 * t - 10) or -0.5 * math.pow(2, -20 * t + 10) + 1
    end,

    PULSE = function(t) return 0.5 + 0.5 * math.sin(2 * math.pi * t) end,
}

local AnimationPrototype = {}

local Animation = AnimationPrototype
Animation.__index = Animation

function Animation:New(id, setter, startVal, endVal, duration, loop, animFunc)
    local instance = setmetatable({}, self)

    instance.id = id
    instance.setter = setter
    instance.startVal = startVal
    instance.endVal = endVal
    instance.duration = duration
    instance.loop = loop
    instance.animFunc = AnimationFunctions[animFunc]

    instance.startTime = GetTime()
    instance.endTime = GetTime() + duration

    return instance
end

function Animation:Animate()
    local currentTime = GetTime()

    if self.loop then
        -- Continuous animation
        local elapsed = currentTime - self.startTime
        local progress = (elapsed / self.duration) % 1  -- Loop progress between 0 and 1

        -- Interpolate based on continuous progress
        local currentValue = self.startVal + (self.endVal - self.startVal) * self.animFunc(progress)
        
        self.setter(currentValue)

        return false 
    else
        if currentTime >= self.endTime then
            self.setter(self.endVal)
            return true
        end
    
        local elapsed = currentTime - self.startTime
        local progress = elapsed / self.duration
    
        -- Interpolate between start and end values
        local currentValue = self.startVal + (self.endVal - self.startVal) * self.animFunc(progress) 
    
        self.setter(currentValue)
    
        return false
    end
end

addon.AnimationBuilderPrototype = {}

local AnimationBuilder = addon.AnimationBuilderPrototype
AnimationBuilder.__index = AnimationBuilder

function AnimationBuilder:New()
    local instance = setmetatable({}, self)

    instance.frame = CreateFrame("Frame", nil, UIParent)

    instance.animations = {}

    instance.frame:SetScript("OnUpdate", function()
        for i, animation in ipairs(instance.animations) do
            if animation:Animate() then
                remove(instance.animations, i)
            end
        end
    end)

    return instance
end

-- Durarion = 0 means continues animation
function AnimationBuilder:Animate(id, setter, startVal, endVal, duration, loop, animFunc)
    addon:Debug("AnimationBuilder:Animate", id)

    assert(AnimationFunctions[animFunc] ~= nil)

    -- Cancel any pending animations with the same id
    self:Cancel(id)

    insert(self.animations, AnimationPrototype:New(id, setter, startVal, endVal, duration, loop, animFunc))
end

function AnimationBuilder:Cancel(animationId)
    for i, animation in ipairs(self.animations) do
        if animation.id == animationId then
            remove(self.animations, i)
            break
        end
    end
end

local function ensureUUID(table, suffix)
    if not table.uuid then
        table.uuid = addon.utils:GenerateUUID()
    end
end

function AnimationBuilder:AnimateFrame(frame, setter, startVal, endVal, duration, loop, animFunc)
    addon:Debug("AnimationBuilder:AnimateFrame")

    ensureUUID(frame)

    animFunc = animFunc or "LINEAR"
    local animationId = frame.uuid .. "-default"

    self:Animate(animationId, setter, startVal, endVal, duration, loop, animFunc)
end

function AnimationBuilder:AnimateFrameAlpha(frame, startVal, endVal, duration, animFunc)
    addon:Debug("AnimationBuilder:AnimateFrameAlpha")

    ensureUUID(frame)

    animFunc = animFunc or "SINUSOIDAL_IN"
    local animationId = frame.uuid .. "-alpha"

    self:Animate(animationId, function(val) frame:SetAlpha(val) end, startVal, endVal, duration, false, animFunc)
end

function AnimationBuilder:AnimateFramePoint(frame, point, refFrame, startVal, endVal, duration, animFunc)
    addon:Debug("AnimationBuilder:AnimateFramePoint")

    ensureUUID(frame)

    animFunc = animFunc or "SINUSOIDAL_IN_OUT"
    local setter = function(val) frame:SetPoint(point, refFrame, point, 0, val) end
    local animationId = frame.uuid .. "-point-" .. point

    self:Animate(animationId, setter, startVal, endVal, duration, false, animFunc)
end

function AnimationBuilder:AnimateFrameWidth(frame, startVal, endVal, duration, animFunc)
    addon:Debug("AnimationBuilder:AnimateFrameWidth")

    ensureUUID(frame)

    animFunc = animFunc or "LINEAR"
    local setter = function(val) frame:SetWidth(val) end
    local animationId = frame.uuid .. "-width"

    self:Animate(animationId, setter, startVal, endVal, duration, false, animFunc)
end

function AnimationBuilder:AnimateFrameHeight(frame, startVal, endVal, duration, animFunc)
    addon:Debug("AnimationBuilder:AnimateFrameHeight")

    ensureUUID(frame)

    animFunc = animFunc or "LINEAR"
    local setter = function(val) frame:SetHeight(val) end
    local animationId = frame.uuid .. "-width"

    self:Animate(animationId, setter, startVal, endVal, duration, false, animFunc)
end

-- Assumes values are seconds
function AnimationBuilder:AnimateTextTime(frame, startVal, endVal)
    addon:Debug("AnimationBuilder:AnimateTextTime")

    ensureUUID(frame)

    local animFunc = "LINEAR"
    local setter = function(val) frame:SetText(string.format("%.1f", val) .. "s") end
    local duration = math.abs(endVal - startVal)
    local animationId = frame.uuid .. "-text"

    self:Animate(animationId, setter, startVal, endVal, duration, false, animFunc)
end
