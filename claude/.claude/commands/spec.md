---
description: Interview me about a feature, then write a complete spec to SPEC.md
disable-model-invocation: true
---

Interview me in detail about what I want to build, using the AskUserQuestion
tool. Ask about technical implementation, UI/UX where relevant, edge cases,
failure modes, and tradeoffs.

Do not ask obvious questions or things you could answer by reading the
codebase. Dig into the hard parts I might not have considered — the decisions
that are expensive to reverse, the cases that break the happy path, the places
where two reasonable choices lead to very different code.

Read the relevant code first so your questions are grounded in what already
exists, not in generalities.

Keep interviewing until the hard parts are actually settled. When they are,
write a complete spec to SPEC.md covering:

- the problem and what "done" looks like
- the approach, and which alternatives were rejected and why
- edge cases and failure modes, with the decided behaviour for each
- files expected to change
- how to verify it works

Then stop. Do not start implementing.

$ARGUMENTS
