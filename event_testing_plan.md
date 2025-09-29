# PP MAMS Event Testing Plan

## Objective
Test verified X4 events to determine which (if any) fire when pilots are dismissed/assigned.

## Verified Events (from working extensions)
- `event_player_alert` - Player alerts (could include pilot alerts)
- `event_player_owned_killed_object` - Player objects destroyed/removed (might include pilot dismissal)
- `event_ui_triggered` - UI interactions (might fire on pilot management UI)
- `event_cue_signalled` - Manual cue signaling
- `event_game_loaded` - Game startup
- `event_universe_generated` - Universe creation

## Testing Strategy
**Phase 1: Single Event Test**
- Choose ONE event to test: `event_player_alert`
- Rationale: Most likely to fire for pilot-related alerts
- Implementation: Simple listener that outputs to messages window
- Version: Update to v2.03

**Test Implementation:**
```xml
<cue name="AlertEventTest" instantiate="true">
  <conditions>
    <event_player_alert />
  </conditions>
  <actions>
    <debug_text text="'PP MAMS: event_player_alert fired'" />
    <show_notification caption="'PP MAMS Event Test'" text="'event_player_alert detected'" />
  </actions>
</cue>
```

**Test Procedure:**
1. Deploy updated mod (v2.03)
2. Fire a pilot from any ship
3. Watch for PP MAMS notification
4. Check debug log for event confirmation

**Success Criteria:**
- Notification appears when pilot is dismissed
- Debug log shows event firing
- Can examine event parameters if available

**Next Steps:**
- If successful: Examine event parameters to filter for pilot-specific alerts
- If unsuccessful: Test next event (`event_player_owned_killed_object`)
- Continue until we find working event or exhaust verified list

## Notes
- Focus on ONE event at a time to avoid confusion
- Use both notification and debug output for confirmation
- Document exact trigger conditions for successful events