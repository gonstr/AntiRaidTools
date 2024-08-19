TestImport = {}

local base64Import = "W3sNCiAgICAidHlwZSI6ICJQQUNLIiwNCiAgICAidmVyc2lvbiI6IDEsDQogICAgIm5hbWUiOiAiVGhlIGJlc3QgcmFpZCBwYWNrIiwNCiAgICAiaWQiOiAicGFjay0xMjMiLA0KICAgICJwYWNrVmVyc2lvbiI6IDEsDQogICAgIml0ZW1zIjogWw0KICAgICAgICB7DQogICAgICAgICAgICAidHlwZSI6ICJUUklHR0VSIiwNCiAgICAgICAgICAgICJ2ZXJzaW9uIjogMSwNCiAgICAgICAgICAgICJlbmNvdW50ZXIiOiAxMDQwLA0KICAgICAgICAgICAgInRyaWdnZXJzIjogW3sgInR5cGUiOiAiU1BFTExfQVVSQSIsICJzcGVsbElkIjogMTIzNCwgImRlbGF5IjogMTAsICJ0aHJvdHRsZSI6IDMgfV0sDQogICAgICAgICAgICAidW50cmlnZ2VycyI6IFt7ICJ0eXBlIjogIkVNT1RFX09SX1lFTEwiLCAidGV4dCI6ICJUaGlzIGVuZHMgbm93ISIgfV0sDQogICAgICAgICAgICAiaWQiOiAidHJpZ2dlci0xIiwNCiAgICAgICAgfSwNCiAgICAgICAgew0KICAgICAgICAgICAgInR5cGUiOiAiRVZFTlQiLA0KICAgICAgICAgICAgInZlcnNpb24iOiAxLA0KICAgICAgICAgICAgImlkIjogImV2ZW50LTEiLA0KICAgICAgICAgICAgImVuY291bnRlciI6IDEwNDAsDQogICAgICAgICAgICAibmFtZSI6ICIke2N0eC50cmlnZ2VyLnNwZWxsTmFtZX0gb24gJHtjdHgudHJpZ2dlci5kZXN0VW5pdH0gZm9yICR7c3RyaW5nLmZvcm1hdCgnJS4yZicsIGN0eC50cmlnZ2VyLmFtb3VudCl9IiwNCiAgICAgICAgICAgICJ0cmlnZ2VyIjogInRyaWdnZXItMSIsDQogICAgICAgIH0NCiAgICBdDQp9XQ=="
local minifiedBase64Import = "W3sidHlwZSI6IlBBQ0siLCJ2ZXJzaW9uIjoxLCJuYW1lIjoiVGhlIGJlc3QgcmFpZCBwYWNrIiwiaWQiOiJwYWNrLTEyMyIsInBhY2tWZXJzaW9uIjoxLCJpdGVtcyI6W3sidHlwZSI6IlRSSUdHRVIiLCJ2ZXJzaW9uIjoxLCJlbmNvdW50ZXIiOjEwNDAsInRyaWdnZXJzIjpbeyJ0eXBlIjoiU1BFTExfQVVSQSIsInNwZWxsSWQiOjEyMzQsImRlbGF5IjoxMCwidGhyb3R0bGUiOjN9XSwidW50cmlnZ2VycyI6W3sidHlwZSI6IkVNT1RFX09SX1lFTEwiLCJ0ZXh0IjoiVGhpcyBlbmRzIG5vdyEifV0sImlkIjoidHJpZ2dlci0xIn0seyJ0eXBlIjoiRVZFTlQiLCJ2ZXJzaW9uIjoxLCJpZCI6ImV2ZW50LTEiLCJlbmNvdW50ZXIiOjEwNDAsIm5hbWUiOiIke2N0eC50cmlnZ2VyLnNwZWxsTmFtZX0gb24gJHtjdHgudHJpZ2dlci5kZXN0VW5pdH0gZm9yICR7c3RyaW5nLmZvcm1hdCgnJS4yZicsIGN0eC50cmlnZ2VyLmFtb3VudCl9IiwidHJpZ2dlciI6InRyaWdnZXItMSJ9XX1d"
local invalidBase64Import = "W3sidHlwZSI6IlBBQ0siLCJ2ZXJzaW9uIjoxLCJuYW1lIjoiVGhlIGJlc3QgcmFpZCBwYWNrIiwiaWQiOiJwYWNrLTEyMyIsInBhY2tWZXJzaW9uIjoxLCJpdGVtcyI6W3sidHlwZSI6IlRSSUdHRVIiLCJ2ZXJzaW9uIjoxLCJlbmNvdW50ZXIiOjEwNDAsInRyaWdnZXJzIjpbeyJ0eXBlIjoiU1BFTExfQVVSQSIsInNwZWxsSWQiOjEyMzQsImRlbGF5IjoxMCwidGhyb3R0bGUiOjN9XSwidW50cmlnZ2VycyI6W3sidHlwZSI6IkVNT1RFX09SX1lFTEwiLCJ0ZXh0IjoiVGhpcyBlbmRzIG5vdyEifV0sImlkIjoidHJpZ2dlci0xIn0seyJ0eXBlIjoiRVZFTlQiLCJ2ZXJzaW9uIjoxLCJlbmNvdW50ZXIiOjEwNDAsIm5hbWUiOiIke2N0eC50cmlnZ2VyLnNwZWxsTmFtZX0gb24gJHtjdHgudHJpZ2dlci5kZXN0VW5pdH0gZm9yICR7c3RyaW5nLmZvcm1hdCgnJS4yZicsIGN0eC50cmlnZ2VyLmFtb3VudCl9IiwidHJpZ2dlciI6InRyaWdnZXItMSJ9XX1d"

local jsonImport = [[
    [{
        "type": "PACK",
        "version": 1,
        "name": "The best raid pack",
        "id": "pack-123",
        "packVersion": 1,
        "items": [
            {
                "type": "TRIGGER",
                "version": 1,
                "encounter": 1035,
                "triggers": [{ "type": "SPELL_AURA", "spellId": 1234, "delay": 10, "throttle": 3 }],
                "untriggers": [{ "type": "EMOTE_OR_YELL", "text": "This ends now!" }],
                "id": "trigger-1"
            },
            {
                "type": "EVENT",
                "version": 1,
                "id": "event-1",
                "encounter": 1035,
                "name": "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}",
                "trigger": "trigger-1"
            }
        ]
    }]
]]

local minifiedJsonImport = [[
    [{"type":"PACK","version":1,"name":"The best raid pack","id":"pack-123","packVersion":1,"items":[{"type":"TRIGGER","version":1,"encounter":1040,"triggers":[{"type":"SPELL_AURA","spellId":1234,"delay":10,"throttle":3}],"untriggers":[{"type":"EMOTE_OR_YELL","text":"This ends now!"}],"id":"trigger-1"},{"type":"EVENT","version":1,"id":"event-1","encounter":1040,"name":"${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}","trigger":"trigger-1"}]}]
]]

local escapedMinifiedJsonImport = '[{"type":"PACK","version":1,"name":"The best raid pack","id":"pack-123","packVersion":1,"items":[{"type":"TRIGGER","version":1,"encounter":1040,"triggers":[{"type":"SPELL_AURA","spellId":1234,"delay":10,"throttle":3}],"untriggers":[{"type":"EMOTE_OR_YELL","text":"This ends now!"}],"id":"trigger-1"},{"type":"EVENT","version":1,"id":"event-1","encounter":1040,"name":"${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format(\'%.2f\', ctx.trigger.amount)}","trigger":"trigger-1"}]}]'

local invalidJsonImport = [[
    [{
        "type": "PACK",
        "version": 1,
        "name": "The best raid pack",
        "id": "pack-123",
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

function TestImport:TestBase64Import()
    local import = addon.ImportPrototype:new()

    luaunit.assertIsTable(import:import(base64Import))
end

function TestImport:TestMinifiedBase64Import()
    local import = addon.ImportPrototype:new()

    luaunit.assertIsTable(import:import(minifiedBase64Import))
end

function TestImport:TestInvalidBase64Import()
    local import = addon.ImportPrototype:new()

    luaunit.assertErrorMsgContentEquals("Failed to parse import", function()
        import:import(invalidBase64Import)
    end)
end

function TestImport:TestJsonImport()
    local import = addon.ImportPrototype:new()

    luaunit.assertIsTable(import:import(jsonImport))
end

function TestImport:TestMinifiedJsonImport()
    local import = addon.ImportPrototype:new()

    luaunit.assertIsTable(import:import(minifiedJsonImport))
end

function TestImport:TestEscapedMinifiedJsonImport()
    local import = addon.ImportPrototype:new()

    luaunit.assertIsTable(import:import(escapedMinifiedJsonImport))
end

function TestImport:TestInvalidBase64Import()
    local import = addon.ImportPrototype:new()

    luaunit.assertErrorMsgContentEquals("Item of type `EVENT` is missing `id`", function()
        import:import(invalidJsonImport)
    end)
end
