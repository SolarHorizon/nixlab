---
description: Create reference docs and templates for a codebase pattern
argument-hint: [pattern-name]
---

# Create Reference Documentation

Create reference documentation for: **$ARGUMENTS**

Follow conventions in @AGENTS.md and existing reference at @docs/reference/Components/

## Process

1. **Explore** - Find 3+ files implementing this pattern:
   - Identify common structure, imports, boilerplate
   - Note which packages/extensions are used
   - Look for variations (simple vs complex)

2. **Create** `docs/reference/$ARGUMENTS/`:
   ```
   docs/reference/$ARGUMENTS/
   ├── README.md
   └── *.template.luau
   ```

3. **README.md** must cover:
   - When to use (and when NOT to use)
   - Directory structure
   - API reference for key utilities
   - Common patterns with snippets
   - Common mistakes

4. **Templates** must:
   - Use `__PLACEHOLDER__` syntax (e.g., `__SERVICE_NAME__`)
   - Be copy-paste ready
   - Include section comments

## Placeholders

- `__COMPONENT_NAME__`, `__SERVICE_NAME__`, `__CONTROLLER_NAME__`
- `__TAG_NAME__` for CollectionService tags
- `__FEATURE_NAME__` for generic names

## Checklist

- [ ] 3+ examples explored
- [ ] Common vs optional patterns identified
- [ ] Templates production-ready
- [ ] Anti-patterns documented
