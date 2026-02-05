#!/bin/bash
#
# Automated Claude Code usage monitoring wrapper script
#
# This script runs the usage monitor and saves reports to ~/.ai/reports/
# with timestamps. Designed to be run daily via cron for trending analysis.
#
# Usage:
#   ~/.ai/tools/run-usage-monitor.sh [days] [sessions_dir]
#
# Arguments:
#   days         - Number of days to analyze (default: 7)
#   sessions_dir - Path to sessions directory (auto-detected if omitted)
#
# Environment Variables:
#   CLAUDE_SESSIONS_DIR - Override sessions directory
#
# Cron example (daily at 9am):
#   0 9 * * * ~/.ai/tools/run-usage-monitor.sh >> ~/.ai/logs/monitor-cron.log 2>&1
#
# Cron example with custom sessions directory:
#   0 9 * * * CLAUDE_SESSIONS_DIR=/custom/path ~/.ai/tools/run-usage-monitor.sh >> ~/.ai/logs/monitor-cron.log 2>&1

set -euo pipefail

# Configuration
DAYS="${1:-7}"
SESSIONS_DIR="${2:-${CLAUDE_SESSIONS_DIR:-}}"
MONITOR_SCRIPT="$HOME/.ai/tools/claude-usage-monitor.py"
REPORTS_DIR="$HOME/.ai/reports"
LOG_DIR="$HOME/.ai/logs"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="$REPORTS_DIR/usage-$TIMESTAMP.txt"
LATEST_LINK="$REPORTS_DIR/latest.txt"

# Ensure directories exist
mkdir -p "$REPORTS_DIR" "$LOG_DIR"

# Build monitor command
MONITOR_CMD=("$MONITOR_SCRIPT" --days "$DAYS")
if [ -n "$SESSIONS_DIR" ]; then
    MONITOR_CMD+=(--sessions-dir "$SESSIONS_DIR")
    echo "[$(date)] Running usage monitor for last $DAYS days from $SESSIONS_DIR..."
else
    echo "[$(date)] Running usage monitor for last $DAYS days (auto-detecting sessions)..."
fi

# Run monitoring tool
if "${MONITOR_CMD[@]}" > "$REPORT_FILE"; then
    echo "[$(date)] Report saved to: $REPORT_FILE"

    # Update latest symlink
    ln -sf "$(basename "$REPORT_FILE")" "$LATEST_LINK"
    echo "[$(date)] Updated latest report link"

    # Cleanup old reports (keep last 30 days)
    find "$REPORTS_DIR" -name "usage-*.txt" -type f -mtime +30 -delete
    echo "[$(date)] Cleaned up reports older than 30 days"

    # Optional: Check for significant changes
    # Compare with previous report to detect major usage spikes
    PREV_REPORT=$(find "$REPORTS_DIR" -name "usage-*.txt" -type f | sort -r | sed -n '2p')
    if [ -n "$PREV_REPORT" ]; then
        # Extract total billable tokens from both reports
        CURRENT_TOKENS=$(grep "Total billable tokens:" "$REPORT_FILE" | awk '{gsub(/,/,""); print $4}')
        PREV_TOKENS=$(grep "Total billable tokens:" "$PREV_REPORT" | awk '{gsub(/,/,""); print $4}')

        if [ -n "$CURRENT_TOKENS" ] && [ -n "$PREV_TOKENS" ] && [ "$PREV_TOKENS" != "0" ]; then
            # Calculate percentage change
            CHANGE=$(awk "BEGIN {printf \"%.1f\", (($CURRENT_TOKENS - $PREV_TOKENS) / $PREV_TOKENS) * 100}")
            echo "[$(date)] Token usage change from previous report: $CHANGE%"

            # Alert if change is > 50%
            if (( $(echo "$CHANGE > 50" | bc -l) )); then
                echo "[$(date)] WARNING: Significant token usage increase detected: $CHANGE%"
                # Could add notification here (email, Slack, etc.)
            fi
        elif [ -n "$CURRENT_TOKENS" ] && [ -n "$PREV_TOKENS" ] && [ "$PREV_TOKENS" = "0" ]; then
            echo "[$(date)] Token usage change: N/A (previous report had no usage)"
        fi
    fi

    echo "[$(date)] Monitoring complete"
    exit 0
else
    echo "[$(date)] ERROR: Monitoring script failed"
    exit 1
fi
