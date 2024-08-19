TestImportParser = {}

function TestImportParser:TestImport()
    local parser = addon.ImportParserPrototype:new()

    local import = "W3sNCiAgICAidHlwZSI6ICJQQUNLIiwNCiAgICAidmVyc2lvbiI6IDEsDQogICAgIm5hbWUiOiAiVGhlIGJlc3QgcmFpZCBwYWNrIiwNCiAgICAicGFja1ZlcnNpb24iOiAxLA0KICAgICJpdGVtcyI6IFsNCiAgICAgICAgew0KICAgICAgICAgICAgInR5cGUiOiAiVFJJR0dFUiIsDQogICAgICAgICAgICAidmVyc2lvbiI6IDEsDQogICAgICAgICAgICAiZW5jb3VudGVyIjogMTA0MCwNCiAgICAgICAgICAgICJ0cmlnZ2VycyI6IFt7ICJ0eXBlIjogIlNQRUxMX0FVUkEiLCAic3BlbGxJZCI6IDEyMzQsICJkZWxheSI6IDEwLCAidGhyb3R0bGUiOiAzIH1dLA0KICAgICAgICAgICAgInVudHJpZ2dlcnMiOiBbeyAidHlwZSI6ICJFTU9URV9PUl9ZRUxMIiwgInRleHQiOiAiVGhpcyBlbmRzIG5vdyEiIH1dLA0KICAgICAgICAgICAgImlkIjogInRyaWdnZXItMSIsDQogICAgICAgIH0sDQogICAgICAgIHsNCiAgICAgICAgICAgICJ0eXBlIjogIkVWRU5UIiwNCiAgICAgICAgICAgICJ2ZXJzaW9uIjogMSwNCiAgICAgICAgICAgICJlbmNvdW50ZXIiOiAxMDQwLA0KICAgICAgICAgICAgIm5hbWUiOiAiJHtjdHgudHJpZ2dlci5zcGVsbE5hbWV9IG9uICR7Y3R4LnRyaWdnZXIuZGVzdFVuaXR9IGZvciAke3N0cmluZy5mb3JtYXQoJyUuMmYnLCBjdHgudHJpZ2dlci5hbW91bnQpfSIsDQogICAgICAgICAgICAidHJpZ2dlciI6ICJ0cmlnZ2VyLTEiLA0KICAgICAgICB9DQogICAgXQ0KfV0="

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
                    encounter = 1040,
                    name = "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}",
                    trigger = "trigger-1",
                }
            }
        }
    }

    luaunit.assertEquals(parser:import(import), expectedResult)
end
