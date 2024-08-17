require("Utils")

local insert = table.insert

TestUtils = {}

function TestUtils:TestTableContains()
    local utils = AntiRaidTools.UtilsPrototype:new()

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
    local utils = AntiRaidTools.UtilsPrototype:new()

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
    local utils = AntiRaidTools.UtilsPrototype:new()

    luaunit.assertEquals(utils:stripErrorFileAndLine("Foo/Bar/Baz.lua:303: Some error"), "Some error")
    luaunit.assertEquals(utils:stripErrorFileAndLine("Some error"), "Some error")
end
