# Docs

## Import API format

The import should be a list of items. The list should be valid `json`. The import can also be base64 encoded.

Every item follow a specific schema. All items have the required fields `type` and `version`.

An example import could look like this:

```json
[{
    "type": "PACK",
    "version": 1,
    "name": "Some raid pack",
    "id": "pack-123",
    "packVersion": 1,
    "items": [{
        "type": "TIMER",
        "version": 1,
        "id": "timer-1",
        "triggers": [{ "type": "UNIT_HEALTH", "unit": "boss1", "lessThanPct": 80 }],
        "untriggers": [{ "type": "EMOTE_OR_YELL", "text": "This ends now!" }],
        "name": "Some ability",
    }]
}]
```

### Item types

For `type`, the supported values are:
- `PACK`
- `TRIGGER`
- `TIMER`
- `STATE`
- `EVENT`
- `RAID_FRAME_ICON`
- `SOUND`

Fow now, all types are of version `1`. 

### encounterId

Most list items only make sense within an encounter, and requires an `encounter` field.

See https://wowpedia.fandom.com/wiki/DungeonEncounterID for a list of values.

## Packs

Packs are used as a way to distribute a list of items. This can be used to distrubute a raid or boss pack or any other collection of items.

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

## Timers

A timer represent a boss timer.

Example trigger:

```json
{
    "type": "TIMER",
    "version": 1,
    "id": "timer-1",
    "encounter": 1040,
    "name": "Boss ability",
    "trigger": "trigger-1",
    "group": "boss1",
}
```

`group` is optional.

## States

States represent some encounter state that we want to show. For example, the health of an encounter add. A debuff on a tank.

Example state:

```json
{
    "type": "STATE",
    "version": 1,
    "id": "state-1",
    "encounter": 1040,
    "name": "Some debuff",
    "trigger": "trigger-1",
    "group": "tank-debuffs",
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
    "name": "${ctx.trigger.spellName} on ${ctx.trigger.destUnit} for ${string.format('%.2f'), ctx.trigger.amount)}",
    "trigger": "trigger-1",
}
```

## Raid Frame icons

Represents a raid frame icon.

Example state:

```json
{
    "type": "RAID_FRAME_ICON",
    "version": 1,
    "id": "raid-frame-icon-1",
    "encounter": 1040,
    "trigger": "trigger-1",
    "icon": "Ability_rogue_deviouspoisons",
}
```

`icon` is optional.

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

`icon` is optional.

## Triggers and Untriggers

Triggers and untriggers are used in all the encounter types.

Supported trigger types are:
- `UNIT_HEALTH`
- `SPELL_AURA`
- `SPELL_CAST`
- `EMOTE_OR_YELL`

Depending on the trigger type, various other trigger fields are required. All triggers support `countdown`, `delay` and `throttle`.

Example trigger:

```json
{ "type": "UNIT_HEALTH", "unit": "boss1", "lessThanPct": 80, "delay": 10, "throttle": 5 }
```

### UNIT_HEALTH

```yaml
triggers:
    type: UNIT_HEALTH
    unit: boss1
    lessThanPct: 20
```

requires either `lessThan`, `greaterThan`, `lessThanPct` or `greaterThanPct`.

### SPELL_AURA

```yaml
triggers:
    type: SPELL_AURA
    spell_id: 12345
```

### SPELL_CAST

```yaml
triggers:
    type: SPELL_CAST
    spell_id: 12345
```

### EMOTE_OR_YELL

```yaml
triggers:
    type: EMOTE_OR_YELL
    text: "The air crackles with energy!"
```

### Countdown, duration, delay and throttle

For most triggers, `countdown` and `duration` fields can also be set.

`countdown` is used in the user interface for triggers where it makes sense to do a countdown. For `SPELL_CAST` triggers the countdown will be the casttime of the spell if one exists.

`delay` delays the trigger.

`throttle` prevents the trigger from being triggered multiple times within a time window.

## Example Import

```json
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
            "triggers": [{ "type": "SPELL_AURA", "spellId": "1234", "delay": 10, "throttle": 3 }],
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
```
