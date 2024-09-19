local insert = table.insert

TestUtils = {}

function TestUtils:TestTableContains()
    luaunit.assertTrue(addon.utils:TableContains({"foo", "bar"}, "foo"))
    luaunit.assertTrue(addon.utils:TableContains({1, 2, 3}, 2))
    luaunit.assertTrue(addon.utils:TableContains({false, true}, true))
    luaunit.assertTrue(addon.utils:TableContains({false, true}, false))

    local testTable = {}
    insert(testTable, "foo")
    insert(testTable, "bar")
    luaunit.assertTrue(addon.utils:TableContains(testTable, "foo"))

    luaunit.assertFalse(addon.utils:TableContains({"foo", "bar"}, "baz"))
    luaunit.assertFalse(addon.utils:TableContains({1, 2, 3}, 5))
    luaunit.assertFalse(addon.utils:TableContains({{ "foo "}}, { "bar"}))
    luaunit.assertFalse(addon.utils:TableContains({false, true}, nil))

    luaunit.assertFalse(addon.utils:TableContains({
        a = "foo",
        b = "bar"
    }, "foo"))
end

function TestUtils:TestDeepCloneAndDeepEqual()
    local t1 = {
        a = "b",
        b = { 1, 2 }
    }

    local c1 = addon.utils:DeepClone(t1)

    luaunit.assertTrue(addon.utils:DeepEqual(t1, c1))

    local t2 = { 1, 2, 3, 4 }

    local c2 = addon.utils:DeepClone(t2)

    luaunit.assertTrue(addon.utils:DeepEqual(t2, c2))
end

function TestUtils:TestStripErrorFileAndLine()
    luaunit.assertEquals(addon.utils:StripErrorFileAndLine("Foo/Bar/Baz.lua:303: Some error"), "Some error")
    luaunit.assertEquals(addon.utils:StripErrorFileAndLine("Some error"), "Some error")
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
            type = "UNIT_FRAME_ICON",
            version = 1,
            id = "raid-icon-1",
            encounter = 1050,
            trigger = "trigger-1",
            icon = "Ability_rogue_deviouspoisons"
        }
    }

    luaunit.assertEquals(#addon.utils:FilterTable(items, function(item) return item.type == "EVENT" end), 2)
    luaunit.assertEquals(#addon.utils:FilterTable(items, function(item) return item.encounter == 1050 end), 1)
end

function TestUtils:TestGroupTable()
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
            type = "UNIT_FRAME_ICON",
            version = 1,
            id = "raid-icon-1",
            encounter = 1050,
            trigger = "trigger-1",
            icon = "Ability_rogue_deviouspoisons"
        }
    }

    do
        local groups = addon.utils:GroupTable(items, function(item) return item.type end)
        luaunit.assertEquals(#groups["EVENT"], 2)
        luaunit.assertEquals(#groups["UNIT_FRAME_ICON"], 1)
    end

    do
        local groups = addon.utils:GroupTable(items, function(item) return item.id end)
        luaunit.assertEquals(#groups["event-1"], 1)
        luaunit.assertEquals(#groups["event-2"], 1)
        luaunit.assertEquals(#groups["raid-icon-1"], 1)
    end
end

function TestUtils:TestStringInterpolate()
    luaunit.assertEquals(addon.utils:StringInterpolate("${ctx.trigger.spellName} on ${string.upper(ctx.trigger.destUnit)}", {
        trigger = {
            spellName = "Shadow Trap",
            destUnit = "Anti"
        }
    }), "Shadow Trap on ANTI")

    luaunit.assertEquals(addon.utils:StringInterpolate("${ctx.trigger.spellName} on ${string.upper(ctx.trigger.destUnit)}", {
        trigger = {
            spellName = "Shadow Trap"
        }
    }), "Shadow Trap on ???")
end
