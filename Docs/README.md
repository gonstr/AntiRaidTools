# Docs

## Import API format

The import should be a list of items. The list should be valid json. The import can also be base64 encoded.

Every item follow a specific schema. All items have the required fields type and version.

An example import could look like this:

```json
[{
  "type": "PACK",
  "version": 1,
  "name": "Some raid pack",
  "id": "pack-123",
  "packVersion": 1,
  "items": [{
    "type": "EVENT",
    "version": 1,
    "id": "event-1",
    "encounter": 1040,
    "name": "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f'), ctx.trigger.amount)}",
    "trigger": "trigger-1",
  }]
}]
```

### Item types

For type, the supported values are:

- `PACK`
- `TRIGGER`
- `EVENT`
- `UNIT_FRAME_ICON`
- `UNIT_FRAME_GLOW`
- `COMM`
- `SOUND`

Fow now, all types are of version 1. 

### encounterId

Most list items only make sense within an encounter, and requires an encounter field.

See https://wowpedia.fandom.com/wiki/DungeonEncounterID for a list of values.

## Packs

Packs are used as a way to distribute a list of items. This can be used to distrubute a raid or boss pack or any other collection of items.

```json
{
  "type": "PACK",
  "version": 1,
  "gameVersion": "CATA",
  "name": "Some raid pack",
  "id": "pack-123",
  "packVersion": 1,
  "author": "Team ART",
  "options": {
    "headerTexture": "interface/questionframe/warboardzonescata",
    "headerTexCords": [0.0009765625, 0.2626953125, 0.001953125, 0.240234375],
    "groups": [{
      "header": "Boss name",
      "items": [{
        "type": "TOGGLE",
        "name": "Some ability",
        "description": "Enable notifications and raid icons for ability 123",
        "id": "ability-1",
        "default": true
      }]
    }]
  },
  "items": [{
      "type": "TRIGGER",
      "version": 1,
      "id": "trigger-1",
      "encounter": 1035,
      "triggers": [{ "type": "SPELL_AURA", "spellId": 1234 }],
      "untriggers": [{ "type": "EMOTE_OR_YELL", "text": "This ends now!" }],
    },{
      "type": "EVENT",
      "version": 1,
      "id": "event-1",
      "encounter": 1040,
      "name": "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f'), ctx.trigger.amount)}",
      "trigger": "trigger-1",
  }]
}
```

## Triggers

A reusable trigger.

Example trigger:

```json
{
  "type": "TRIGGER",
  "version": 1,
  "id": "trigger-1",
  "triggers": [{ "type": "SPELL_AURA", "spellId": "1234" }],
  "untriggers": [{ "type": "EMOTE_OR_YELL", "text": "This ends now!" }],
}
```

## Events

Events represent some encounter event that we want to show in a temporary timer or popup.

Example state:

```json
{
  "type": "EVENT",
  "version": 1,
  "id": "event-1",
  "encounter": 1040,
  "name": "${utils:FormatColor(ctx.trigger.spellName, 'RED')}",
  "warn": "${ctx.trigger.destName == UnitName('player')}",
  "trigger": "trigger-1",
}
```

## Unit Frame Icons

Represents a raid frame icon.

Example state:

```json
{
  "type": "UNIT_FRAME_ICON",
  "version": 1,
  "id": "unit-frame-icon-1",
  "encounter": 1040,
  "trigger": "trigger-1",
  "icon": "Ability_rogue_deviouspoisons",
}
```

if icon is not provided, it will be infered from the trigger.

## Unit Frame Glow

Represents a raid frame border glow.

Example state:

```json
{
  "type": "UNIT_FRAME_GLOW",
  "version": 1,
  "id": "unit-frame-glow-1",
  "encounter": 1040,
  "trigger": "trigger-1",
  "type": "AUTOCAST",
  "color": [ 0.95, 0.95, 0.32, 1 ]
}
```

color is RGBA and is optional. type can be AUTOCAST, PIXEL or BUTTON.

## Comm

Represents a some form of communication (say, yell).

Example comm:

```json
{
  "type": "COMM",
  "version": 1,
  "id": "say-1",
  "encounter": 1040,
  "trigger": "trigger-1",
  "type": "SAY",
  "text": "Ability on me!",
}
```

## Sounds

Represents a sound or tts.

Example sound:

```json
{
  "type": "SOUND",
  "version": 1,
  "id": "sound-1",
  "encounter": 1040,
  "trigger": "trigger-1",
  "sound": "Ability_rogue_deviouspoisons",
}
```

icon is optional.

## Conditional loading

If you created a pack with options, you might want to conditionally load an item.

Example:

```json
{
  "type": "PACK",
  "version": 1,
  "name": "Some raid pack",
  "id": "pack-123",
  "packVersion": 1,
  "options": [{
    "sections": [{
      "header": "Boss name",
      "subSections": [{
        "header": "Events",
        "items": [{
          "type": "TOGGLE",
          "name": "Some ability",
          "id": "ability-1",
          "default": true
        }]
      }]
    }]
  }],
  "items": [{
    "type": "EVENT",
    "version": 1,
    "id": "event-1",
    "encounter": 1040,
    "name": "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f'), ctx.trigger.amount)}",
    "trigger": "trigger-1"
  }]
}
```

## Triggers and Untriggers

Triggers and untriggers are used in all the encounter types.

Supported trigger types are:

- `UNIT_HEALTH`
- `SPELL_CAST`
- `SPELL_AURA`
- `SPELL_AURA_REMOVED`
- `EMOTE_OR_YELL`

Depending on the trigger type, various other trigger fields are required. All triggers support countdown, delay and throttle.

Example trigger:

```json
{ "type": "UNIT_HEALTH", "unit": "boss1", "lessThanPct": 80, "delay": 10, "throttle": 5 }
```

### UNIT_HEALTH

```json
"triggers": {
  "type": "UNIT_HEALTH",
  "unit": "boss1",
  "lessThanPct": 20
}
```

requires either `lessThan`, `greaterThan`, `lessThanPct` or `greaterThanPct`.

### SPELL_AURA

Triggers on both `SPELL_AURA_APPLIED` and `SPELL_AURA_REFRESH`.

```json
"triggers": {
  "type": "SPELL_AURA",
  "spellId": 12345
}
```

### SPELL_AURA_REMOVED

```json
"triggers": {
  "type": "SPELL_AURA_REMOVED",
  "spellId": 12345
}
```

### SPELL_CAST

```json
"triggers": {
  "type": "SPELL_CAST",
  "spellId": 12345
}
```

### EMOTE_OR_YELL

```json
"triggers": {
  "type": "EMOTE_OR_YELL",
  "text": "The air crackles with energy!"
}
```

### Countdown, duration, delay and throttle

For most triggers, `countdown`, `duration`, `delay` and `throttle` fields can also be set.

All fields are optional.

#### Countdown

Used in the user interface for triggers where it makes sense to do a countdown. For `SPELL_CAST` triggers countdown will be the casttime of the spell if one exists.

#### Duration

How long the trigger will be active for. The defualt is `5` seconds.

#### Delay

Delay the trigger execution. If an `untrigger` triggers during the delay, the trigger will be cancelled before it's run.

#### Throttle

Prevents the trigger from being triggered multiple times within a time window.
