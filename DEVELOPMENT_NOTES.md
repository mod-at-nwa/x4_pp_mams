
## 2025-09-29: CRITICAL DISCOVERY - No Pilot Firing Events in X4

**PROBLEM IDENTIFIED:**
- PP MAMS v3.06 uses periodic 30-second scanning
- When pilot is fired, NO detection occurs
- Checked debug logs around firing events (timestamps 65355-65364)

**INVESTIGATION RESULTS:**
- X4 triggers conversation events: `g_pilotleave_confirmation` and `g_pilotleave`
- These are **internal conversation system events** - NOT subscribable MD events
- No MD event like `event_pilot_fired` or `event_personnel_changed` exists
- Side effects observed: AI order cancellations, but unreliable for detection

**CONCLUSION:**
X4 does NOT broadcast an MD script event when pilots are fired. There is no `event_pilot_fired` or similar to listen for.

**IMPLICATION:**
Cannot implement event-driven pilot firing detection. Must use alternative approach (periodic scanning is currently the only viable method, or hook into conversation system somehow).


## 2025-09-29: CRITICAL DISCOVERY - No Pilot Firing Events in X4

**PROBLEM IDENTIFIED:**
- PP MAMS v3.06 uses periodic 30-second scanning
- When pilot is fired, NO detection occurs
- Checked debug logs around firing events (timestamps 65355-65364)

**INVESTIGATION RESULTS:**
- X4 triggers conversation events: `g_pilotleave_confirmation` and `g_pilotleave`
- These are **internal conversation system events** - NOT subscribable MD events
- No MD event like `event_pilot_fired` or `event_personnel_changed` exists
- Side effects observed: AI order cancellations, but unreliable for detection

**CONCLUSION:**
X4 does NOT broadcast an MD script event when pilots are fired. There is no `event_pilot_fired` or similar to listen for.

**IMPLICATION:**
Cannot implement event-driven pilot firing detection. Must use alternative approach (periodic scanning is currently the only viable method, or hook into conversation system somehow).

