# Google Docs Integration Setup

## Overview
This setup enables Claude Code to work with Google Docs through rclone and pandoc, allowing document download, conversion to markdown for editing, and seamless workflow integration.

## Tools

### rclone v1.72.1
- **Purpose**: Sync and access Google Drive files via CLI
- **Installation**: `curl https://rclone.org/install.sh | sudo bash`
- **Config Location**: `~/.config/rclone/rclone.conf`
- **Remote Name**: `gdrive:`

**Configuration Steps:**
1. Run `rclone config`
2. Create new remote named `gdrive`
3. Select Google Drive as storage type
4. Use default OAuth client (no GCP project needed)
5. Authenticate via browser (headless: use `n` for auto-config, paste URL manually)

### pandoc v3.1.3
- **Purpose**: Convert documents between formats (docx ↔ markdown)
- **Installation**: `sudo apt install -y pandoc`
- **Usage**: Preserves document structure, formatting, and hierarchy

## Workflow

**Step-by-step process:**

1. **Download document from Drive:**
   ```bash
   rclone copyto "gdrive:Document Name.docx" /tmp/document.docx
   ```

2. **Convert to markdown for editing:**
   ```bash
   pandoc /tmp/document.docx -o /tmp/document.md
   ```

3. **Claude reads/edits the markdown** using Read and Edit tools

4. **User copies updated markdown and pastes into Google Docs directly**
   - This preserves all comments in the original document
   - User has full control over what changes to apply

**For additional rclone and pandoc commands, see `one-liners.md`.**

## Important Notes

### Comments and Formatting
- **Comments**: Preserved in .docx format, lost in markdown conversion
- **Formatting**: Tables, images, bullets preserved in docx ↔ markdown
- **Google Docs**: Appear with .docx extension but are native Google Docs

### File Types
- Google Docs export as Word format (.docx) automatically
- Use `--drive-export-formats` flag for other formats:
  - `txt` - Plain text (loses formatting)
  - `pdf` - PDF format
  - `html` - HTML format

### Recommended Workflow
1. Download as .docx to preserve comments
2. Convert to markdown for editing
3. Work on markdown (easy for AI to edit)
4. User copies updated markdown back to Google Docs
5. Comments remain intact in original document

## Troubleshooting

**Common issues:**
- **rclone "directory not found"**: Ensure remote name includes colon (`gdrive:`)
- **Authentication failed**: Re-run `rclone config` and re-authenticate
- **Rate limiting**: Consider creating custom OAuth client ID in GCP
- **Lost formatting**: Use docx format for round-trip preservation
- **Missing images**: Images in docx are embedded, check output format
- **Table issues**: Complex tables may need manual adjustment

**For troubleshooting commands, see `one-liners.md`.**

## Security Notes
- OAuth tokens stored in `~/.config/rclone/rclone.conf`
- Tokens are encrypted and refresh automatically
- Do NOT share rclone.conf file (contains authentication credentials)
- Using default OAuth client is safe but has shared rate limits
