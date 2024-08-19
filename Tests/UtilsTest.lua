local insert = table.insert

TestUtils = {}

function TestUtils:TestTableContains()
    local utils = addon.UtilsPrototype:new()

    luaunit.assertTrue(utils:tableContains({"foo", "bar"}, "foo"))
    luaunit.assertTrue(utils:tableContains({1, 2, 3}, 2))
    luaunit.assertTrue(utils:tableContains({false, true}, true))
    luaunit.assertTrue(utils:tableContains({false, true}, false))

    local testTable = {}
    insert(testTable, "foo")
    insert(testTable, "bar")
    luaunit.assertTrue(utils:tableContains(testTable, "foo"))

    luaunit.assertFalse(utils:tableContains({"foo", "bar"}, "baz"))
    luaunit.assertFalse(utils:tableContains({1, 2, 3}, 5))
    luaunit.assertFalse(utils:tableContains({{ "foo "}}, { "bar"}))
    luaunit.assertFalse(utils:tableContains({false, true}, nil))

    luaunit.assertFalse(utils:tableContains({
        a = "foo",
        b = "bar"
    }, "foo"))
end

function TestUtils:TestDeepCloneAndDeepEqual()
    local utils = addon.UtilsPrototype:new()

    local t1 = {
        a = "b",
        b = { 1, 2 }
    }

    local c1 = utils:deepClone(t1)

    luaunit.assertTrue(utils:deepEqual(t1, c1))

    local t2 = { 1, 2, 3, 4 }

    local c2 = utils:deepClone(t2)

    luaunit.assertTrue(utils:deepEqual(t2, c2))
end

function TestUtils:TestStripErrorFileAndLine()
    local utils = addon.UtilsPrototype:new()

    luaunit.assertEquals(utils:stripErrorFileAndLine("Foo/Bar/Baz.lua:303: Some error"), "Some error")
    luaunit.assertEquals(utils:stripErrorFileAndLine("Some error"), "Some error")
end

local event = {
    type = "EVENT",
    version = 1,
    id = "event-1",
    encounter = 1040,
    name = "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}",
    trigger = "trigger-1",
}

function TestUtils:TestFilterTable()
    local utils = addon.UtilsPrototype:new()

    local items = {
        {
            type = "EVENT",
            version = 1,
            id = "event-1",
            encounter = 1040,
            name = "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}",
            trigger = "trigger-1",
        },
        {
            type = "EVENT",
            version = 1,
            id = "event-2",
            encounter = 1040,
            name = "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}",
            trigger = "trigger-1",
        },
        {
            type = "RAID_FRAME_ICON",
            version = 1,
            id = "raid-icon-1",
            encounter = 1050,
            trigger = "trigger-1",
            icon = "Ability_rogue_deviouspoisons"
        }
    }

    luaunit.assertEquals(#utils:filterTable(items, function(item) return item.type == "EVENT" end), 2)
    luaunit.assertEquals(#utils:filterTable(items, function(item) return item.encounter == 1050 end), 1)
end

function TestUtils:TestGroupTable()
    local utils = addon.UtilsPrototype:new()

    local items = {
        {
            type = "EVENT",
            version = 1,
            id = "event-1",
            encounter = 1040,
            name = "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}",
            trigger = "trigger-1",
        },
        {
            type = "EVENT",
            version = 1,
            id = "event-2",
            encounter = 1040,
            name = "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}",
            trigger = "trigger-1",
        },
        {
            type = "RAID_FRAME_ICON",
            version = 1,
            id = "raid-icon-1",
            encounter = 1050,
            trigger = "trigger-1",
            icon = "Ability_rogue_deviouspoisons"
        }
    }

    do
        local groups = utils:groupTable(items, function(item) return item.type end)
        luaunit.assertEquals(#groups["EVENT"], 2)
        luaunit.assertEquals(#groups["RAID_FRAME_ICON"], 1)
    end

    do
        local groups = utils:groupTable(items, function(item) return item.id end)
        luaunit.assertEquals(#groups["event-1"], 1)
        luaunit.assertEquals(#groups["event-2"], 1)
        luaunit.assertEquals(#groups["raid-icon-1"], 1)
    end
end
