local AntiRaidTools = AntiRaidTools

function AntiRaidTools:InternalTestStart()
    self.TEST = true

    self:UpdateOverviewSpells()

    self:ENCOUNTER_START(1032)

    C_Timer.After(3, function()
        AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Anticipâte", nil, nil, 31821)
    end)

    C_Timer.After(10, function()
        AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Valiona", nil, nil, 86788)
    end)

    C_Timer.After(12, function()
        AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Dableach", nil, nil, 51052)
    end)

    C_Timer.After(12, function()
        AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Kondec", nil, nil, 62618)
    end)

    C_Timer.After(12, function()
        AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Solfernus", nil, nil, 51052)
    end)

    C_Timer.After(20, function()
        AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Valiona", nil, nil, 86788)
    end)

    C_Timer.After(22, function()
        AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Sîf", nil, nil, 97462)
    end)
    
    C_Timer.After(30, function()
        AntiRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Valiona", nil, nil, 86788)
    end)

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

    self:ENCOUNTER_END(1032)
end
