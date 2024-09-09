TestBase64Parser = {}

local testString = [[
    {
        "test": 123,
        "foo": ["bar"],
    }
]]

function TestBase64Parser:TestEncode()
    luaunit.assertEquals(addon.base64Parser:Encode(testString), "ICAgIHsKICAgICAgICAidGVzdCI6IDEyMywKICAgICAgICAiZm9vIjogWyJiYXIiXSwKICAgIH0K")
end

function TestBase64Parser:TestDecode()
    luaunit.assertEquals(addon.base64Parser:Decode("ICAgIHsKICAgICAgICAidGVzdCI6IDEyMywKICAgICAgICAiZm9vIjogWyJiYXIiXSwKICAgIH0K"), testString)
end

function TestBase64Parser:TestFailDecode()
    luaunit.assertError(function() addon.base64Parser:Decode("543(-#)") end)
end
