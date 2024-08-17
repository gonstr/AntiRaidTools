require('Parsers/Base64')

TestBase64Parser = {}

local testString = [[
    {
        "test": 123,
        "foo": ["bar"],
    }
]]

function TestBase64Parser:TestEncode()
    local parser = AntiRaidTools.Base64ParserPrototype:new()

    luaunit.assertEquals(parser:encode(testString), "ICAgIHsKICAgICAgICAidGVzdCI6IDEyMywKICAgICAgICAiZm9vIjogWyJiYXIiXSwKICAgIH0K")
end

function TestBase64Parser:TestDecode()
    local parser = AntiRaidTools.Base64ParserPrototype:new()

    luaunit.assertEquals(parser:decode("ICAgIHsKICAgICAgICAidGVzdCI6IDEyMywKICAgICAgICAiZm9vIjogWyJiYXIiXSwKICAgIH0K"), testString)
end

function TestBase64Parser:TestFailDecode()
    local parser = AntiRaidTools.Base64ParserPrototype:new()

    luaunit.assertError(function() parser:decode("543(-#)") end)
end
