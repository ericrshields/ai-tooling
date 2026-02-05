#!/bin/bash
#
# Automated Claude Code usage monitoring wrapper script
#
# This script runs the usage monitor and saves reports to ~/.ai/reports/
# with timestamps. Designed to be run daily via cron for trending analysis.
#
# Usage:
#   ~/.ai/tools/run-usage-monitor.sh [days]
#
# Arguments:
#   days - Number of days to analyze (default: 7)
#
# Cron example (daily at 9am):
#   0 9 * * * ~/.ai/tools/run-usage-monitor.sh >> ~/.ai/logs/monitor-cron.log 2>&1

set -euo pipefail

# Configuration
DAYS="${1:-7}"
MONITOR_SCRIPT="$HOME/.ai/tools/claude-usage-monitor.py"
REPORTS_DIR="$HOME/.ai/reports"
LOG_DIR="$HOME/.ai/logs"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="$REPORTS_DIR/usage-$TIMESTAMP.txt"
LATEST_LINK="$REPORTS_DIR/latest.txt"

# Ensure directories exist
mkdir -p "$REPORTS_DIR" "$LOG_DIR"

# Run monitoring tool
echo "[$(date)] Running usage monitor for last $DAYS days..."
if "$MONITOR_SCRIPT" --days "$DAYS" > "$REPORT_FILE"; then
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

        if [ -n "$CURRENT_TOKENS" ] && [ -n "$PREV_TOKENS" ]; then
            # Calculate percentage change
            CHANGE=$(awk "BEGIN {printf \"%.1f\", (($CURRENT_TOKENS - $PREV_TOKENS) / $PREV_TOKENS) * 100}")
            echo "[$(date)] Token usage change from previous report: $CHANGE%"

            # Alert if change is > 50%
            if (( $(echo "$CHANGE > 50" | bc -l) )); then
                echo "[$(date)] WARNING: Significant token usage increase detected: $CHANGE%"
                # Could add notification here (email, Slack, etc.)
            fi
        fi
    fi

    echo "[$(date)] Monitoring complete"
    exit 0
else
    echo "[$(date)] ERROR: Monitoring script failed"
    exit 1
fi
