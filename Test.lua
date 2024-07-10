local AntiRaidTools = AntiRaidTools

function AntiRaidTools:InternalTestStart()
    self.TEST = true

    self:OverviewUpdateSpells()

    self:ENCOUNTER_START(nil, 1035)

    C_Timer.After(3, function()
        AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Anticipâte", nil, nil, 31821)
    end)

    C_Timer.After(5, function()
        AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Rohash", nil, nil, 93059)
    end)
end

function AntiRaidTools:InternalTestEnd()
    self.TEST = false

    self:ENCOUNTER_END(nil, 1035)
end
