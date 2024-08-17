require("Import")

TestImport = {}

local base64Import = "W3sNCiAgICAidHlwZSI6ICJQQUNLIiwNCiAgICAidmVyc2lvbiI6IDEsDQogICAgIm5hbWUiOiAiVGhlIGJlc3QgcmFpZCBwYWNrIiwNCiAgICAicGFja1ZlcnNpb24iOiAxLA0KICAgICJpdGVtcyI6IFsNCiAgICAgICAgew0KICAgICAgICAgICAgInR5cGUiOiAiVFJJR0dFUiIsDQogICAgICAgICAgICAidmVyc2lvbiI6IDEsDQogICAgICAgICAgICAiZW5jb3VudGVyIjogMTA0MCwNCiAgICAgICAgICAgICJ0cmlnZ2VycyI6IFt7ICJ0eXBlIjogIlNQRUxMX0FVUkEiLCAic3BlbGxJZCI6IDEyMzQsICJkZWxheSI6IDEwLCAidGhyb3R0bGUiOiAzIH1dLA0KICAgICAgICAgICAgInVudHJpZ2dlcnMiOiBbeyAidHlwZSI6ICJFTU9URV9PUl9ZRUxMIiwgInRleHQiOiAiVGhpcyBlbmRzIG5vdyEiIH1dLA0KICAgICAgICAgICAgImlkIjogInRyaWdnZXItMSIsDQogICAgICAgIH0sDQogICAgICAgIHsNCiAgICAgICAgICAgICJ0eXBlIjogIkVWRU5UIiwNCiAgICAgICAgICAgICJ2ZXJzaW9uIjogMSwNCiAgICAgICAgICAgICJpZCI6ICJldmVudC0xIiwNCiAgICAgICAgICAgICJlbmNvdW50ZXIiOiAxMDQwLA0KICAgICAgICAgICAgIm5hbWUiOiAiJHtjdHgudHJpZ2dlci5zcGVsbE5hbWV9IG9uICR7Y3R4LnRyaWdnZXIuZGVzdFVuaXR9IGZvciAke3N0cmluZy5mb3JtYXQoJyUuMmYnLCBjdHgudHJpZ2dlci5hbW91bnQpfSIsDQogICAgICAgICAgICAidHJpZ2dlciI6ICJ0cmlnZ2VyLTEiLA0KICAgICAgICB9DQogICAgXQ0KfV0="
local minifiedBase64Import = "W3sidHlwZSI6IlBBQ0siLCJ2ZXJzaW9uIjoxLCJuYW1lIjoiVGhlIGJlc3QgcmFpZCBwYWNrIiwicGFja1ZlcnNpb24iOjEsIml0ZW1zIjpbeyJ0eXBlIjoiVFJJR0dFUiIsInZlcnNpb24iOjEsImVuY291bnRlciI6MTA0MCwidHJpZ2dlcnMiOlt7InR5cGUiOiJTUEVMTF9BVVJBIiwic3BlbGxJZCI6MTIzNCwiZGVsYXkiOjEwLCJ0aHJvdHRsZSI6M31dLCJ1bnRyaWdnZXJzIjpbeyJ0eXBlIjoiRU1PVEVfT1JfWUVMTCIsInRleHQiOiJUaGlzIGVuZHMgbm93ISJ9XSwiaWQiOiJ0cmlnZ2VyLTEifSx7InR5cGUiOiJFVkVOVCIsInZlcnNpb24iOjEsImlkIjoiZXZlbnQtMSIsImVuY291bnRlciI6MTA0MCwibmFtZSI6IiR7Y3R4LnRyaWdnZXIuc3BlbGxOYW1lfSBvbiAke2N0eC50cmlnZ2VyLmRlc3RVbml0fSBmb3IgJHtzdHJpbmcuZm9ybWF0KCclLjJmJywgY3R4LnRyaWdnZXIuYW1vdW50KX0iLCJ0cmlnZ2VyIjoidHJpZ2dlci0xIn1dfV0="
local invalidBase64Import = "ICAgICAgICBbew0KICAgICAgICAgICAgInR5cGUiOiAiUEFDSyIsDQogICAgICAgICAgICAidmVyc2lvbiI6IDEsDQogICAgICAgICAgICAibmFtZSI6ICJUaGUgYmVzdCByYWlkIHBhY2siLA0KICAgICAgICAgICAgInBhY2tWZXJzaW9uIjogMSwNCiAgICAgICAgICAgICJpdGVtcyI6IFsNCiAgICAgICAgICAgICAgICB7DQogICAgICAgICAgICAgICAgICAgICJ0eXBlIjogIlRSSUdHRVIiLA0KICAgICAgICAgICAgICAgICAgICAidmVyc2lvbiI6IDEsDQogICAgICAgICAgICAgICAgICAgICJlbmNvdW50ZXIiOiAxMDQwLA0KICAgICAgICAgICAgICAgICAgICAidHJpZ2dlcnMiOiBbeyAidHlwZSI6ICJTUEVMTF9BVVJBIiwgInNwZWxsSWQiOiAxMjM0LCAiZGVsYXkiOiAxMCwgInRocm90dGxlIjogMyB9XSwNCiAgICAgICAgICAgICAgICAgICAgInVudHJpZ2dlcnMiOiBbeyAidHlwZSI6ICJFTU9URV9PUl9ZRUxMIiwgInRleHQiOiAiVGhpcyBlbmRzIG5vdyEiIH1dLA0KICAgICAgICAgICAgICAgICAgICAiaWQiOiAidHJpZ2dlci0xIiwNCiAgICAgICAgICAgICAgICB9LA0KICAgICAgICAgICAgICAgIHsNCiAgICAgICAgICAgICAgICAgICAgInR5cGUiOiAiRVZFTlQiLA0KICAgICAgICAgICAgICAgICAgICAidmVyc2lvbiI6IDEsDQogICAgICAgICAgICAgICAgICAgICJlbmNvdW50ZXIiOiAxMDQwLA0KICAgICAgICAgICAgICAgICAgICAibmFtZSI6ICIke2N0eC50cmlnZ2VyLnNwZWxsTmFtZX0gb24gJHtjdHgudHJpZ2dlci5kZXN0VW5pdH0gZm9yICR7c3RyaW5nLmZvcm1hdCgnJS4yZicsIGN0eC50cmlnZ2VyLmFtb3VudCl9IiwNCiAgICAgICAgICAgICAgICAgICAgInRyaWdnZXIiOiAidHJpZ2dlci0xIiwNCiAgICAgICAgICAgICAgICB9DQogICAgICAgICAgICBdDQogICAgICAgIH1d"

local jsonImport = [[
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
                "id": "trigger-1"
            },
            {
                "type": "EVENT",
                "version": 1,
                "id": "event-1",
                "encounter": 1040,
                "name": "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}",
                "trigger": "trigger-1"
            }
        ]
    }]
]]

local minifiedJsonImport = [[
    [{"type":"PACK","version":1,"name":"The best raid pack","packVersion":1,"items":[{"type":"TRIGGER","version":1,"encounter":1040,"triggers":[{"type":"SPELL_AURA","spellId":1234,"delay":10,"throttle":3}],"untriggers":[{"type":"EMOTE_OR_YELL","text":"This ends now!"}],"id":"trigger-1"},{"type":"EVENT","version":1,"id":"event-1","encounter":1040,"name":"${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}","trigger":"trigger-1"}]}]
]]

local escapedMinifiedJsonImport = '[{"type":"PACK","version":1,"name":"The best raid pack","packVersion":1,"items":[{"type":"TRIGGER","version":1,"encounter":1040,"triggers":[{"type":"SPELL_AURA","spellId":1234,"delay":10,"throttle":3}],"untriggers":[{"type":"EMOTE_OR_YELL","text":"This ends now!"}],"id":"trigger-1"},{"type":"EVENT","version":1,"id":"event-1","encounter":1040,"name":"${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format(\'%.2f\', ctx.trigger.amount)}","trigger":"trigger-1"}]}]'

local invalidJsonImport = [[
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
                "encounter": 1040,
                "name": "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}",
                "trigger": "trigger-1",
            }
        ]
    }]
]]

function TestImportValidator:TestBase64Import()
    local import = AntiRaidTools.ImportPrototype:new()

    luaunit.assertIsTable(import:import(base64Import))
end

function TestImportValidator:TestMinifiedBase64Import()
    local import = AntiRaidTools.ImportPrototype:new()

    luaunit.assertIsTable(import:import(minifiedBase64Import))
end

function TestImportValidator:TestInvalidBase64Import()
    local import = AntiRaidTools.ImportPrototype:new()

    luaunit.assertErrorMsgContentEquals("Failed to parse import", function()
        import:import(invalidBase64Import)
    end)
end

function TestImportValidator:TestJsonImport()
    local import = AntiRaidTools.ImportPrototype:new()

    luaunit.assertIsTable(import:import(jsonImport))
end

function TestImportValidator:TestMinifiedJsonImport()
    local import = AntiRaidTools.ImportPrototype:new()

    luaunit.assertIsTable(import:import(minifiedJsonImport))
end

function TestImportValidator:TestEscapedMinifiedJsonImport()
    local import = AntiRaidTools.ImportPrototype:new()

    luaunit.assertIsTable(import:import(escapedMinifiedJsonImport))
end

function TestImportValidator:TestInvalidBase64Import()
    local import = AntiRaidTools.ImportPrototype:new()

    luaunit.assertErrorMsgContentEquals("Item of type `EVENT` is missing `id`", function()
        import:import(invalidJsonImport)
    end)
end
