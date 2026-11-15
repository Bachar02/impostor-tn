---
name: test-gameplay
description: Verify Impostor TN gameplay rules against the PRD by auditing and extending the deterministic engine and recovery tests. Use when asked to test gameplay, check rule coverage, or validate voting, runoff, final guess, cooldown or recovery.
---

# Test gameplay

Goal: every rule in the PRD has a deterministic test that would fail if the rule were broken.

1. **Build the rule matrix** from `docs/product/PRD.md` §4–§11 and `docs/product/DECISIONS.md`. One row per rule, with the PRD reference.
2. **Map rows to tests** under `test/game/` and `test/data/`. Mark each row covered, partially covered or missing. A test that only checks the happy path is "partial".
3. **Write the missing tests.** Use seeded `Random` and fakes only. Minimum scenarios:
   - **Setup:** start accepted for every count 4–12; rejected for 3 and 13; rejected with no available pack.
   - **Roles:** exactly one Impostor across many seeds and all counts; the Impostor view holds no word or alias; assignment identical after save and restore.
   - **Reveal:** acknowledge required to advance; interruption before commit lets the same player reveal again; after commit the next pending player is up; the last acknowledgement moves to discussion.
   - **Voting:** self-vote rejected; second vote by the same player rejected; vote change rejected (D-03); ballot closes only when everyone has voted.
   - **Outcome:** unique top → nominated; 2-way, 3-way and all-way top ties → runoff with exactly the tied candidates; lower-ranked ties do not trigger a runoff.
   - **Runoff:** all players vote; tied candidates cannot self-vote; first-ballot votes do not carry over; unique winner nominated; tie → draw with no final guess.
   - **Final guess:** canonical match; alias match; leading, trailing and repeated inner whitespace accepted (D-01); diacritic, tatweel, ق/ڨ and ة/ه variants rejected unless listed as aliases; empty guess handled.
   - **Result:** civilian nominated → Impostor wins; Impostor nominated with correct guess → Impostor wins; wrong guess → civilians win; runoff tie → draw.
   - **Cooldown:** last 30 distinct IDs excluded; recorded once per game; not recorded when abandoned before reveal; oldest entries released progressively when everything is excluded; controlled error when no approved content exists; selection always terminates.
   - **Recovery:** kill and restore at every checkpoint; duplicate submission after restore is rejected; corrupt or incompatible state cancels the session without inventing data.
4. **Run** `flutter test test/game test/data` and record the counts.
5. **Mutation spot-check.** For three critical rules (one Impostor, self-vote, runoff tie), temporarily break the rule, confirm a test fails, then restore the code and re-run.

## Output

The rule matrix with status per row, tests added, exact test results, and rules that cannot be tested yet with the reason. Never include a real secret word in a test name.

If `lib/game/` does not exist yet, report that gameplay is not implemented and stop.
