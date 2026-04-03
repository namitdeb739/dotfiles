---
description: Deep web research + synthesis (multi-source) with a short Sources list
agent: Chat Researcher
tools: ['read', 'search', 'web', 'vscode', 'makenotion/notion-mcp-server/*', 'io.github.upstash/context7/*', 'microsoft/markitdown/*']
model: ['GPT-5.3 Codex High']
---

Do deep web research to answer the user.

Requirements:
- Use `web/fetch` and consult multiple reputable sources when possible.
- Cross-check key claims; call out uncertainty/disagreement.
- Output: (1) direct answer (2) key findings bullets (3) recommended next steps (4) Sources (URLs).
- Ask up to 2 clarifying questions only if required to research effectively.

User input:
$input
