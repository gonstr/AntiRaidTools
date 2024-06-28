# Docs

## Import API spec

The import should be a list of items, where each item is separated by `---`. The import should be valid `yaml`.

Example import:

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
metadata: { name: "Grip of Death", icon: 77764 }
strategy: { type: BEST_MATCH }
assignments:
- [{ type: SPELL, player: Riphyrra, spell_id: 77764 }]
- [{ type: SPELL, player: Jamón, spell_id: 77764 }]
- [{ type: SPELL, player: Clutex, spell_id: 77764 }]
- [{ type: SPELL, player: Crawlern, spell_id: 77764 }]
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
