#!/bin/bash
#
# Claude Code Monitoring Setup Script
#
# This script installs and configures the Claude Code usage monitoring system.
# It can be run on a new server or used to update an existing installation.
#
# Usage:
#   bash install-monitoring.sh [--update]
#
# Options:
#   --update    Update existing installation (preserves reports and logs)
#
# Prerequisites:
#   - Python 3.6+ installed
#   - Git repository cloned to ~/.ai
#   - Cron service running
#
# What it installs:
#   - claude-usage-monitor.py in ~/.ai/tools/
#   - run-usage-monitor.sh wrapper in ~/.ai/tools/
#   - Daily cron job (9am) for automated monitoring
#   - Directory structure: ~/.ai/reports/, ~/.ai/logs/
#   - .gitignore entries for generated content

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AI_DIR="$HOME/.ai"
TOOLS_DIR="$AI_DIR/tools"
REPORTS_DIR="$AI_DIR/reports"
LOGS_DIR="$AI_DIR/logs"
UPDATE_MODE=false

# Parse arguments
if [[ "${1:-}" == "--update" ]]; then
    UPDATE_MODE=true
fi

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check Python version
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 is not installed. Please install Python 3.6 or later."
        exit 1
    fi

    local python_version=$(python3 --version | awk '{print $2}')
    log_info "Found Python $python_version"

    # Check if ~/.ai exists
    if [ ! -d "$AI_DIR" ]; then
        log_error "Directory $AI_DIR does not exist."
        log_error "Please clone the ai-tooling repository first:"
        log_error "  git clone https://github.com/ericrshields/ai-tooling.git ~/.ai"
        exit 1
    fi

    # Check if git repo
    if [ ! -d "$AI_DIR/.git" ]; then
        log_warn "Directory $AI_DIR is not a git repository."
        log_warn "Monitoring tools may not be up to date."
    fi

    # Check cron service
    if ! command -v crontab &> /dev/null; then
        log_error "Cron is not available. Please install cron service."
        exit 1
    fi

    log_info "Prerequisites check passed"
}

create_directories() {
    log_info "Creating directory structure..."

    mkdir -p "$TOOLS_DIR"
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$LOGS_DIR"

    log_info "Directories created: tools/, reports/, logs/"
}

install_monitoring_script() {
    log_info "Installing monitoring scripts..."

    local monitor_script="$TOOLS_DIR/claude-usage-monitor.py"
    local wrapper_script="$TOOLS_DIR/run-usage-monitor.sh"

    if [ ! -f "$monitor_script" ]; then
        log_error "Monitoring script not found at $monitor_script"
        log_error "Please ensure the repository is up to date:"
        log_error "  cd ~/.ai && git pull"
        exit 1
    fi

    if [ ! -f "$wrapper_script" ]; then
        log_error "Wrapper script not found at $wrapper_script"
        log_error "Please ensure the repository is up to date:"
        log_error "  cd ~/.ai && git pull"
        exit 1
    fi

    # Make scripts executable
    chmod +x "$monitor_script"
    chmod +x "$wrapper_script"

    log_info "Scripts installed and made executable"
}

setup_cron_job() {
    log_info "Setting up cron job..."

    local cron_entry="0 9 * * * $TOOLS_DIR/run-usage-monitor.sh >> $LOGS_DIR/monitor-cron.log 2>&1"
    local cron_comment="# Claude Code usage monitoring - runs daily at 9am with 7-day rolling analysis"

    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "run-usage-monitor.sh"; then
        if [ "$UPDATE_MODE" = true ]; then
            log_info "Cron job already exists, updating..."
            # Remove old entry and add new one, preserving other cron jobs
            local temp_cron=$(mktemp)
            crontab -l 2>/dev/null | grep -v "run-usage-monitor.sh" | grep -v "Claude Code usage monitoring" > "$temp_cron" || true
            echo "" >> "$temp_cron"
            echo "$cron_comment" >> "$temp_cron"
            echo "$cron_entry" >> "$temp_cron"
            crontab "$temp_cron"
            rm "$temp_cron"
        else
            log_warn "Cron job already exists. Skipping..."
            log_warn "Use --update flag to update existing installation."
            return
        fi
    else
        # Add new cron job
        local temp_cron=$(mktemp)
        crontab -l 2>/dev/null > "$temp_cron" || true
        echo "" >> "$temp_cron"
        echo "$cron_comment" >> "$temp_cron"
        echo "$cron_entry" >> "$temp_cron"
        crontab "$temp_cron"
        rm "$temp_cron"
    fi

    log_info "Cron job configured: Daily at 9am"
}

update_gitignore() {
    log_info "Updating .gitignore..."

    local gitignore="$AI_DIR/.gitignore"

    if [ ! -f "$gitignore" ]; then
        log_warn ".gitignore not found, creating..."
        cat > "$gitignore" << 'EOF'
# Claude Code local settings
.claude/

# Sensitive configuration files
*.env
*.secrets
*credentials*

# Editor settings
.idea

# Generated monitoring reports and logs
reports/
logs/
EOF
    else
        # Check if entries already exist
        if ! grep -q "reports/" "$gitignore" 2>/dev/null; then
            echo "" >> "$gitignore"
            echo "# Generated monitoring reports and logs" >> "$gitignore"
            echo "reports/" >> "$gitignore"
            echo "logs/" >> "$gitignore"
        fi
    fi

    log_info ".gitignore updated"
}

verify_installation() {
    log_info "Verifying installation..."

    # Test monitoring script
    if "$TOOLS_DIR/claude-usage-monitor.py" --days 1 > /dev/null 2>&1; then
        log_info "Monitoring script test: PASSED"
    else
        log_warn "Monitoring script test: FAILED (may not have session data yet)"
    fi

    # Check cron job
    if crontab -l 2>/dev/null | grep -q "run-usage-monitor.sh"; then
        log_info "Cron job verification: PASSED"
    else
        log_error "Cron job verification: FAILED"
        return 1
    fi

    # Check directories
    for dir in "$TOOLS_DIR" "$REPORTS_DIR" "$LOGS_DIR"; do
        if [ -d "$dir" ]; then
            log_info "Directory $dir: EXISTS"
        else
            log_error "Directory $dir: MISSING"
            return 1
        fi
    done

    log_info "Installation verification complete"
}

show_next_steps() {
    echo ""
    log_info "Installation complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Test monitoring manually:"
    echo "     ~/.ai/tools/run-usage-monitor.sh 7"
    echo ""
    echo "  2. View latest report:"
    echo "     cat ~/.ai/reports/latest.txt"
    echo ""
    echo "  3. Check cron job status:"
    echo "     crontab -l"
    echo ""
    echo "  4. Monitor cron execution logs:"
    echo "     tail -f ~/.ai/logs/monitor-cron.log"
    echo ""
    echo "The monitoring system will run automatically every day at 9am."
    echo ""
}

# Main installation flow
main() {
    echo "========================================"
    echo "Claude Code Monitoring Setup"
    echo "========================================"
    echo ""

    if [ "$UPDATE_MODE" = true ]; then
        log_info "Running in UPDATE mode"
    else
        log_info "Running in INSTALL mode"
    fi
    echo ""

    check_prerequisites
    create_directories
    install_monitoring_script
    setup_cron_job
    update_gitignore
    verify_installation
    show_next_steps
}

# Run main installation
main
