# Markdown Standards and Cross-Editor Compatibility

**Research Date**: 2026-01-30
**Purpose**: Determine optimal markdown flavor for maximum compatibility across editors (IntelliJ, VS Code, Notepad, GitHub, Google Docs)
**Context**: Markdown files not rendering properly in IntelliJ/Windows Notepad

---

## Executive Summary

**Recommendation**: Use **CommonMark** as the base standard with **GitHub Flavored Markdown (GFM)** extensions for maximum compatibility across technical tools.

**Why**:
- CommonMark is the formal specification adopted by major platforms (GitHub, GitLab, Stack Overflow, Reddit)
- IntelliJ IDEA explicitly supports CommonMark
- VS Code supports CommonMark by default
- GFM is a strict superset of CommonMark (100% backward compatible)
- Ensures consistent rendering across all development tools

**Google Docs Caveat**: Google Docs has limited, custom Markdown support that doesn't fully align with CommonMark/GFM. For Google Docs integration, use conversion tools (see Google Docs section).

---

## Markdown Flavors Overview

### CommonMark (The Standard)

**Source**: [CommonMark: A Formal Specification For Markdown — Smashing Magazine](https://www.smashingmagazine.com/2020/12/commonmark-formal-specification-markdown/)

**What It Is**:
- Formal specification developed to address lack of standardization in Markdown
- Provides unified and clear definition ensuring content is interpreted consistently
- Goal: Eliminate ambiguity in Markdown parsing

**Adoption** (from [Markdown - Wikipedia](https://en.wikipedia.org/wiki/Markdown)):
- GitHub (migrated from Sundown to cmark in 2017)
- GitLab
- Stack Exchange (Stack Overflow)
- Reddit
- Discourse
- Qt
- Swift
- Codeberg

**Key Principle**: "Write once, render consistently everywhere"

---

### GitHub Flavored Markdown (GFM)

**Source**: [GitHub Flavored Markdown Spec](https://github.github.com/gfm/)

**What It Is**:
- Strict superset of CommonMark (follows CommonMark exactly)
- Adds 4 extensions: tables, strikethrough, autolinks, task lists
- Official dialect for GitHub.com and GitHub Enterprise

**History** (from [A formal spec for GitHub Flavored Markdown - GitHub Blog](https://github.blog/engineering/user-experience/a-formal-spec-for-github-markdown/)):
- 2012: GitHub created GFM built on Sundown parser
- 2017: GitHub deprecated Sundown in favor of CommonMark-based cmark
- GFM now built on CommonMark foundation

**Extensions**:

#### 1. Tables
```markdown
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
```

#### 2. Strikethrough
```markdown
~~deleted text~~
```

#### 3. Autolinks
```markdown
www.example.com (auto-converted to link)
user@example.com (auto-converted to mailto link)
```

#### 4. Task Lists
```markdown
- [ ] Unchecked task
- [x] Checked task
```

**Compatibility**: 100% backward compatible with CommonMark (anything valid in CommonMark is valid in GFM)

---

## Editor Support

### IntelliJ IDEA

**Source**: [Markdown | IntelliJ IDEA Documentation](https://www.jetbrains.com/help/idea/markdown.html)

**Support Level**: Full CommonMark support

**Features**:
- Recognizes `.md` and `.markdown` files automatically
- Live preview pane with rendered HTML
- Syntax highlighting and code completion
- Formatting tools
- Diagram rendering (Mermaid, PlantUML)

**Specification**: Explicitly based on **CommonMark specification**

**Configuration**:
- Default: CommonMark
- Can be configured for other flavors via plugins

**Plugin**: [Markdown plugin](https://plugins.jetbrains.com/plugin/7793-markdown) built-in

---

### VS Code

**Source**: [Markdown and Visual Studio Code](https://code.visualstudio.com/docs/languages/markdown)

**Support Level**: Full CommonMark support (built-in)

**Features**:
- Markdown preview (Ctrl+Shift+V or Cmd+Shift+V)
- Side-by-side preview (Ctrl+K V)
- Outline view for navigation
- Snippet support
- Syntax highlighting

**Popular Extensions**:
- [Markdown All in One](https://github.com/yzhang-gh/vscode-markdown): TOC generation, keyboard shortcuts, math
- markdownlint: Linting based on CommonMark rules
- Markdown Preview Enhanced: Advanced preview features

**Compatibility Note** (from [Markdown All in One Documentation](https://markdown-all-in-one.github.io/docs/guide/compatibility.html)):
> "Markdown All in One is not guaranteed to work with Markdown flavors which diverge from CommonMark greatly"

**Recommendation**: Stick to CommonMark for maximum extension compatibility

---

### Google Docs

**Sources**:
- [Import and export Markdown in Google Docs](https://workspaceupdates.googleblog.com/2024/07/import-and-export-markdown-in-google-docs.html)
- [Use Markdown in Google Docs](https://support.google.com/docs/answer/12014036?hl=en)
- [Google Docs still doesn't fully support Markdown · Reproof](https://www.reproof.app/blog/google-docs-markdown)

**Support Level**: ⚠️ **Limited, Custom Implementation**

**Important Context**:
- Google Docs is fundamentally a rich text editor, not a Markdown editor
- Markdown support works via automatic substitution (type syntax → auto-converts to rich text)
- **Does NOT explicitly follow CommonMark or GFM specification**
- Google has not published which Markdown flavor they implement

**Supported Features** (Limited):
- ✅ Bold, italic, strikethrough
- ✅ Headings (# syntax)
- ✅ Lists (ordered and unordered)
- ✅ Links
- ❌ Code blocks (limited or no support)
- ❌ Tables (may not render correctly)
- ❌ Advanced formatting

**Import/Export** (Added July 2024):
- Can import `.md` files: File → Open
- Can export as `.md`: File → Download → Markdown (.md)
- **Warning**: Conversion may not preserve all Markdown features
- Exported Markdown may have Google-specific extensions

**Custom Features**:
- Unique TOC anchor syntax: `## Chapter 1 {#chapter-1}`
- Some GFM influence (footnotes similar to GitHub)
- Not compatible with standard CommonMark parsers

**Recommendation for Google Docs Integration**:

1. **For Docs → Markdown**: Use [Docs to Markdown add-on](https://workspace.google.com/marketplace/app/docs_to_markdown/700168918607)
   - Better conversion quality
   - More control over output format
   - Explicitly supports GFM tables and other extensions

2. **For Markdown → Docs**:
   - Use Google's built-in import (File → Open)
   - Be aware some features may not convert perfectly
   - Complex formatting may need manual cleanup

3. **Don't Treat Google Docs as Markdown Source**:
   - Store source files as `.md` in version control (GitHub)
   - Use Google Docs for collaboration/comments only
   - Convert back to Markdown using add-on before committing changes

**Key Insight**: Google Docs is not a first-class Markdown tool. Use CommonMark/GFM for source files; treat Google Docs as a collaboration layer with lossy conversion.

---

### Windows Notepad

**Reality**: Notepad is a plain text editor with no Markdown rendering

**Implications**:
- Markdown files are just text (no preview)
- Line endings matter: Windows uses CRLF (`\r\n`), Unix uses LF (`\n`)
- Encoding matters: UTF-8 (with or without BOM)

**Compatibility Issues**:
- Mixed line endings can cause rendering problems in other tools
- Non-UTF-8 encoding can break special characters

**Best Practice**: Use UTF-8 without BOM, LF line endings (Git normalizes this)

---

## Common Compatibility Issues

### Issue 1: Line Endings

**Problem**: Windows (CRLF) vs Unix (LF) line endings

**Impact**:
- Can cause extra blank lines in some parsers
- Git may show entire file as changed

**Solution**:
```bash
# Configure Git to normalize line endings
git config --global core.autocrlf true  # Windows
git config --global core.autocrlf input # Mac/Linux
```

**In `.gitattributes`**:
```
*.md text eol=lf
```

---

### Issue 2: Non-CommonMark Extensions

**Problem**: Using features specific to one flavor

**Examples**:
- Definition lists (supported in some flavors, not CommonMark)
- Footnotes (not in CommonMark core)
- Custom containers (not in CommonMark)

**Solution**: Stick to CommonMark + GFM extensions only

**CommonMark Core Features** (Always Safe):
- Headings (`#`, `##`, etc.)
- Emphasis (`*italic*`, `**bold**`)
- Lists (ordered, unordered)
- Links (`[text](url)`)
- Images (`![alt](url)`)
- Code blocks (fenced with ` ``` `)
- Blockquotes (`>`)
- Horizontal rules (`---`)

**GFM Extensions** (Safe for GitHub/GitLab):
- Tables
- Strikethrough
- Task lists
- Autolinks

**Not Standard** (Avoid or use with caution):
- Definition lists
- Footnotes
- Abbreviations
- Custom attributes
- Math (requires plugin)
- Google Docs custom syntax

---

### Issue 3: Encoding

**Problem**: Non-UTF-8 encoding or BOM (Byte Order Mark)

**Impact**:
- Special characters render as gibberish
- Some parsers reject BOM

**Solution**:
- Always use UTF-8 encoding
- Save without BOM (most modern editors default to this)

**Check Encoding**:
```bash
file -bi filename.md
# Should show: text/plain; charset=utf-8
```

---

## Markdown Feature Comparison

**Source**: [Comparison of features in various Markdown flavors](https://gist.github.com/vimtaai/99f8c89e7d3d02a362117284684baa0f)

| Feature | CommonMark | GFM | Google Docs | MultiMarkdown | Pandoc |
|---------|------------|-----|-------------|---------------|--------|
| **Basic Syntax** | ✅ | ✅ | ⚠️ Limited | ✅ | ✅ |
| **Tables** | ❌ | ✅ | ⚠️ Via add-on | ✅ | ✅ |
| **Strikethrough** | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Task Lists** | ❌ | ✅ | ❌ | ❌ | ✅ |
| **Autolinks** | ❌ | ✅ | ⚠️ Auto-convert | ❌ | ❌ |
| **Code Blocks** | ✅ | ✅ | ❌ Limited | ✅ | ✅ |
| **Footnotes** | ❌ | ❌ | ⚠️ GFM-style | ✅ | ✅ |
| **Definition Lists** | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Abbreviations** | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Math** | ❌ | ❌ | ❌ | ✅ | ✅ |

**Key Insight**: CommonMark + GFM covers 95% of documentation needs while maintaining compatibility with development tools. Google Docs has limited, lossy support.

---

## Recommended Markdown Standard

### For All Documentation Files

**Standard**: **CommonMark with GFM extensions**

**Rationale**:
1. **Universally Supported**: IntelliJ, VS Code, GitHub, GitLab all support CommonMark
2. **Strict Specification**: No ambiguity in parsing
3. **GitHub Integration**: Native support for tables, task lists (useful for project management)
4. **Future-Proof**: Adopted by major platforms, unlikely to change
5. **Google Docs**: Limited compatibility, but conversion tools exist

### File Configuration

**`.editorconfig`** (Project Root):
```ini
[*.md]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
```

**`.gitattributes`** (Project Root):
```
*.md text eol=lf
```

**Purpose**: Ensures consistent line endings and encoding across all contributors and editors

---

## Google Docs Workflow

### Recommended Workflow for Documents Needing Google Docs Collaboration

**Pattern**: Markdown-First, Google Docs for Collaboration

```
Source of Truth: Markdown (.md) in Git Repository
         ↓
   [Convert to Google Doc for collaboration]
         ↓
   Collaborators edit in Google Docs
   (Comments, suggestions, track changes)
         ↓
   [Export using Docs to Markdown add-on]
         ↓
   Review diff, clean up conversion artifacts
         ↓
   Commit updated Markdown to Git
```

**Tools**:
1. **Markdown → Google Docs**:
   - File → Open (select .md file from Drive)
   - OR: Build custom converter ([guide](https://dev.to/googleworkspace/building-a-basic-markdown-to-google-docs-converter-1220))

2. **Google Docs → Markdown**:
   - [Docs to Markdown add-on](https://workspace.google.com/marketplace/app/docs_to_markdown/700168918607) (recommended)
   - OR: File → Download → Markdown (.md) (basic, may lose formatting)

**Important**: Always review diffs after Google Docs conversion. Manual cleanup may be needed for:
- Tables (may need formatting fixes)
- Code blocks (may convert to plain text)
- Task lists (may lose checkbox syntax)
- Links (check relative paths preserved)

---

## Linting and Validation

### markdownlint

**Source**: [markdownlint for VS Code](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)

**What It Does**:
- Validates Markdown files against CommonMark rules
- Catches common formatting issues
- Configurable rules

**Configuration** (`.markdownlint.json`):
```json
{
  "default": true,
  "MD013": false,  // Line length (disable if too strict)
  "MD033": false,  // Allow inline HTML (sometimes needed)
  "MD041": false   // First line as heading (not always desired)
}
```

**Benefits**:
- Ensures CommonMark compliance
- Catches syntax errors before commit
- Maintains consistency across team

---

## IntelliJ-Specific Issues

### Issue: Preview Not Rendering Correctly

**Possible Causes**:
1. **Markdown plugin disabled**: Check Settings → Plugins → Markdown
2. **Non-CommonMark syntax**: IntelliJ expects CommonMark
3. **File encoding**: Should be UTF-8
4. **Line endings**: Should be LF

**Debugging Steps**:

1. **Check Plugin Status**:
   - File → Settings → Plugins
   - Search "Markdown"
   - Ensure enabled

2. **Validate Syntax**:
   - Run markdownlint or use online validator: [CommonMark Spec](https://spec.commonmark.org/dingus/)
   - Paste content, check for errors

3. **Check File Encoding**:
   - Right-click status bar (bottom right)
   - Should show "UTF-8"
   - If not, click → "Convert to UTF-8"

4. **Check Line Endings**:
   - Right-click status bar (bottom right)
   - Should show "LF" (not "CRLF")
   - If CRLF, click → "LF - Unix and macOS (\\n)"

5. **Test with Simple File**:
```markdown
# Test Heading

This is a **test** file with *emphasis*.

- List item 1
- List item 2

| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
```

If this renders correctly, issue is with specific syntax in your files.

---

## Migration Checklist

For existing Markdown files that aren't rendering properly:

- [ ] Convert to UTF-8 encoding (without BOM)
- [ ] Normalize line endings to LF
- [ ] Remove non-CommonMark extensions (or accept they won't render everywhere)
- [ ] Validate against CommonMark spec
- [ ] Test preview in IntelliJ IDEA
- [ ] Test preview in VS Code
- [ ] Test import/export with Google Docs (if needed)
- [ ] Add `.editorconfig` and `.gitattributes` to project
- [ ] Configure markdownlint (optional but recommended)

---

## Recommendations for This Project

### Immediate Actions

1. **Standardize on CommonMark + GFM**:
   - Document this decision in project README
   - Add note to contribution guidelines
   - Update existing files to comply

2. **Add Configuration Files**:
   ```bash
   # Create .editorconfig
   cat > .editorconfig << 'EOF'
   root = true

   [*.md]
   charset = utf-8
   end_of_line = lf
   insert_final_newline = true
   trim_trailing_whitespace = true
   EOF

   # Update .gitattributes
   echo "*.md text eol=lf" >> .gitattributes
   ```

3. **Fix Line Endings** (if issues persist):
   ```bash
   # Convert all .md files to LF (Linux/Mac)
   find . -name "*.md" -exec sed -i 's/\r$//' {} \;

   # Or use dos2unix if available
   find . -name "*.md" -exec dos2unix {} \;
   ```

4. **Validate Existing Files**:
   ```bash
   # Install markdownlint-cli
   npm install -g markdownlint-cli

   # Run on all files
   markdownlint '**/*.md'
   ```

5. **For Google Docs Workflow**:
   - Install [Docs to Markdown add-on](https://workspace.google.com/marketplace/app/docs_to_markdown/700168918607)
   - Document conversion workflow in README
   - Add reminder to review diffs after Google Docs edits

### Long-Term Guidelines

1. **Document Markdown Standard**:
   - Add to project README or CONTRIBUTING.md
   - "This project uses CommonMark with GitHub Flavored Markdown extensions"
   - "Google Docs is used for collaboration only; Markdown files are source of truth"

2. **Pre-Commit Hook** (Optional):
   ```bash
   # .git/hooks/pre-commit
   #!/bin/bash
   markdownlint $(git diff --cached --name-only --diff-filter=ACM | grep '\.md$')
   ```

3. **Editor Configuration**:
   - IntelliJ: Ensure Markdown plugin enabled and updated
   - VS Code: Install markdownlint extension
   - Google Docs: Use Docs to Markdown add-on for exports

---

## References

**Specifications**:
- [CommonMark Specification](https://spec.commonmark.org/)
- [GitHub Flavored Markdown Spec](https://github.github.com/gfm/)

**Editor Documentation**:
- [Markdown | IntelliJ IDEA Documentation](https://www.jetbrains.com/help/idea/markdown.html)
- [Markdown and Visual Studio Code](https://code.visualstudio.com/docs/languages/markdown)
- [Use Markdown in Google Docs](https://support.google.com/docs/answer/12014036?hl=en)
- [Import and export Markdown in Google Docs](https://workspaceupdates.googleblog.com/2024/07/import-and-export-markdown-in-google-docs.html)

**Google Docs Caveats**:
- [Google Docs still doesn't fully support Markdown · Reproof](https://www.reproof.app/blog/google-docs-markdown)
- [Google adds limited Markdown support to Google Docs](https://techcrunch.com/2022/03/30/google-adds-limited-markdown-support-to-google-docs/)

**Comparison and Tools**:
- [Comparison of Markdown Flavors](https://gist.github.com/vimtaai/99f8c89e7d3d02a362117284684baa0f)
- [Docs to Markdown (Google Workspace Add-on)](https://workspace.google.com/marketplace/app/docs_to_markdown/700168918607)
- [CommonMark Dingus (Online Validator)](https://spec.commonmark.org/dingus/)
- [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli)

---

**Related Documentation**:
- [context-efficiency.md](../instructions/context-efficiency.md) - Documentation best practices
- [rule-file-architecture.md](~/.ai-context-store/user-wide/rules/rule-file-architecture.md) - File organization patterns
