---
name: Markdown Standards
description: Writing style, heading structure, link conventions for documentation
applyTo: '**/*.md'
---

# Markdown Conventions

## Structure
- Start with a single H1 (`#`) as the document title
- Use heading levels sequentially — never skip from H2 to H4
- Keep heading depth to H3 maximum for readability
- Use blank lines before and after headings, code blocks, and lists

## Writing Style
- Use present tense and active voice
- Write in second person for instructions ("Run the command", not "The user should run")
- Keep sentences concise — one idea per sentence
- Use bullet lists for unordered items, numbered lists for sequential steps
- Bold key terms on first use; use inline code for commands, filenames, and variable names

## Links
- Use descriptive link text, never "click here" or bare URLs
- Prefer relative links for internal references within the same repo
- Use reference-style links for URLs used multiple times

## Code Blocks
- Always specify the language for syntax highlighting
- Keep examples minimal — show the essential pattern, not a full application
- Include expected output when it aids understanding

## Tables
- Use tables for structured comparisons, not for layout
- Align columns for readability in source
- Keep tables under 5 columns — use lists or subsections for more complex data
