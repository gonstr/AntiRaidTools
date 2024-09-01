local insert = table.insert

local addonName, addon = ...

addon.FrameFactoryPrototype = {}

local FrameFactory = addon.FrameFactoryPrototype
FrameFactory.__index = FrameFactory

function FrameFactory:New()
    local instance = setmetatable({}, self)

    instance.framePrototypes = {
        container = addon.ContainerFramePrototype,
        events = addon.EventsFramePrototype,
        event = addon.EventFramePrototype
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
        self:OnRelease()
    end

    insert(self.frames[frameType], frame)

    return frame
end
