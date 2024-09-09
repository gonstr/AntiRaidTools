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
}

local AnimationPrototype = {}

local Animation = AnimationPrototype
Animation.__index = Animation

function Animation:New(id, startVal, endVal, duration, setter, animFunc)
    local instance = setmetatable({}, self)

    instance.id = id
    instance.startVal = startVal
    instance.endVal = endVal
    instance.duration = duration
    instance.setter = setter
    instance.animFunc = AnimationFunctions[animFunc]

    instance.startTime = GetTime()
    instance.endTime = GetTime() + duration

    return instance
end

function Animation:Animate()
    local currentTime = GetTime()

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

function AnimationBuilder:Animate(id, startVal, endVal, duration, setter, animFunc)
    addon:Debug("AnimationBuilder:Animate", id)

    assert(AnimationFunctions[animFunc] ~= nil)

    -- Cancel any pending animations with the same id
    for i, animation in ipairs(self.animations) do
        if animation.id == id then
            animation:Cancel()
            remove(self.animations, i)
            break
        end
    end

    insert(self.animations, AnimationPrototype:New(id, startVal, endVal, duration, setter, animFunc))
end
