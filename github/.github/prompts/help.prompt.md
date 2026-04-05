---
name: help
description: "Summarize available prompt commands from built-in, custom, and MCP/plugin sources"
agent: agent
argument-hint: "Optional filter such as testing, security, docs, or planning"
---

# Help

Preferred custom agent: context-architect.

Generate a workspace-specific help table of prompt commands.

${input:focus:Optional focus filter (leave blank for full list)}

Requirements:

- Build a combined command inventory from:
  - Built-in Copilot slash commands available in this client.
  - Custom prompt files in `.github/prompts` and any user prompt directory if accessible.
  - MCP or plugin-provided prompt-like commands discovered from active integrations, plugin manifests, skill files, and repository docs.
- Use command names with a leading slash (for example `/help`).
- Deduplicate by normalized command name.
- Keep source attribution explicit for each command.
- Assign each command to one broad category:
  - Planning and Research
  - Editing and Implementation
  - Testing and Quality
  - Security and Governance
  - CI/CD and Repo Operations
  - Documentation and Communication
  - General Utility
- If a command fits multiple categories, pick the primary user intent and list alternates in notes.
- If a source cannot be enumerated directly, include a note and mark entries from that source as `unverified`.

Output format:

1. Coverage summary with two sections:
   - count by source
   - count by category
2. Category index table:

| Category | Command Count |
| -------- | ------------- |

3. One markdown table per category (multiple tables):

### <Category Name>

| Command | Source | Purpose | How discovered | Availability |
| ------- | ------ | ------- | -------------- | ------------ |

4. If a focus was provided, add a final focused table that includes matching commands from all categories.
5. Final notes with any limitations and quick validation steps.
