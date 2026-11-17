# Impostor TN — Arabic and Derja Localization

Status: **Stage 2 foundation.** No Arabic string in this project is approved yet. Every string below was drafted by the design session and must be validated by a native Tunisian Derja speaker before release.

## 1. Fonts

| Family | Use | Licence | Verified how |
|---|---|---|---|
| Noto Kufi Arabic (variable, wght 100–900) | Display, weights 800 and 900 | SIL Open Font License 1.1, © 2022 The Noto Project Authors | `OFL.txt` and `METADATA.pb` (`license: "OFL"`) in `github.com/google/fonts/ofl/notokufiarabic`, downloaded 2026-11-15 |
| IBM Plex Sans Arabic (400, 500, 600, 700) | Text | SIL Open Font License 1.1, © 2017 IBM Corp., Reserved Font Name "Plex" | `OFL.txt` and `METADATA.pb` in `github.com/google/fonts/ofl/ibmplexsansarabic`, downloaded 2026-11-15 |

What the OFL allows here: bundling the unmodified font files in a commercial app and redistributing them with their licence text. What it requires: keep the copyright and licence files with the fonts; do not sell the fonts on their own; a modified font may not use a Reserved Font Name. The files in `docs/design/assets/fonts/` are unmodified. This is a reading of the licence text, not legal advice.

### Glyph coverage test (run on the font files)

| Font | ڨ U+06A8 | ڤ U+06A4 | پ U+067E | گ U+06AF | Latin | Digits 0–9 |
|---|---|---|---|---|---|---|
| Noto Kufi Arabic | yes | yes | yes | yes | yes | yes |
| IBM Plex Sans Arabic | yes | yes | yes | yes | yes | yes |
| Lalezar (Stage 1, dropped) | **no** | yes | yes | yes | yes | yes |
| Almarai (Stage 1, dropped) | **no** | yes | yes | yes | yes | yes |

Also tested and lacking ڨ: Cairo, Alexandria, Changa, Rubik, Vazirmatn, Tajawal, Readex Pro, Rakkas. ڨ matters because player names and word packs will contain it.

Not yet tested: rendering on real Android devices, and behaviour with heavy diacritics.

## 2. RTL rules

| Topic | Rule |
|---|---|
| Direction | The whole app is RTL (`Directionality.rtl`, locale `ar`). No LTR layout exists |
| Alignment | Text aligns to the start (right). Centred text only for hero words, names on handoff and stamps |
| Reading order in rows | Right to left: leading badge or radio on the right, trailing action on the left |
| Back | Top right. Arrow points right |
| Forward / next | Chevron points left |
| Page transition | Use Flutter's default RTL page transition: a pushed screen enters from the left and leaves to the left on back |
| Progress | Fills from right to left |
| Switch | Thumb rests on the right when off, moves left when on |
| Icons | Only directional arrows flip. Check, trash, eye, lock and similar never mirror |
| Shadows | Physical, not mirrored |
| Use `start` / `end` | Never `left` / `right` in paddings, alignments and borders |
| Text caret | At the left end of typed Arabic text |

## 3. Numbers and mixed script

- Western digits (0–9) everywhere, as approved for the initial design.
- Numeric groups such as `2 / 6`, `3 / 12`, `4–12` are rendered as one LTR run (isolate), so the order never flips inside an Arabic sentence.
- Latin fragments ("TN", version numbers) are isolated LTR runs. The product name in Arabic text is written in Arabic script.
- A count followed by a noun keeps the number first as written: `60 كلمة`.
- Player names may be typed in Latin; they are displayed as typed, isolated, with the same styles. Plex and Kufi both carry Latin glyphs.
- Arabic punctuation: `؟` and `،`, not `?` and `,`.

## 4. Derja writing conventions (proposed, for review)

1. One register: Tunisian Derja in Arabic script. No Modern Standard Arabic sentences, no Latin-script Derja ("3arbi").
2. Short imperative labels; avoid long sentences on buttons.
3. Avoid second-person pronouns and gendered forms where possible. Where unavoidable, use one form for everyone and have the reviewer choose it.
4. Use `ڨ` for the hard g sound, `ڤ` for v, `پ` for p in loanwords.
5. Shadda is written where it prevents misreading (خبّي). The Product Owner uses لاعب / لاعبين, not لعّاب / لعّابة (2026-11-17). Other diacritics are omitted.
6. Loanwords are written the way people text them (تليفون, باكو, أنترنات); the reviewer confirms each spelling.
7. Each concept has one term across the whole app (glossary below).

## 5. Terminology glossary

Status values: **Review** = drafted, needs Derja validation. **Approved** = validated by the Product Owner or reviewer. Nothing is Approved yet.

| Key | Arabic | Meaning | Status | Note for reviewer |
|---|---|---|---|---|
| app.name | إمبوستور | Product name | Review | Spelling variants: إمبوستر, أمبوستور |
| role.impostor | إمبوستور | Impostor | Review | Alternative: الدخيل (more MSA) |
| role.civilian | مدني | Civilian | Review | Plural used: المدنيين |
| game.round | طرح | One game | Review | Used in "new game", "another game" |
| home.new_game | طرح جديد | New game | Review | |
| home.how_to | كيفاش تتلعب؟ | How to play | Review | |
| home.packs | باكوات الكلمات | Word packs | Review | باكو / باكوات |
| home.tagline | شكون فيكم؟ | Which of you? | Review | |
| settings.title | الإعدادات | Settings | Review | MSA word, widely understood; Derja alternative unclear |
| settings.sound | الصوت | Sound | Review | |
| settings.haptics | الاهتزاز | Vibration | Review | MSA-leaning |
| players.title | اللاعبين | Players | Review | Singular لاعب |
| players.add | زيد لاعب | Add player | Review | |
| players.name_label | اسم اللاعب | Player name | Review | |
| players.name_hint | مثلا: سلمى | e.g. Salma | Review | |
| players.name_limit | حتى 16 حرف | Up to 16 characters | Review | Limit itself must come from the PRD |
| players.empty | مازال ما فمّا حتى لاعب | No players yet | Review | |
| players.empty_hint | زيد 3 لاعبين باش تبداو | Add 3 players to start | Review | |
| error.name_duplicate | الاسم هذا موجود | Name already used | Review | |
| error.name_empty | اكتب اسم | Enter a name | Review | |
| error.min_players | لازمكم 3 لاعبين على الأقل | You need at least 3 players | Review | |
| pack.word_count | {n} كلمة | {n} words | Review | Plural rule for 3–10 (كلمات) to decide |
| pack.selected | مختار | Selected | Review | |
| pack.locked | مسكّر | Locked | Review | |
| pack.empty | ما فيه حتى كلمة | Contains no words | Review | |
| action.start | هيّا نبداو | Let's start | Review | |
| action.confirm | أكّد | Confirm | Review | |
| action.back | ارجع | Back | Review | |
| action.delete_player | فسّخ اللاعب | Delete player | Review | |
| action.rename | بدّل الاسم | Change name | Review | |
| action.retry | عاود | Retry | Review | |
| action.play_again | طرح آخر | Play again | Review | |
| handoff.pass_to | أعطي التليفون لـ {name} | Pass the phone to {name} | Review | |
| handoff.i_am | أنا {name} | I am {name} | Review | |
| privacy.only_you | ما يشوف حد غيرك | No one else should see | Review | |
| reveal.sealed | الدور مخبّي | Role is hidden | Review | |
| reveal.show | ورّيني دوري | Show me my role | Review | |
| reveal.role_label | دورك | Your role | Review | Sealed state uses دور |
| reveal.word_label | الكلمة السرّية | The secret word | Review | |
| reveal.category | الصنف: {category} | Category: {category} | Review | |
| reveal.category_only | الصنف برك | Category only | Review | برك = only |
| reveal.no_word | ما تعرفش الكلمة | You don't know the word | Review | |
| reveal.ack | فهمت، خبّي | Got it, hide | Review | |
| reveal.all_done | الكل شافوا دورهم | Everyone has seen their role | Review | |
| phase.clues | التلميحات | Clues | Review | MSA-leaning |
| phase.vote | التصويت | Voting | Review | MSA-leaning |
| vote.self | إنتي | You (marks own row) | Review | Gender-neutral usage to confirm; rule itself depends on PRD |
| vote.tie | تعادل في الأصوات. نعاودو التصويت بيناتهم. | Tie. We vote again between them. | Review | |
| result.civilians_win | المدنيين ربحوا | Civilians won | Review | |
| result.impostor_wins | الإمبوستور ربح | The Impostor won | Review | |
| result.draw | تعادل | Draw | Review | |
| dialog.quit_title | تخرج من الطرح؟ | Leave the game? | Review | |
| dialog.quit_body | الطرح الحالي يتفسّخ وما تنجّمش ترجّعو. | The current game is deleted and cannot be restored. | Review | |
| dialog.quit_confirm | أخرج | Leave | Review | |
| dialog.quit_cancel | كمّل اللعب | Keep playing | Review | |
| state.loading | لحظة… | One moment… | Review | |
| state.resumed | الطرح توقّف. كمّلوا من وين وصلتوا. | The game was paused. Continue where you stopped. | Review | |
| state.error | صار مشكل. عاود مرّة أخرى. | Something went wrong. Try again. | Review | |
| home.facts | — | — | Removed | Removed from Home by the Product Owner (2026-11-17) |

Sample content used in mockups only (not UI strings): سلمى, ياسين, عبد الرحمان بن عاشور الطرابلسي, ڨمر (names); ماكلة تونسية, بلايص, كورة, أمثال (pack names); بريك (word); ماكلة (category).

### 5.1 Proposed category labels (content metadata, not UI strings) — D-37

Simple, recognizable category labels proposed by the Product Owner (2026-11-17). They are **not** in `app_ar.arb`: they are content data in `assets/content/catalog.json` (ADR-0009). Under D-38 one label is both a pack's `title` and the `category` of every word in it, and carries its own `labelStatus`; all 13 are `in_review` until a Derja reviewer approves them. No pack, word or ID exists for them yet (Q-13), so none is published. English glosses are approximate.

| # | Label | Gloss | Set | Status |
|---|---|---|---|---|
| 0 | ماكلة | Food | Initial | Review |
| 1 | بلايص | Places | Initial | Review |
| 2 | حيوانات | Animals | Initial | Review |
| 3 | خدمة | Work, jobs | Initial | Review |
| 4 | حاجات في الدار | Things at home | Initial | Review |
| 5 | تنقّل | Getting around, transport | Initial | Review |
| 6 | رياضة | Sport | Initial | Review |
| 7 | فنّ وفرجة | Art and entertainment | Initial | Review |
| 8 | تكنولوجيا | Technology | Later candidate | Review |
| 9 | بدن الإنسان | The human body | Later candidate | Review |
| 10 | قراية | Studies, school | Later candidate | Review |
| 11 | حاجات في الشارع | Things in the street | Later candidate | Review |
| 12 | عادات وتقاليد | Customs and traditions | Later candidate | Review |

Measured 2026-11-17 (`test/core/design/widgets/proposed_category_labels_test.dart`, real fonts, RTL): all 13 pass the content text rules and fit the pack card at 360×720, 320×568 and text scale 1.5. On the role ticket, before D-39, #4 and #11 wrapped the Civilian's chip ("الصنف: …") at text scale 1.5 and made that ticket 31 px taller than the Impostor's. With the two-line category reserve of D-39, all 13 keep identical ticket sizes for both roles at all four frames. The list is kept in sync by hand with `test/support/proposed_category_labels.dart`.

## 6. Text validation requirements (for the reviewer and for QA)

- Each glossary row reviewed by a native Derja speaker; status changed to Approved or replaced.
- Check tone with 3–5 people aged 16–35 from at least two regions (Tunis and one other).
- Longest approved string for each key re-tested in its component at 360 dp width and at text scale 1.3 and 1.5.
- Player-name input: accepts Arabic and Latin letters; trims spaces; duplicate check ignores leading/trailing spaces. Whether it also normalises أ/إ/ا and ة/ه is a product decision to take from the PRD.
- Keyboard: opens the user's current keyboard; no forced Latin layout; "done" action closes it.
