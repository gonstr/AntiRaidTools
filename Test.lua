local AntiRaidTools = AntiRaidTools

function AntiRaidTools:InternalTestStart()
    self:ENCOUNTER_START(1027)
end

function AntiRaidTools:InternalTestEnd()
    self:ENCOUNTER_END(1027)
end
