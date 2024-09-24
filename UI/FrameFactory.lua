local addonName, addon = ...

local insert = table.insert

addon.FrameFactoryPrototype = {}

local FrameFactory = addon.FrameFactoryPrototype
FrameFactory.__index = FrameFactory

function FrameFactory:New()
    local instance = setmetatable({}, self)

    instance.framePrototypes = {
        container = addon.ContainerFramePrototype,
        events = addon.EventsFramePrototype,
        event = addon.EventFramePrototype,
        bar = addon.BarFramePrototype,
        icon = addon.IconFramePrototype
    }
    
    instance.frames = {}

    return instance
end

function FrameFactory:AcquireFrame(frameType, ...)
    if not self.framePrototypes[frameType] then
        error("Unknown frame type: " .. frameType)
    end

    if not self.frames[frameType] then
        self.frames[frameType] = {}
    end

    -- We only look for a reused frame if no frame constructor args are passed
    if not select("#", ...) then    
        for _, frame in ipairs(self.frames[frameType]) do
            if not frame._acquired then
                frame._acquired = true
                frame:OnAcquire()
                return frame
            end
        end
    end

    local frame = self.framePrototypes[frameType]:New(...)
    frame._acquired = true
    frame:OnAcquire()

    function frame:Release()
        self._acquired = false

        if self._releaseTimer then
            self._releaseTimer:Cancel()
            self._releaseTimer = nil
        end

        self:OnRelease()
    end

    function frame:ScheduleRelease(time)
        if self._releaseTimer then
            self._releaseTimer:Cancel()
        end

        self.releaseTimer = C_Timer.NewTimer(time, function() self:Release() end)
    end

    insert(self.frames[frameType], frame)

    return frame
end
