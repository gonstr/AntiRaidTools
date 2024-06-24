local AntiRaidTools = AntiRaidTools

function AntiRaidTools:InternalTestStart()
    self:ENCOUNTER_START(1027)
    self:HandleCombatLog("SPELL_CAST_SUCCESS", "Anticipâte", nil, nil, 31821)
end

function AntiRaidTools:InternalTestEnd()
    self:ENCOUNTER_END(1027)
end
