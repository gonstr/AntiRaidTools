TestBase64Parser = {}

local testString = [[
    {
        "test": 123,
        "foo": ["bar"],
    }
]]

function TestBase64Parser:TestEncode()
    local parser = addon.Base64ParserPrototype:New()

    luaunit.assertEquals(parser:Encode(testString), "ICAgIHsKICAgICAgICAidGVzdCI6IDEyMywKICAgICAgICAiZm9vIjogWyJiYXIiXSwKICAgIH0K")
end

function TestBase64Parser:TestDecode()
    local parser = addon.Base64ParserPrototype:New()

    luaunit.assertEquals(parser:Decode("ICAgIHsKICAgICAgICAidGVzdCI6IDEyMywKICAgICAgICAiZm9vIjogWyJiYXIiXSwKICAgIH0K"), testString)
end

function TestBase64Parser:TestFailDecode()
    local parser = addon.Base64ParserPrototype:New()

    luaunit.assertError(function() parser:Decode("543(-#)") end)
end
