TestJsonParser = {}

function TestJsonParser:TestEncode()
    luaunit.assertEquals(addon.jsonParser:Encode({ foo = "bar" }), '{"foo":"bar"}')
end

function TestJsonParser:TestDecodeObject()
    luaunit.assertEquals(addon.jsonParser:Decode('{ "foo": "bar" }'), { foo = "bar" })
end

function TestJsonParser:TestDecodeArray()
    luaunit.assertEquals(addon.jsonParser:Decode('["foo", "bar"]'), { "foo", "bar" })
end

function TestJsonParser:TestFailDecode()
    luaunit.assertError(function() addon.jsonParser:Decode('["foo", {"bar"]') end)
end

function TestJsonParser:TestDecodeImport()
    local import = [[
        [{
            "type": "PACK",
            "version": 1,
            "name": "The best raid pack",
            "packVersion": 1,
            "items": [
                {
                    "type": "TRIGGER",
                    "version": 1,
                    "encounter": 1040,
                    "triggers": [{ "type": "SPELL_AURA", "spellId": 1234, "delay": 10, "throttle": 3 }],
                    "untriggers": [{ "type": "EMOTE_OR_YELL", "text": "This ends now!" }],
                    "id": "trigger-1",
                },
                {
                    "type": "EVENT",
                    "version": 1,
                    "id": "event-1",
                    "encounter": 1040,
                    "name": "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}",
                    "trigger": "trigger-1",
                }
            ]
        }]
    ]]

    local expectedResult = {
        {
            type = "PACK",
            version = 1,
            name = "The best raid pack",
            packVersion = 1,
            items = {
                {
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
                },
                {
                    type = "EVENT",
                    version = 1,
                    id = "event-1",
                    encounter = 1040,
                    name = "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}",
                    trigger = "trigger-1",
                }
            }
        }
    }

    luaunit.assertEquals(addon.jsonParser:Decode(import), expectedResult)
end
