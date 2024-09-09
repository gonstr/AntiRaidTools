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
    sound = "Interface\\AddOns\\addon\\Media\\PowerAuras_Sounds_Sonar.mp3"
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
    gameVersion = "CATA",
    name = "The best raid pack",
    id = "Pack-123",
    packVersion = 1,
    options = {
        headerTexture = "interface/questionframe/warboardzonescata",
        headerTexCords = { 0.0009765625, 0.2626953125, 0.001953125, 0.240234375 },
        groups = {
            {
                header = "Halfus Wyrmbreaker",
                items = {
                    {
                        type = "TOGGLE",
                        name = "Scorching Breath",
                        description = "Show timers and notifications for Scorching Breath.",
                        id = "scorching-breath",
                        default = true
                    }
                }
            }
        }
    },
    items = { trigger, timer, state, event, raidFrameIcon, sound, tts }
}

local function createPack(item)
    return {
        type = "PACK",
        version = 1,
        gameVersion = "CATA",
        name = "Test Pack",
        id = "test-pack",
        packVersion = 1,
        items = { item }
    }
end

function TestImportValidator:TestImport()
    luaunit.assertTrue(addon.importValidator:Validate({ pack }))
end

function TestImportValidator:TestImportNoVersion()
    local clone = addon.utils:DeepClone(pack)
    clone.version = nil

    luaunit.assertError(function()
        addon.importValidator:Validate({ clone })
    end)
end

function TestImportValidator:TestImportInvalidType()
    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(trigger)
        clone.type = "FOO"
        addon.importValidator:Validate({ clone })
    end)
end

function TestImportValidator:TestImportNotArray()
    luaunit.assertError(function()
        addon.importValidator:Validate("foo")
    end)

    luaunit.assertError(function()
        addon.importValidator:Validate({
            foo = "bar"
        })
    end)
end

function TestImportValidator:TestImportPack()
    luaunit.assertTrue(addon.importValidator:Validate({ pack }))

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.name = nil
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.packVersion = nil
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.id = nil
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.items = nil
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.items = {}
        addon.importValidator:Validate({ clone })
    end)
end

function TestImportValidator:TestImportTrigger()
    luaunit.assertTrue(addon.importValidator:Validate({ createPack(trigger) }))

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(trigger)
        clone.id = nil
        addon.importValidator:Validate({ createPack(clone) })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(trigger)
        clone.encounter = nil
        addon.importValidator:Validate({ createPack(clone) })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(trigger)
        clone.triggers = nil
        addon.importValidator:Validate({ createPack(clone) })
    end)

    local clone = addon.utils:DeepClone(trigger)
    clone.untriggers = nil
    
    luaunit.assertTrue(addon.importValidator:Validate({ createPack(clone) }))
end

function TestImportValidator:TestImportTimer()
    luaunit.assertTrue(addon.importValidator:Validate({ createPack(timer) }))

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(timer)
        clone.id = nil
        addon.importValidator:Validate({ createPack(clone) })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(timer)
        clone.encounter = nil
        addon.importValidator:Validate({ createPack(clone) })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(timer)
        clone.name = nil
        addon.importValidator:Validate({ createPack(clone) })
    end)


    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(timer)
        clone.trigger = nil
        addon.importValidator:Validate({ createPack(clone) })
    end)
end

function TestImportValidator:TestImportInvalidPackOptions()
    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.options.headerTexture = nil
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.options.headerTexCords = { 1, 2 }
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.options.groups[1].header = nil
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.options.groups = {}
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.options.groups[1].header = nil
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.options.groups[1].items = {}
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.options.groups[1].items[1].type = nil
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.options.groups[1].items[1].name = nil
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.options.groups[1].items[1].description = nil
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.options.groups[1].items[1].id = nil
        addon.importValidator:Validate({ clone })
    end)

    luaunit.assertError(function()
        local clone = addon.utils:DeepClone(pack)
        clone.options.groups[1].items[1].default = nil
        addon.importValidator:Validate({ clone })
    end)
end
