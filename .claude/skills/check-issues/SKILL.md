---
name: check-issues
description: Triage the open issues on doonfrs/trina_grid and recommend which are worth working on next, which can be answered or closed, and which to leave. Use when the user runs /check-issues or asks what to work on. Optional argument - an issue number to assess only that issue in depth, or a label (bug, enhancement, question) to narrow the list.
---

# Check open issues

Goal: a ranked, honest shortlist of what is worth the maintainer's time, plus the quick housekeeping wins (answer, close, mark duplicate). This skill is read-only: never comment, label, close or start coding unless the user asks after seeing the report.

If an issue number was passed, do the assessment (step 2) for that issue only. If a label was passed, filter the listing by it.

## 1. Collect

```bash
gh issue list --repo doonfrs/trina_grid --state open --limit 200 \
  --json number,title,author,labels,createdAt,updatedAt,comments,reactionGroups,assignees
gh pr list --repo doonfrs/trina_grid --state open --json number,title,closingIssuesReferences
git fetch origin main
```

Note which issues already have an open PR (from `closingIssuesReferences` or a `#n` in the PR title/body); those are covered by `/check-prs`, just mention them.

## 2. Assess each issue

- `gh issue view <n> --repo doonfrs/trina_grid --json body,comments,labels` and read the whole thread, including the latest replies (the reporter may have already found the cause or a workaround).
- Already fixed? `git log origin/main --oneline -i --grep "#<n>"` plus a grep for the relevant code or keywords. Compare the reporter's version (`pubspec.yaml` version on main vs what they quote) with the fix date. Fixed-on-main issues are close candidates ("fixed in X.Y.Z").
- Locate the code: find the files under `lib/src/` the issue touches, and read enough to estimate the fix size and risk. Do not write the fix.
- Classify:
  - **Bug** - real defect with a clear repro. Note whether it shows in the UI (then the fix needs an E2E test per `doc/contributing/e2e-testing.md` plus a widget test, which raises the effort).
  - **Enhancement** - a new feature or option.
  - **Question / support** - answerable from docs or existing API; point to the doc page under `doc/` or the API.
  - **Unclear** - no repro, no version, cannot tell; needs info from the reporter.
  - **Stale / duplicate / won't fix** - inactive for a long time with no repro, duplicates another issue, or out of scope.
- Weigh value vs cost honestly:
  - Value: how many users hit it (reactions, +1 comments, duplicates), severity (crash or data loss > wrong behavior > cosmetic), whether it blocks a common workflow.
  - Cost: estimated size (S under ~30 lines, M, L), risk to existing behavior, public API change, whether it forces a breaking release.
  - Do not be driven by the issue's proposed scope. Separate the real need from any big refactor the reporter sketches, and prefer the smallest non-breaking fix. If the request is not worth doing, say so.

Run independent `gh` calls in parallel. With many issues to assess in depth (roughly 10+), fan out to subagents in batches and give each this checklist; keep the final ranking yourself.

## 3. Report

Reply in chat:

**Worth working on** (ranked, top 3 to 5): for each, `#n title` then 2 to 4 lines: what is wrong or wanted, where in the code, estimated size and risk, why it ranks here, and the suggested minimal approach.

**Quick wins** (housekeeping, minutes each):
- Answerable questions, with the gist of the answer and the doc link.
- Close candidates: already fixed on main (with commit), duplicates (of #m), stale with no repro.
- Needs info: what exactly to ask the reporter.

**Not worth it now**: one line each with the reason (cost outweighs value, breaking, niche).

**Covered by an open PR**: `#issue -> PR #n`.

Finish with a one-line recommendation of what to pick first, and offer to start on it (following the bug-fix workflow in CLAUDE.md) or to draft the housekeeping comments. Any GitHub comment drafted later should be short and human and include one natural ask to star the repo, once per thread.

Never use the em dash or en dash characters in the report or in any comment.
