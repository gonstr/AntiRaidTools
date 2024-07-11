# Docs

## Import API spec

The import should be a list of items, where each item is separated by `---`. The import should be valid `yaml`.

### Type

The item type. Can only be `RAID_ASSIGNMENTS`.

### Encounter

The encounter ID.

See https://wowpedia.fandom.com/wiki/DungeonEncounterID.

### Trigger

The item trigger. Can be of types `UNIT_HEALTH`, `SPELL_CAST`, `SPELL_AURA`, `RAID_BOSS_EMOTE` or `FOJJI_NUMEN_TIMER`.

#### UNIT_HEALTH

```yaml
triggers:
    type: UNIT_HEALTH
    unit: boss1
    percentage: 20
```

#### SPELL_AURA

```yaml
triggers:
    type: SPELL_AURA
    spell_id: 12345
```

#### SPELL_CAST

```yaml
triggers:
    type: SPELL_CAST
    spell_id: 12345
```

#### RAID_BOSS_EMOTE

```yaml
triggers:
    type: RAID_BOSS_EMOTE
    text: "The air crackles with energy!"
```

#### FOJJI_NUMEN_TIMER

```yaml
triggers:
    type: FOJJI_NUMEN_TIMER
    key: HALFUS_PROTOBREATH
```

### Countdown and duration

For most triggers, `countdown` and `duration` fields can also be set. The `countdown` value controls the countdown timer in the raid assignments popup. `duration` control how long the popup will be visible for.

### Strategy

The strategy for deciding how to display raid assignments. Can be of types `BEST_MATCH`, and `CHAIN`.

#### BEST_MATCH

If the stategy is set to `BEST_MATCH`, the addon will choose what it considers to be the best match in the assignments array whenever the item triggers. The addon will choose an assignments, from top to bottom, where
the most number of raid CDs are avaible.

E.g with these assignemnts:

```yaml
strategy:
    type: BEST_MATCH
assignments:
- [{ type: SPELL, player: Sîf, spell_id: 97462 }, { type: SPELL, player: Anticipâte, spell_id: 31821 }]
- [{ type: SPELL, player: Solfernus, spell_id: 51052 }, { type: SPELL, player: Kondec, spell_id: 62618 }]
```

If all raid CDS being available and off cooldown, the best match would be the first row.

If player `Sîf` has already used Rallying Cry (97462), the best match would be the second row of assignments.

If player `Anticipâte` is dead, the best match would also be the second row of assignments.

#### CHAIN

If the stategy is set to `CHAIN`, the addon will show all available assignments in a list. This can be useful if you want to chain raid CDs during phases of boss fights.

### Assignments

The list of assignments for this trigger. Can only be of type `SPELL`.

### Example Import

```yaml
type: RAID_ASSIGNMENTS
encounter: 1024
trigger: { type: UNIT_HEALTH, unit: boss1, percentage: 35 }
metadata: { name: "Boss 25%" }
strategy: { type: CHAIN }
assignments:
- [{ type: SPELL, player: Anticipâte, spell_id: 31821 }]
- [{ type: SPELL, player: Kondec, spell_id: 62618 }]
- [{ type: SPELL, player: Venmir, spell_id: 98008 }]
---
type: RAID_ASSIGNMENTS
encounter: 1027
trigger: { type: SPELL_CAST, spell_id: 91849 }
metadata: { name: "Grip of Death" }
strategy: { type: BEST_MATCH }
assignments:
- [{ type: SPELL, player: Riphyrra, spell_id: 77764 }]
- [{ type: SPELL, player: Jamón, spell_id: 77764 }]
- [{ type: SPELL, player: Clutex, spell_id: 77764 }]
- [{ type: SPELL, player: Crawlern, spell_id: 77764 }]
---
type: RAID_ASSIGNMENTS
encounter: 1022
trigger: { type: FOJJI_NUMEN_TIMER, key: ATRAMEDES_SEARING_FLAME, duration: 7 }
metadata: { name: Flames }
strategy: { type: BEST_MATCH }
assignments: 
- [{ type: SPELL, player: Sîf, spell_id: 97462 }, { type: SPELL, player: Anticipâte, spell_id: 31821 }]
- [{ type: SPELL, player: Solfernus, spell_id: 51052 }, { type: SPELL, player: Kondec, spell_id: 62618 }]
---
type: RAID_ASSIGNMENTS
encounter: 1026
trigger: { type: RAID_BOSS_EMOTE, text: "The air crackles with electricity!", countdown: 5, duration: 10 }
metadata: { name: "Crackle" }
strategy: { type: BEST_MATCH }
assignments:
- [{ type: SPELL, player: Anticipâte, spell_id: 31821 }, { type: SPELL, player: Kondec, spell_id: 62618 }]
- [{ type: SPELL, player: Managobrr, spell_id: 64843 }, { type: SPELL, player: Venmir, spell_id: 98008 }]
```
