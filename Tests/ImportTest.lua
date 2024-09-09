TestImport = {}

local base64Import = "W3sNCiAgICAidHlwZSI6ICJQQUNLIiwNCiAgICAidmVyc2lvbiI6IDEsDQogICAgImdhbWVWZXJzaW9uIjogIkNBVEEiLA0KICAgICJuYW1lIjogIlRoZSBiZXN0IHJhaWQgcGFjayIsDQogICAgImlkIjogInBhY2stMTIzIiwNCiAgICAicGFja1ZlcnNpb24iOiAxLA0KICAgICJpdGVtcyI6IFsNCiAgICAgICAgew0KICAgICAgICAgICAgInR5cGUiOiAiVFJJR0dFUiIsDQogICAgICAgICAgICAidmVyc2lvbiI6IDEsDQogICAgICAgICAgICAiZW5jb3VudGVyIjogMTA0MCwNCiAgICAgICAgICAgICJ0cmlnZ2VycyI6IFt7ICJ0eXBlIjogIlNQRUxMX0FVUkEiLCAic3BlbGxJZCI6IDEyMzQsICJkZWxheSI6IDEwLCAidGhyb3R0bGUiOiAzIH1dLA0KICAgICAgICAgICAgInVudHJpZ2dlcnMiOiBbeyAidHlwZSI6ICJFTU9URV9PUl9ZRUxMIiwgInRleHQiOiAiVGhpcyBlbmRzIG5vdyEiIH1dLA0KICAgICAgICAgICAgImlkIjogInRyaWdnZXItMSIsDQogICAgICAgIH0sDQogICAgICAgIHsNCiAgICAgICAgICAgICJ0eXBlIjogIkVWRU5UIiwNCiAgICAgICAgICAgICJ2ZXJzaW9uIjogMSwNCiAgICAgICAgICAgICJpZCI6ICJldmVudC0xIiwNCiAgICAgICAgICAgICJlbmNvdW50ZXIiOiAxMDQwLA0KICAgICAgICAgICAgIm5hbWUiOiAiJHtjdHgudHJpZ2dlci5zcGVsbE5hbWV9IG9uICR7Y3R4LnRyaWdnZXIuZGVzdFVuaXR9IGZvciAke3N0cmluZy5mb3JtYXQoJyUuMmYnLCBjdHgudHJpZ2dlci5hbW91bnQpfSIsDQogICAgICAgICAgICAidHJpZ2dlciI6ICJ0cmlnZ2VyLTEiLA0KICAgICAgICB9DQogICAgXQ0KfV0="
local minifiedBase64Import = "W3sidHlwZSI6IlBBQ0siLCJ2ZXJzaW9uIjoxLCJnYW1lVmVyc2lvbiI6IkNBVEEiLCJuYW1lIjoiVGhlIGJlc3QgcmFpZCBwYWNrIiwiaWQiOiJwYWNrLTEyMyIsInBhY2tWZXJzaW9uIjoxLCJpdGVtcyI6W3sidHlwZSI6IlRSSUdHRVIiLCJ2ZXJzaW9uIjoxLCJlbmNvdW50ZXIiOjEwNDAsInRyaWdnZXJzIjpbeyJ0eXBlIjoiU1BFTExfQVVSQSIsInNwZWxsSWQiOjEyMzQsImRlbGF5IjoxMCwidGhyb3R0bGUiOjN9XSwidW50cmlnZ2VycyI6W3sidHlwZSI6IkVNT1RFX09SX1lFTEwiLCJ0ZXh0IjoiVGhpcyBlbmRzIG5vdyEifV0sImlkIjoidHJpZ2dlci0xIn0seyJ0eXBlIjoiRVZFTlQiLCJ2ZXJzaW9uIjoxLCJpZCI6ImV2ZW50LTEiLCJlbmNvdW50ZXIiOjEwNDAsIm5hbWUiOiIke2N0eC50cmlnZ2VyLnNwZWxsTmFtZX0gb24gJHtjdHgudHJpZ2dlci5kZXN0VW5pdH0gZm9yICR7c3RyaW5nLmZvcm1hdCgnJS4yZicsIGN0eC50cmlnZ2VyLmFtb3VudCl9IiwidHJpZ2dlciI6InRyaWdnZXItMSJ9XX1d"
local invalidBase64Import = "W3sidHlwZSI6IlBBQ0siLCJ2ZXJzaW9uIjoxLCJuYW1lIjoiVGhlIGJlc3QgcmFpZCBwYWNrIiwiaWQiOiJwYWNrLTEyMyIsInBhY2tWZXJzaW9uIjoxLCJpdGVtcyI6W3sidHlwZSI6IlRSSUdHRVIiLCJ2ZXJzaW9uIjoxLCJlbmNvdW50ZXIiOjEwNDAsInRyaWdnZXJzIjpbeyJ0eXBlIjoiU1BFTExfQVVSQSIsInNwZWxsSWQiOjEyMzQsImRlbGF5IjoxMCwidGhyb3R0bGUiOjN9XSwidW50cmlnZ2VycyI6W3sidHlwZSI6IkVNT1RFX09SX1lFTEwiLCJ0ZXh0IjoiVGhpcyBlbmRzIG5vdyEifV0sImlkIjoidHJpZ2dlci0xIn0seyJ0eXBlIjoiRVZFTlQiLCJ2ZXJzaW9uIjoxLCJlbmNvdW50ZXIiOjEwNDAsIm5hbWUiOiIke2N0eC50cmlnZ2VyLnNwZWxsTmFtZX0gb24gJHtjdHgudHJpZ2dlci5kZXN0VW5pdH0gZm9yICR7c3RyaW5nLmZvcm1hdCgnJS4yZicsIGN0eC50cmlnZ2VyLmFtb3VudCl9IiwidHJpZ2dlciI6InRyaWdnZXItMSJ9XX1d"

local jsonImport = [[
    [{
        "type": "PACK",
        "version": 1,
        "gameVersion": "CATA",
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
    [{"type":"PACK","version":1,"gameVersion":"CATA","name":"The best raid pack","id":"pack-123","packVersion":1,"items":[{"type":"TRIGGER","version":1,"encounter":1040,"triggers":[{"type":"SPELL_AURA","spellId":1234,"delay":10,"throttle":3}],"untriggers":[{"type":"EMOTE_OR_YELL","text":"This ends now!"}],"id":"trigger-1"},{"type":"EVENT","version":1,"id":"event-1","encounter":1040,"name":"${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f', ctx.trigger.amount)}","trigger":"trigger-1"}]}]
]]

local escapedMinifiedJsonImport = '[{"type":"PACK","version":1,"gameVersion":"CATA","name":"The best raid pack","id":"pack-123","packVersion":1,"items":[{"type":"TRIGGER","version":1,"encounter":1040,"triggers":[{"type":"SPELL_AURA","spellId":1234,"delay":10,"throttle":3}],"untriggers":[{"type":"EMOTE_OR_YELL","text":"This ends now!"}],"id":"trigger-1"},{"type":"EVENT","version":1,"id":"event-1","encounter":1040,"name":"${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format(\'%.2f\', ctx.trigger.amount)}","trigger":"trigger-1"}]}]'

local invalidJsonImport = [[
    [{
        "type": "PACK",
        "version": 1,
        "gameVersion": "CATA",
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
    luaunit.assertIsTable(addon.import:Import(base64Import))
end

function TestImport:TestMinifiedBase64Import()
    luaunit.assertIsTable(addon.import:Import(minifiedBase64Import))
end

function TestImport:TestInvalidBase64Import()
    luaunit.assertErrorMsgContentEquals("Failed to parse import", function()
        addon.import:Import(invalidBase64Import)
    end)
end

function TestImport:TestJsonImport()
    luaunit.assertIsTable(addon.import:Import(jsonImport))
end

function TestImport:TestMinifiedJsonImport()
    luaunit.assertIsTable(addon.import:Import(minifiedJsonImport))
end

function TestImport:TestEscapedMinifiedJsonImport()
    luaunit.assertIsTable(addon.import:Import(escapedMinifiedJsonImport))
end

function TestImport:TestInvalidJsonImport()
    luaunit.assertErrorMsgContentEquals("Item of type `EVENT` is missing `id`", function()
        addon.import:Import(invalidJsonImport)
    end)
end
