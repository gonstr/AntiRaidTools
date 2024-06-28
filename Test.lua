local AntiRaidTools = AntiRaidTools

function AntiRaidTools:InternalTestStart()
    self.TEST = true

    self:UpdateOverviewSpells()

    self:ENCOUNTER_START(1027)

    C_Timer.After(3, function()
        AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Magnetron", nil, nil, 79023)
    end)

    C_Timer.After(5, function()
        AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Magnetron", nil, nil, 91849)
    end)

    -- C_Timer.After(3, function()
    --     AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Anticipâte", nil, nil, 31821)
    -- end)
    
    -- C_Timer.After(6, function()
    --     AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Kondec", nil, nil, 62618)
    -- end)

    -- -- C_Timer.After(9, function()
    -- --     AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Venmir", nil, nil, 98008)
    -- -- end)

    -- C_Timer.After(12, function()
    --     AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Managobrr", nil, nil, 64843)
    -- end)

    -- C_Timer.After(15, function()
    --     AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Clutex", nil, nil, 44203)
    -- end)
end

function AntiRaidTools:InternalTestEnd()
    self.TEST = false

    self:ENCOUNTER_END(1027)
end
