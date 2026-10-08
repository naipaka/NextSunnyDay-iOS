---
name: next-task
description: Pick up the next task of the NextSunnyDay revival roadmap (GitHub issue #89) and work on it. Use when the owner says "next task", "次のタスク", "次やって", "続きやって", "ロードマップ進めて" or similar without naming an issue.
---

# Next roadmap task

The revival roadmap is GitHub issue **#89** in `naipaka/NextSunnyDay-iOS`. Each task is a sub-issue of #89, or of a group issue under #89 (#101 "New features for 2.0"). One task = one chat.

## 1. Find the task

1. List the sub-issues with their state:
   ```sh
   gh api repos/naipaka/NextSunnyDay-iOS/issues/89/sub_issues --jq '.[] | "\(.number)\t\(.state)\t\(.title)"'
   ```
2. A sub-issue that has sub-issues of its own is a **group**, not a task (check with `gh api repos/naipaka/NextSunnyDay-iOS/issues/<n>/sub_issues`). Treat its open sub-issues as the candidates in its place, and its own `Depends on` line as a dependency of each of them. When all of a group's sub-issues are closed, tick it in #89 and close it.
3. If every task is closed, say the roadmap is finished and offer to close #89. Stop.
4. Read the body of each open task in ascending number order (`gh issue view <n>`). Its first lines say `Depends on #X` (and sometimes "Can start any time after #X"). Pick the **lowest-numbered open issue whose dependencies are all closed**.
   - If an open issue already has ticked checkboxes or progress comments, it is in progress — prefer resuming it over starting a new one.
   - If the owner named an issue, use that one instead, but warn if its dependencies are still open.

## 2. Brief the owner (in Japanese) and confirm

Before changing anything, tell the owner:

- Which issue was picked and why (one line on the dependency check).
- The goal and the scope, summarized in a few bullets.
- Any **Owner prerequisites** (manual steps such as Apple Developer portal settings) — ask whether they are done.
- Every **Owner decision** listed in the issue, each with a recommendation. Use AskUserQuestion for these.

Wait for the answers. Record the decisions as one comment on the issue (in English), following [Writing on GitHub](#writing-on-github).

## 3. Do the work

- Read `CLAUDE.md` and the docs the issue links to first.
- Follow the issue's Scope; respect Out of scope (mention, don't do).
- Commit to `main` in small, focused steps and push directly (no PRs). Keep CI green: check `gh run list` after pushing and fix failures.
- Tick checkboxes in the issue body as items are completed (`gh issue edit <n> --body-file …`), so a later chat can resume.
- Issue comments, commit messages, docs and code comments are in English; talk to the owner in Japanese.
- Everything written to GitHub, commits and docs follows [Writing on GitHub](#writing-on-github).

## 4. Finish

When every "Done when" item is met:

1. Update `CLAUDE.md` and `docs/` so the next chat starts with accurate context.
2. Put anything deferred into the body of the issue that will do it (a Scope checkbox with enough detail to act on); a later chat reads only the body of its own task, not comments on other issues. Mention it in the summary too.
3. Post a short English summary comment on the issue (what changed, commits, anything deferred) and close it. Don't post kick-off or play-by-play progress comments before this.
4. Tick the task's checkbox in #89's body (tasks of a group are listed there too).
5. Tell the owner in Japanese what was done, and that the next task can be started in a new chat with `/next-task`.

If the task cannot be finished in this chat, leave a progress comment on the issue (done / remaining / blockers) instead of closing it.

## Writing on GitHub

The repository is public and everything is posted from the owner's account. Write issue comments, issue bodies, commit messages and docs as if the owner wrote them:

- State what was decided and why, in the first person or with no subject. Don't write "owner decision", "the owner chose / felt / added", or mention Claude or the chat.
- Don't record the conversation: options shown in chat, drafts the owner turned down, their reactions, revisions made during the discussion, "under review". Record only the final decision; mention a rejected alternative only when it explains the decision, and then on technical grounds.
- Only refer to things a reader can see in the repository or on GitHub. No chat mockups, prototypes outside the repo, artifact links, or option labels such as "option A"; describe the thing itself.
- Don't edit a posted comment, because GitHub keeps the earlier text in its edit history. Delete it and post a new one.
