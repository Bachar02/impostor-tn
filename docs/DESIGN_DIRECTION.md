# Impostor TN — Design Direction

Status: **Stage 2 foundation, awaiting Product Owner review.** Direction A (Tesskra) was approved by the Product Owner on 2026-11-15.

## 1. The three directions explored (Stage 1)

| | A · Tesskra (تسكرة) | B · Sahriya (سهرية) | C · Wjouh (وجوه) |
|---|---|---|---|
| Concept | Everyday printed matter: tickets, stamps, receipts | Night arcade, chunky pressable blocks | Geometric face tiles, one is "off" |
| Ground | Warm paper, navy ink | Dark indigo | Saffron and cream fields |
| Strength | Distinctive, Tunisian without flags or tourism imagery | Good in dim rooms | Shareable avatars |
| Weakness | Light screens leak more in dark rooms | Generic for the genre | Drifts childish; colour-as-role leaks privacy |

Decision: **A — Tesskra**, with private screens on a dark carbon ground. Small borrowings allowed: B's dark ground for private moments; nothing from C.

## 2. Final identity: Tesskra

**Idea.** The game is a stack of printed slips. What the whole table may see is printed on **paper**. What one player sees alone is on the **carbon** side. A role is a ticket you are handed.

**Modern, not nostalgic.** The print reference is carried by four things only: ink outlines, hard offset shadows, perforations and stamps. Everything else is contemporary: geometric kufi display type, generous spacing, flat colour, no textures on interactive surfaces, no skeuomorphic ticket-machine imagery, no serif or typewriter type.

| Element | Rule |
|---|---|
| Colour | Paper `#F3EBDD`, ink `#1B2A4A`, stamp red `#C92D22`, mustard `#E9A820`, carbon `#141C30` |
| Type | Noto Kufi Arabic 800/900 for display, IBM Plex Sans Arabic 400–700 for text |
| Shape | Rounded rectangles (radius 16–20), 2.5 px ink outline, circular perforation notches |
| Shadow | Hard offset, zero blur, public theme only |
| Stamps | Rotated −6° outlined labels for status (selected, locked, winner) |
| Icons | Lucide outline set, 24 px, 2.25 px stroke |
| Motion | Stamp (overshoot), paper slide, tear. Short and physical |

## 3. Public and private

| | Public (paper) | Private (carbon) |
|---|---|---|
| When | Home, setup, clue and discussion phases, results | Handoff, role reveal, voting, final guess, resume gate |
| Ground | Paper | Carbon |
| Primary action | Stamp red with hard shadow | Mustard, flat |
| Accents | Red, mustard, blue ink | Mustard only |
| Secret content | Never | Only on the paper-coloured ticket, only after a deliberate tap |

The change of ground is the signal: when the screen goes dark, the table looks away. The transition is a carbon sheet sliding up over the paper (520 ms); it slides back down when play becomes public again. Nothing secret is rendered while it moves.

## 4. Design principles

1. **Role-neutral at a glance.** Civilian and Impostor private screens share structure, colour and sound. Role colours exist only on public result screens.
2. **One deliberate tap to reveal, one separate tap to acknowledge.** No hold gestures. Secret content leaves the screen in the same frame as the acknowledgement.
3. **Name first.** Every handoff and private screen states whose turn it is before anything else.
4. **Never colour alone.** Status is always icon + text, plus colour.
5. **Arabic first.** Layouts are designed RTL; Tunisian letters (ڨ ڤ پ) must render in the brand fonts.
6. **One thumb, small phone.** Primary actions sit at the bottom, 60 px tall, and layouts are checked at 360 × 720.
7. **Print cues are seasoning.** If a screen starts to look like a ticketing kiosk, remove print cues until it does not.

## 5. Changes since Stage 1

| Change | Reason |
|---|---|
| Lalezar + Almarai replaced by Noto Kufi Arabic + IBM Plex Sans Arabic | Lalezar and Almarai have no glyph for **ڨ** (U+06A8), common in Tunisian spelling (ڨازوز, ڨفصة). Verified from the font files. Kufi Black is also more contemporary than Lalezar. |
| Hold-to-reveal replaced by tap-to-reveal + separate acknowledge | Product Owner decision (accessibility) |
| Player row has one trailing action | Two icon buttons truncated long Arabic names too early |
| Role colours removed from private screens | Privacy |

## 6. Open items

- PRD v0.3 has not been provided to the design session. All gameplay-dependent details (self-vote, name length limit, pack rules, resume behaviour) are marked as assumptions until checked.
- All Arabic strings, including the product name spelling, need Derja review. See `ARABIC_LOCALIZATION.md`.
