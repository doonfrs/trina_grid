---
name: check-prs
description: Review the open pull requests on doonfrs/trina_grid and recommend which are worth merging, which need a follow-up, and which should be closed. Use when the user runs /check-prs or asks what is going on with open PRs. Optional argument - a PR number to look at only that PR in depth.
---

# Check open PRs

Goal: give the maintainer a short, ranked verdict on every open PR so they can act in a few minutes. This skill is read-only: never merge, close, approve, comment or push unless the user asks for that action after seeing the report.

If an argument was passed (a PR number), skip the listing and do the deep review (step 2) for that PR only.

## 1. Collect

```bash
gh pr list --repo doonfrs/trina_grid --state open --limit 100 \
  --json number,title,author,isDraft,createdAt,updatedAt,additions,deletions,changedFiles,mergeable,reviewDecision,labels,closingIssuesReferences,statusCheckRollup
```

If there are no open PRs, say so in one line and stop.

## 2. Review each PR

For each PR (skip deep review of drafts unless they are the only ones; just list them):

- `gh pr view <n> --repo doonfrs/trina_grid --json body,comments,reviews,files,commits` for intent and discussion.
- `gh pr diff <n> --repo doonfrs/trina_grid` and actually read the diff. For large diffs, read the files under `lib/` first.
- `gh pr checks <n> --repo doonfrs/trina_grid` for CI (`dart analyze` + `flutter test`).
- Linked issue: read it (`gh issue view`) to confirm the PR solves the reported problem, not a nearby one.
- Check whether main already covers it: `git fetch origin main` then `git log origin/main --oneline -i --grep "<keyword or #issue>"` and grep the relevant code on main. A PR made obsolete by a later commit is a close candidate.
- Judge the change itself:
  - Correctness: does the logic hold for edge cases (empty rows, frozen columns, pagination, RTL, dual grid, row groups)?
  - Public API: does it add, rename or remove anything exported from `lib/trina_grid.dart`? Breaking changes need a strong reason.
  - Scope: is it focused, or does it bundle unrelated refactors or formatting churn?
  - Tests: are there tests in `test/`? For a UI bug, is the fix the kind that needs an E2E check per `doc/contributing/e2e-testing.md`?
  - Docs/CHANGELOG: does a changed or new API need a `/doc` update?
  - Dependency bumps (`pubspec.yaml`): check the new constraint range is sane and does not drop versions users still need.
- Cost/benefit: what do users actually gain, and what is the maintenance or breakage cost? Do not be swayed by the PR existing; a small non-breaking alternative may be better than the proposed scope.

Run independent `gh` calls in parallel. With many PRs (roughly 6+), fan the deep reviews out to subagents, one per PR, and give each the checklist above.

## 3. Verdicts

Pick one per PR:

- **Merge** - sound, CI green, nothing missing.
- **Merge + follow-up** - sound but missing polish (tests, CHANGELOG, a nit). Preferred over blocking a contributor: merge, thank them, and do the polish in our own follow-up PR. Say which polish items actually earn their place.
- **Needs changes** - a real correctness or design problem the contributor should fix. Name it concretely (file:line, failing scenario).
- **Close** - obsolete, duplicate, already fixed on main, or not worth the cost. Give the reason the comment would state.
- **Wait** - draft, or waiting on the author's reply.

## 4. Report

Reply in chat, most actionable first:

```
| PR | Title | Author | Size | CI | Verdict |
|----|-------|--------|------|----|---------|
```

Then, per PR, 2 to 5 lines: what it does, the key finding, and the exact next action (for example "merge, then follow-up PR adding a widget test for X").

End with a **Suggested order** list (what to do first and why) and offer to carry out the actions. When the user later asks to post a GitHub comment (thanks, change request, close reason), keep it short and human and include one natural ask to star the repo, once per thread.

Never use the em dash or en dash characters in the report or in any comment.
