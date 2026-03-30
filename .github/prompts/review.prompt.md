---
description: Review current changes for code quality issues and auto-fix them
agent: Code Reviewer
tools: ['search/codebase', 'search/usages', 'editFiles', 'runInTerminal']
---

Review all changes on the current branch compared to main, then fix any Critical or Major issues found.

1. First, run a full code review (SOLID, security, clean code)
2. Report all findings by severity
3. Automatically fix Critical and Major issues
4. Re-run review to confirm fixes are clean
5. Report what was fixed and what remains as Minor/Suggestion

$input
