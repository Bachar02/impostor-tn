---
name: prepare-release
description: Run the Impostor TN release readiness checklist and produce a go/no-go report with evidence. Use when asked to prepare, check or cut a release build.
---

# Prepare a release

This skill gathers evidence and reports. It does not publish, sign with real keys, tag or commit; those belong to the Product Owner.

1. **Quality gates** (record the real output of each):
   ```
   flutter pub get
   dart format --set-exit-if-changed lib test tool
   flutter analyze
   flutter test
   flutter build apk --release
   ```
2. **PRD acceptance (§15, §16).** Go through every criterion and mark it passed with evidence, failed, or not verified. Nothing is "passed" without evidence from this run or a recorded device test.
3. **Run the audits:** `audit-privacy`, `review-rtl`, `test-gameplay`. Include their open findings.
4. **Content.** Every published word has both human reviews recorded by the Product Owner; no unreviewed content is reachable in production. Report counts; never infer review status.
5. **Strings.** List every ARB entry still `[REVIEW]`. Any remaining one is a release blocker unless the Product Owner accepts it.
6. **Android configuration.**
   - `applicationId` confirmed by the Product Owner (permanent after publishing).
   - `versionName` / `versionCode` in `pubspec.yaml` bumped.
   - Release signing configured with the Product Owner's keystore, not the debug key.
   - Backups disabled; no unexpected permissions in the merged manifest (expect none, in particular no `INTERNET`).
   - Launcher icon correct on a device.
7. **Licences.** OFL texts for both fonts and the Lucide licence are bundled and visible in the in-app licence page.
8. **Offline.** Complete game played in airplane mode on a real device.
9. **Docs.** README, ADRs and `docs/DEVELOPMENT_CHECKLIST.md` match the code; open questions in `DECISIONS.md` are resolved or explicitly accepted.

## Output

A go/no-go report: blockers first, then each gate with its evidence, then items not verified. End with the exact Git commands (tag and push) for the Product Owner to run.
