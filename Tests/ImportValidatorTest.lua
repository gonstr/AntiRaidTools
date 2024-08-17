require("Utils")
require("ImportValidator")

TestImportValidator = {}

local trigger = {
    type = "TRIGGER",
    version = 1,
    id = "trigger-1",
    encounter = 1040,
    triggers = {
        {
            type = "SPELL_AURA",
            spellId = 1234,
            delay = 10,
            throttle = 3,
        }
    },
    untriggers = {
        {
            type = "EMOTE_OR_YELL",
            text = "This ends now!",
        }
    }
}

local timer = {
    type = "TIMER",
    version = 1,
    id = "timer-1",
    encounter = 1040,
    name = "Boss ability",
    trigger = "trigger-1",
    group = "Boss1",
}

local state = {
    type = "STATE",
    version = 1,
    id = "timer-1",
    encounter = 1040,
    name = "Boss ability",
    trigger = "trigger-1",
    group = "Boss1",
}

local event = {
    type = "EVENT",
    version = 1,
    id = "event-1",
    encounter = 1040,
    name = "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}",
    trigger = "trigger-1",
}

local raidFrameIcon = {
    type = "RAID_FRAME_ICON",
    version = 1,
    id = "raid-icon-1",
    encounter = 1040,
    trigger = "trigger-1",
    icon = "Ability_rogue_deviouspoisons"
}

local sound = {
    type = "SOUND",
    version = 1,
    id = "sound-1",
    encounter = 1040,
    trigger = "trigger-1",
    sound = "Interface\\AddOns\\AntiRaidTools\\Media\\PowerAuras_Sounds_Sonar.mp3"
}

local tts = {
    type = "SOUND",
    version = 1,
    id = "sound-1",
    encounter = 1040,
    trigger = "trigger-1",
    tts = "Lava Spew"
}

local pack = {
    type = "PACK",
    version = 1,
    name = "The best raid pack",
    packVersion = 1,
    items = { trigger, timer, state, event, raidFrameIcon, sound, tts }
}

function TestImportValidator:TestImport()
    local validator = AntiRaidTools.ImportValidatorPrototype:new()

    luaunit.assertTrue(validator:validate({ pack }))
end

function TestImportValidator:TestImportNoVersion()
    local validator = AntiRaidTools.ImportValidatorPrototype:new()
    local utils = AntiRaidTools.UtilsPrototype:new()

    local clone = utils:deepClone(pack)
    clone.version = nil

    luaunit.assertError(function()
        validator:validate({ clone })
    end)
end

function TestImportValidator:TestImportInvalidType()
    local validator = AntiRaidTools.ImportValidatorPrototype:new()
    local utils = AntiRaidTools.UtilsPrototype:new()

    luaunit.assertError(function()
        local clone = utils:deepClone(trigger)
        clone.type = "FOO"
        validator:validate({ clone })
    end)
end

function TestImportValidator:TestImportNotArray()
    local validator = AntiRaidTools.ImportValidatorPrototype:new()

    luaunit.assertError(function()
        validator:validate("foo")
    end)

    luaunit.assertError(function()
        validator:validate({
            foo = "bar"
        })
    end)
end

function TestImportValidator:TestImportPack()
    local validator = AntiRaidTools.ImportValidatorPrototype:new()
    local utils = AntiRaidTools.UtilsPrototype:new()

    luaunit.assertTrue(validator:validate({ pack }))

    luaunit.assertError(function()
        local clone = utils:deepClone(pack)
        clone.name = nil
        validator:validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = utils:deepClone(pack)
        clone.packVersion = nil
        validator:validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = utils:deepClone(pack)
        clone.items = nil
        validator:validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = utils:deepClone(pack)
        clone.items = {}
        validator:validate({ clone })
    end)
end

function TestImportValidator:TestImportTrigger()
    local validator = AntiRaidTools.ImportValidatorPrototype:new()
    local utils = AntiRaidTools.UtilsPrototype:new()

    luaunit.assertTrue(validator:validate({ trigger }))

    luaunit.assertError(function()
        local clone = utils:deepClone(trigger)
        clone.id = nil
        validator:validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = utils:deepClone(trigger)
        clone.encounter = nil
        validator:validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = utils:deepClone(trigger)
        clone.triggers = nil
        validator:validate({ clone })
    end)

    local clone = utils:deepClone(trigger)
    clone.untriggers = nil
    
    luaunit.assertTrue(validator:validate({ clone }))
end

function TestImportValidator:TestImportTimer()
    local validator = AntiRaidTools.ImportValidatorPrototype:new()
    local utils = AntiRaidTools.UtilsPrototype:new()

    luaunit.assertTrue(validator:validate({ timer }))

    luaunit.assertError(function()
        local clone = utils:deepClone(timer)
        clone.id = nil
        validator:validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = utils:deepClone(timer)
        clone.encounter = nil
        validator:validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = utils:deepClone(timer)
        clone.name = nil
        validator:validate({ clone })
    end)


    luaunit.assertError(function()
        local clone = utils:deepClone(timer)
        clone.trigger = nil
        validator:validate({ clone })
    end)
end
