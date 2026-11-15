# Impostor TN --- Product Requirements Document (PRD)

**Version:** 0.3\
**Status:** Approved product baseline\
**Product:** Impostor TN 🇹🇳\
**Platform:** Android (Flutter)\
**Primary language:** Tunisian Derja (Arabic script)\
**Product model:** Offline-first, single-device, pass-and-play party
game\
**Document purpose:** Product and gameplay source of truth for MVP
implementation.

> **Authority:** This document records the approved MVP requirements. Do
> not silently change gameplay rules, privacy behaviour, content policy,
> or scope. If implementation reveals ambiguity or contradiction, raise
> it for Product Owner approval.

------------------------------------------------------------------------

## 1. Product overview

Impostor TN is a local social-deduction party game played by 4--12
people sharing one Android phone. Most players receive the same secret
word and category. One player is the Impostor and receives only the
category. Players give verbal one-word clues, discuss, and vote to
identify the Impostor.

The experience should feel distinctly Tunisian through its language,
references, humour, and curated content---not merely through flags or
decorative motifs.

### Product goals

-   Make it easy for a group to start and complete a game on one shared
    phone.
-   Deliver reliable, fair gameplay with clear rules and no accidental
    information leaks.
-   Provide a polished, memorable visual identity and natural Tunisian
    Arabic experience.
-   Work fully offline without accounts or a backend.
-   Support a sustainable freemium model without compromising the MVP
    experience.

### Non-goals for MVP

-   Online multiplayer or remote play.
-   User accounts, cloud sync, or social profiles.
-   Backend services.
-   In-app purchases, subscriptions, or advertising.
-   Tournament scoring or persistent player rankings.
-   User-created or downloadable packs.
-   Multiple Impostors or advanced game modes.

------------------------------------------------------------------------

## 2. Target users and context

-   Groups of friends and family playing together in person.
-   One shared Android smartphone passed privately between players.
-   Players may have different levels of familiarity with party games.
-   The app must be understandable with minimal explanation.
-   Play may happen in bright or dim environments; private screens must
    remain legible and discreet.

### Core experience principles

1.  **Privacy first:** a player must not accidentally see another
    player's role.
2.  **Fast to understand:** onboarding and instructions should be
    concise.
3.  **Fairness:** voting, tie handling, word selection, and guessing
    must follow deterministic rules.
4.  **Cultural authenticity:** content and language require human review
    by people fluent in Tunisian Derja.
5.  **Offline reliability:** gameplay must not depend on network access.

------------------------------------------------------------------------

## 3. MVP scope and priorities

### P0 --- Required for MVP

-   Home screen and game setup.
-   4--12 player names and player order.
-   Word/category pack selection.
-   Exactly one Impostor per game.
-   Private role reveal and acknowledgement flow.
-   Discussion phase.
-   Private voting and one possible runoff.
-   Impostor's final guess when nominated.
-   Results screen and replay.
-   Word cooldown across sessions and app restarts.
-   Persistent session state and safe recovery.
-   Arabic RTL interface and Tunisian Derja copy.
-   Tutorial/help and basic settings.
-   Local content bundled with the app.
-   Privacy protections for sensitive screens and app switching.

### P1 --- Possible future enhancements, not MVP

-   Multiple Impostors.
-   Custom packs.
-   Tournament or cumulative scoring.
-   Difficulty settings.
-   Player statistics.
-   Additional themes.

### P2 --- Later possibilities, explicitly excluded from MVP

-   Downloadable content packs.
-   Online multiplayer.
-   Cloud synchronization and accounts.
-   Premium purchases, subscriptions, or advertising.

------------------------------------------------------------------------

## 4. Players and game setup

-   Minimum players: **4**.
-   Maximum players: **12**.
-   Each game has **exactly one Impostor**.
-   Players enter names and establish a playing order.
-   The game setup allows selection of available content packs.
-   Player names, player order, and selected packs should be retained
    for replay where practical and as specified in the approved UX.

Validation must prevent starting a game with fewer than 4 or more than
12 players, invalid/duplicate player entries where the UX requires
uniqueness, or an unavailable content selection.

------------------------------------------------------------------------

## 5. Word and role assignment

-   Civilian players receive the same secret word and its category.
-   The Impostor receives the category only.
-   The Impostor must never receive the secret word, an alias, a
    definition, or a related hint.
-   Role assignment must produce exactly one Impostor.
-   Role assignment and the selected word must remain stable throughout
    a game and after recovery.
-   The app must not reassign roles because the process was interrupted
    or restarted.

### Private role reveal

-   The phone is passed from player to player.
-   Each player must deliberately reveal their own role.
-   The player sees their role privately.
-   The player must then explicitly acknowledge that they have seen it.
-   Acknowledgement must be persisted before the app advances to the
    next player.
-   The role must not disappear merely because a timer expires.
-   A hold-to-reveal interaction alone is not sufficient; reveal and
    acknowledgement are separate actions.
-   Civilian and Impostor reveal screens must use the same overall
    structure and must not leak the role through obvious layout or
    background differences.
-   After acknowledgement, the app returns to a neutral handoff state
    before the next player.
-   If the app is interrupted before acknowledgement is committed, the
    same player may reveal again.
-   If acknowledgement was committed, recovery must continue with the
    next pending player.

The UI must make it clear whose turn it is without exposing the previous
player's role.

------------------------------------------------------------------------

## 6. Discussion and clue rules

-   Once all players have viewed and acknowledged their roles, the game
    moves to discussion.
-   Players give **one-word verbal clues** related to the secret word.
-   A player may verbally pass rather than provide a clue.
-   Clues are spoken aloud; the MVP does not need to record or validate
    them.
-   The app should communicate the rules clearly and provide an obvious
    transition to voting when the group is ready.

------------------------------------------------------------------------

## 7. Voting

### First ballot

-   Every player must vote once.
-   Voting is private on the shared device.
-   A player cannot vote for themselves.
-   The app must prevent skipping, duplicate voting, or changing a
    submitted vote unless the approved UX explicitly provides a
    correction step.
-   Votes must not be exposed to players who should not see them during
    the ballot.

### First-ballot outcome

-   If one player has a unique highest vote count, that player is
    nominated.
-   If the highest vote count is tied, the game proceeds to exactly one
    runoff.
-   Do not resolve ties randomly or by player order.

### Runoff

-   All players participate in the runoff.
-   Only players tied at the top of the first ballot are eligible
    candidates.
-   A tied candidate cannot vote for themselves.
-   A player who was not among the tied candidates may vote for any tied
    candidate.
-   Votes from the first ballot do not carry over.
-   The runoff is a fresh ballot.

### Runoff outcome

-   A unique runoff winner is nominated.
-   If the runoff remains tied, the result is a draw.
-   An unresolved runoff tie does not lead to a final Impostor guess.

------------------------------------------------------------------------

## 8. Final guess and win conditions

If the nominated player is the Impostor:

1.  The phone is passed privately to the Impostor.
2.  The Impostor is given one final opportunity to enter a textual guess
    for the secret word.
3.  The guess is checked against the canonical word and its explicitly
    approved aliases.
4.  Matching is exact after only the approved normalization rules.
5.  No fuzzy matching, semantic matching, or approximate spelling
    acceptance is allowed.

### Normalization and aliases

-   Canonical words and aliases are curated in the content data.
-   Only explicitly approved normalization is allowed.
-   Do not indiscriminately normalize Arabic letter variants such as ق/ڨ
    or ة/ه.
-   Do not accept a guessed word merely because it is semantically
    related.
-   Content editors must add legitimate variants as explicit aliases.

### Win conditions

-   If the nominated player is a civilian, the Impostor wins.
-   If the nominated player is the Impostor and the final guess is
    correct, the Impostor wins.
-   If the nominated player is the Impostor and the final guess is
    incorrect, the civilians win.
-   If the runoff ends in a tie, the game is a draw and there is no
    final guess.

The result screen reveals the secret word, the Impostor, the votes, the
winner, and the final-guess outcome where applicable.

------------------------------------------------------------------------

## 9. Replay

-   Players should be able to start another game without re-entering
    retained player names and packs.
-   Replay must create a new game session and a new valid role
    assignment.
-   No cumulative tournament score is included in MVP.
-   Cooldown history must carry across replay and across separate
    sessions.

------------------------------------------------------------------------

## 10. Word content and cooldown

### Content target

-   Target **200--300 curated free words** for the initial content
    library.
-   Content should reflect Tunisian culture and everyday life: food,
    places, cities, football, entertainment, expressions, and familiar
    experiences.
-   Avoid content that is obscure, ambiguous, culturally insensitive, or
    difficult to clue fairly.
-   Pack/category selection must only expose content that is approved
    and available.

### Required word metadata

Each word record must support:

-   Stable unique ID.
-   Canonical word.
-   Explicit aliases.
-   Category.
-   Difficulty (if used by the content system).
-   Language.
-   Region or cultural context where relevant.
-   Pack.
-   Content version.
-   Access status (free or otherwise, if applicable to future scope).
-   Editorial status.

Do not expose unpublished or unreviewed content in production gameplay.

### Human review

Every published word must have two distinct human reviews:

1.  A Tunisian Derja linguistic reviewer.
2.  An independent gameplay/editorial reviewer.

The Product Owner coordinates the review process. Do not fabricate
reviewer names, approvals, or completed review status. A word is not
approved merely because an automated validator passes it.

### Cooldown

-   Maintain a cooldown of the **30 most recently used distinct word
    IDs**.
-   Cooldown applies across sessions, packs, and application restarts.
-   Record a word atomically before the first private role reveal is
    prepared.
-   An interrupted reveal must not record the word a second time.
-   A game abandoned before the first reveal must not consume a word.
-   When all candidate words are excluded by cooldown, release the
    oldest cooldown entries progressively until an eligible word exists.
-   The selection process must terminate in a bounded and predictable
    way.
-   If no eligible approved content exists, return a controlled,
    understandable error rather than crashing or silently selecting
    invalid content.

Cooldown logic must be deterministic and covered by tests.

------------------------------------------------------------------------

## 11. Persistence and recovery

Persist enough session state to resume safely, including:

-   Player names and order.
-   Selected packs.
-   Secret word reference.
-   Impostor assignment.
-   Current game phase.
-   Role reveal progress.
-   Acknowledgement status for each player.
-   Votes and ballot identity.
-   First-ballot and runoff state.
-   Final guess submission and outcome.
-   Result state.

### Reliability requirements

-   Use atomic checkpoints for important transitions.
-   Do not advance a phase until its required state is safely persisted.
-   Do not duplicate votes or word consumption after retries or
    restarts.
-   Do not regenerate roles or secret words when restoring an existing
    session.
-   Handle process termination at every sensitive transition.
-   If saved state is corrupted or cannot be safely interpreted, cancel
    the session safely. Never invent votes, reassign roles, or expose
    secrets to recover by guessing.

The technical architecture must document the persistence mechanism,
transaction boundaries, schema/version strategy, and recovery behaviour
before implementation.

------------------------------------------------------------------------

## 12. Privacy and device security

The phone is shared, so privacy is a core gameplay requirement.

-   Use neutral handoff screens between players.
-   Require deliberate role reveal and explicit acknowledgement.
-   Hide private information immediately after acknowledgement.
-   Do not advance until acknowledgement is persisted.
-   Keep civilian and Impostor reveal layouts structurally consistent.
-   Keep votes private during voting.
-   Enable Android `FLAG_SECURE` on sensitive screens where supported.
-   Protect app-switcher previews from displaying private game
    information.
-   Resume into a neutral screen rather than restoring a visible secret.
-   Never put secret words, roles, votes, or final guesses in
    notifications.
-   Never log sensitive gameplay data.
-   Define and implement an appropriate secure local-storage strategy.
-   Minimize the amount of sensitive information retained beyond what is
    required for recovery and results.

Privacy protections must be tested on real Android devices where
possible. Do not claim screenshot or app-switcher protection works
without verifying it.

------------------------------------------------------------------------

## 13. Localization and visual design

### Language

-   Primary interface language: Tunisian Derja in Arabic script.
-   Support proper right-to-left layout throughout the application.
-   Use human-reviewed Tunisian wording for user-facing copy.
-   Arabic text, Western digits, punctuation, and mixed-direction
    strings must render correctly.
-   Do not treat generic Modern Standard Arabic as automatically
    equivalent to natural Tunisian Derja.
-   Provisional copy must be marked for linguistic review.

### Visual identity

The approved design direction is **Tesskra (تسكرة)**.

-   Public screens use the warm paper/navy/red/mustard visual direction.
-   Private screens use the dark carbon treatment.
-   The overall experience should feel modern, polished, playful, and
    distinctive---not like an outdated ticketing interface.
-   Reuse approved design tokens, typography, assets, components, and
    screen specifications.
-   Do not invent replacement visual styles without Product Owner
    approval.

### Fonts and assets

-   Verify font source, licence, redistribution rights, and Arabic glyph
    coverage.
-   Include required attribution/licence files.
-   Do not bundle assets with unclear licensing.
-   Validate that every referenced asset exists and renders correctly.

------------------------------------------------------------------------

## 14. Settings and tutorial

MVP includes a concise tutorial/help experience explaining:

-   The objective of the game.
-   The difference between Civilian and Impostor.
-   Private role reveal and phone handoff.
-   One-word clues and verbal passing.
-   Voting and runoff rules.
-   The Impostor's final guess.

MVP also includes basic settings appropriate to the approved design. Do
not add unrelated settings or features without approval.

------------------------------------------------------------------------

## 15. Quality and acceptance criteria

A feature is not complete merely because its UI exists.

### Functional acceptance

-   A valid game can be started with every supported player count from 4
    through 12.
-   Exactly one Impostor is assigned.
-   The Impostor receives category only.
-   Every player completes the private reveal/acknowledgement flow.
-   Interrupted reveal resumes correctly.
-   Discussion and clue instructions are clear.
-   First ballot and runoff follow all specified rules.
-   Final guess accepts only canonical words or approved aliases.
-   Win/draw outcomes match the rules.
-   Replay retains the intended setup but creates a new session.
-   Cooldown works across sessions and restarts.

### Privacy acceptance

-   No role or word is visible to the next player before their reveal.
-   Private information disappears after acknowledgement.
-   Sensitive screens are protected from screenshots where supported.
-   App-switcher previews do not expose secrets.
-   Resume behaviour is neutral.
-   Sensitive data does not appear in logs or notifications.

### UX and localization acceptance

-   All screens follow the approved design handoff.
-   RTL is correct across the full flow.
-   Long names and labels do not cause overflow.
-   Text remains usable with system text scaling.
-   The interface is legible in bright and dim environments.
-   Touch targets and transitions are appropriate for one-handed
    shared-device play.

### Engineering acceptance

-   Critical game rules have automated unit tests.
-   Important screens have widget tests.
-   Complete flows have integration tests.
-   Persistence and recovery have dedicated tests.
-   Content data passes structural validation.
-   Formatting and static analysis pass.
-   Builds are verified on Android.
-   Tests are reported accurately with actual execution results.

Do not mark any criterion as passed without evidence.

------------------------------------------------------------------------

## 16. MVP success criteria

The MVP should be considered ready for controlled release only when:

-   A complete game can be played from setup to result without network
    access.
-   All core gameplay and tie scenarios behave correctly.
-   No critical privacy leak is identified in tested flows.
-   Session recovery and cooldown survive app restarts.
-   The Arabic RTL experience has been reviewed.
-   The initial published content has completed both required human
    reviews.
-   The app has been playtested with at least **three distinct groups**.
-   Critical defects are resolved or explicitly accepted by the Product
    Owner.

No numerical retention, revenue, or download targets are defined in this
PRD.

------------------------------------------------------------------------

## 17. Change control

This PRD is the approved baseline for MVP implementation.

If a requirement is unclear: 1. Identify the exact ambiguity. 2. Explain
its technical or product impact. 3. Recommend the simplest safe
interpretation. 4. Wait for Product Owner approval when it changes
gameplay, privacy, scope, or user experience materially.

Do not silently change requirements to simplify implementation.

**End of PRD v0.3**
