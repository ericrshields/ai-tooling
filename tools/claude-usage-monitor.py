#!/usr/bin/env python3
"""
Claude Code Usage Monitor

Analyzes JSONL session files from Claude Code to track:
- Tool usage (Read, Write, Edit, Grep, Glob, Bash, Task, etc.)
- Agent invocations (via Task tool with subagent_type parameter)
- Token usage per tool/agent
- Temporal patterns and trends

Usage:
    python claude-usage-monitor.py [--days N] [--format json|text]

Options:
    --days N        Analyze sessions from last N days (default: 7)
    --format FMT    Output format: json or text (default: text)
    --sessions-dir  Path to session files (default: ~/.claude/projects/-home-eshields--ai-context-store/)

Examples:
    # Analyze last 7 days
    python /tmp/claude-usage-monitor.py

    # Analyze last 30 days as JSON
    python /tmp/claude-usage-monitor.py --days 30 --format json

    # Analyze specific directory
    python /tmp/claude-usage-monitor.py --sessions-dir /path/to/sessions
"""

import json
import argparse
from pathlib import Path
from datetime import datetime, timedelta
from collections import defaultdict, Counter
from typing import Dict, List, Any
import os


class ClaudeUsageMonitor:
    def __init__(self, sessions_dir: str, days: int = 7):
        self.sessions_dir = Path(sessions_dir).expanduser()
        self.days = days
        # Make cutoff_date timezone-aware (UTC)
        from datetime import timezone
        self.cutoff_date = datetime.now(timezone.utc) - timedelta(days=days)

        # Storage for analytics
        self.tool_usage = Counter()
        self.agent_usage = defaultdict(lambda: {
            'count': 0,
            'total_input_tokens': 0,
            'total_output_tokens': 0,
            'total_cache_creation_tokens': 0,
            'total_cache_read_tokens': 0,
            'sessions': set()
        })
        self.tool_token_usage = defaultdict(lambda: {
            'input_tokens': 0,
            'output_tokens': 0,
            'cache_creation_tokens': 0,
            'cache_read_tokens': 0
        })
        self.sessions_analyzed = set()
        self.total_sessions = 0

    def parse_session_file(self, filepath: Path) -> None:
        """Parse a single JSONL session file"""
        try:
            with open(filepath, 'r') as f:
                for line in f:
                    if not line.strip():
                        continue
                    try:
                        entry = json.loads(line)
                        self.process_entry(entry)
                    except json.JSONDecodeError:
                        continue
        except Exception as e:
            print(f"Error parsing {filepath}: {e}")

    def process_entry(self, entry: Dict[str, Any]) -> None:
        """Process a single JSONL entry"""
        # Check if this is within our date range
        timestamp = entry.get('timestamp')
        if timestamp:
            try:
                entry_date = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
                if entry_date < self.cutoff_date:
                    return
            except ValueError:
                pass

        # Track session
        session_id = entry.get('sessionId')
        if session_id:
            self.sessions_analyzed.add(session_id)

        # Look for tool usage in message content
        message = entry.get('message', {})
        content = message.get('content', [])

        if isinstance(content, list):
            for item in content:
                if isinstance(item, dict) and item.get('type') == 'tool_use':
                    tool_name = item.get('name')
                    tool_input = item.get('input', {})

                    if tool_name:
                        self.tool_usage[tool_name] += 1

                        # Check if this is a Task tool (agent invocation)
                        if tool_name == 'Task':
                            subagent = tool_input.get('subagent_type') or tool_input.get('agent')
                            if subagent:
                                self.track_agent_usage(subagent, message, session_id)

                        # Track token usage for this tool
                        self.track_tool_tokens(tool_name, message)

    def track_agent_usage(self, agent_name: str, message: Dict[str, Any], session_id: str) -> None:
        """Track usage of a specific agent"""
        usage = message.get('usage', {})

        self.agent_usage[agent_name]['count'] += 1
        self.agent_usage[agent_name]['total_input_tokens'] += usage.get('input_tokens', 0)
        self.agent_usage[agent_name]['total_output_tokens'] += usage.get('output_tokens', 0)
        self.agent_usage[agent_name]['total_cache_creation_tokens'] += usage.get('cache_creation_input_tokens', 0)
        self.agent_usage[agent_name]['total_cache_read_tokens'] += usage.get('cache_read_input_tokens', 0)

        if session_id:
            self.agent_usage[agent_name]['sessions'].add(session_id)

    def track_tool_tokens(self, tool_name: str, message: Dict[str, Any]) -> None:
        """Track token usage for a specific tool"""
        usage = message.get('usage', {})

        self.tool_token_usage[tool_name]['input_tokens'] += usage.get('input_tokens', 0)
        self.tool_token_usage[tool_name]['output_tokens'] += usage.get('output_tokens', 0)
        self.tool_token_usage[tool_name]['cache_creation_tokens'] += usage.get('cache_creation_input_tokens', 0)
        self.tool_token_usage[tool_name]['cache_read_tokens'] += usage.get('cache_read_input_tokens', 0)

    def analyze_all_sessions(self) -> None:
        """Analyze all session files in the directory"""
        if not self.sessions_dir.exists():
            print(f"Error: Sessions directory not found: {self.sessions_dir}")
            return

        jsonl_files = list(self.sessions_dir.glob('*.jsonl'))
        self.total_sessions = len(jsonl_files)

        for filepath in jsonl_files:
            self.parse_session_file(filepath)

    def generate_text_report(self) -> str:
        """Generate a human-readable text report"""
        lines = []
        lines.append("=" * 80)
        lines.append(f"Claude Code Usage Analysis (Last {self.days} Days)")
        lines.append("=" * 80)
        lines.append(f"Sessions analyzed: {len(self.sessions_analyzed)} (from {self.total_sessions} total files)")
        lines.append("")

        # Agent Usage Section
        if self.agent_usage:
            lines.append("AGENT USAGE:")
            lines.append("-" * 80)
            for agent, data in sorted(self.agent_usage.items(), key=lambda x: x[1]['count'], reverse=True):
                count = data['count']
                avg_input = data['total_input_tokens'] // count if count > 0 else 0
                avg_output = data['total_output_tokens'] // count if count > 0 else 0
                avg_cache_create = data['total_cache_creation_tokens'] // count if count > 0 else 0
                avg_cache_read = data['total_cache_read_tokens'] // count if count > 0 else 0

                lines.append(f"  {agent}:")
                lines.append(f"    Invocations: {count}")
                lines.append(f"    Avg input tokens: {avg_input:,}")
                lines.append(f"    Avg output tokens: {avg_output:,}")
                lines.append(f"    Avg cache creation: {avg_cache_create:,}")
                lines.append(f"    Avg cache read: {avg_cache_read:,}")
                lines.append(f"    Sessions: {len(data['sessions'])}")
                lines.append("")
        else:
            lines.append("AGENT USAGE: No agents invoked")
            lines.append("")

        # Tool Usage Section
        lines.append("TOOL USAGE:")
        lines.append("-" * 80)
        for tool, count in sorted(self.tool_usage.items(), key=lambda x: x[1], reverse=True):
            tokens = self.tool_token_usage[tool]
            total_tokens = (tokens['input_tokens'] + tokens['output_tokens'] +
                          tokens['cache_creation_tokens'])

            lines.append(f"  {tool}:")
            lines.append(f"    Calls: {count}")
            lines.append(f"    Total tokens: {total_tokens:,}")
            lines.append(f"      Input: {tokens['input_tokens']:,}")
            lines.append(f"      Output: {tokens['output_tokens']:,}")
            lines.append(f"      Cache create: {tokens['cache_creation_tokens']:,}")
            lines.append(f"      Cache read: {tokens['cache_read_tokens']:,}")
            lines.append("")

        # Summary Statistics
        lines.append("SUMMARY:")
        lines.append("-" * 80)
        lines.append(f"  Total tool calls: {sum(self.tool_usage.values())}")
        lines.append(f"  Unique tools used: {len(self.tool_usage)}")
        lines.append(f"  Total agent invocations: {sum(d['count'] for d in self.agent_usage.values())}")
        lines.append(f"  Unique agents used: {len(self.agent_usage)}")
        lines.append("")

        # Top tools by frequency
        lines.append("TOP 5 TOOLS (by frequency):")
        for tool, count in self.tool_usage.most_common(5):
            pct = (count / sum(self.tool_usage.values()) * 100) if sum(self.tool_usage.values()) > 0 else 0
            lines.append(f"  {tool}: {count} calls ({pct:.1f}%)")
        lines.append("")

        # Token Consumption Analysis
        lines.append("TOKEN CONSUMPTION ANALYSIS:")
        lines.append("-" * 80)

        # Calculate total tokens for all entities (agents + tools)
        token_consumers = []

        # Add agents
        for agent, data in self.agent_usage.items():
            total_billable = (data['total_input_tokens'] +
                            data['total_output_tokens'] * 3 +  # Output tokens cost 3x
                            data['total_cache_creation_tokens'])
            total_with_cache = total_billable + data['total_cache_read_tokens']
            cache_efficiency = (data['total_cache_read_tokens'] / total_with_cache * 100) if total_with_cache > 0 else 0

            token_consumers.append({
                'name': f"Agent: {agent}",
                'total_billable': total_billable,
                'total_cache_read': data['total_cache_read_tokens'],
                'cache_efficiency': cache_efficiency,
                'calls': data['count']
            })

        # Add tools
        for tool, tokens in self.tool_token_usage.items():
            total_billable = (tokens['input_tokens'] +
                            tokens['output_tokens'] * 3 +  # Output tokens cost 3x
                            tokens['cache_creation_tokens'])
            total_with_cache = total_billable + tokens['cache_read_tokens']
            cache_efficiency = (tokens['cache_read_tokens'] / total_with_cache * 100) if total_with_cache > 0 else 0

            token_consumers.append({
                'name': f"Tool: {tool}",
                'total_billable': total_billable,
                'total_cache_read': tokens['cache_read_tokens'],
                'cache_efficiency': cache_efficiency,
                'calls': self.tool_usage[tool]
            })

        # Sort by total billable tokens (descending)
        token_consumers.sort(key=lambda x: x['total_billable'], reverse=True)

        lines.append("Top 10 Token Consumers (by billable tokens):")
        lines.append("Note: Billable = Input + (Output * 3) + Cache Creation")
        lines.append("      Cache Read tokens shown separately (90% discount)")
        lines.append("")

        for i, consumer in enumerate(token_consumers[:10], 1):
            lines.append(f"{i}. {consumer['name']}")
            lines.append(f"   Billable tokens: {consumer['total_billable']:,}")
            lines.append(f"   Cache read tokens: {consumer['total_cache_read']:,}")
            lines.append(f"   Cache efficiency: {consumer['cache_efficiency']:.1f}%")
            lines.append(f"   Calls: {consumer['calls']}")
            lines.append("")

        # Overall cache efficiency
        total_billable_all = sum(c['total_billable'] for c in token_consumers)
        total_cache_read_all = sum(c['total_cache_read'] for c in token_consumers)
        overall_efficiency = (total_cache_read_all / (total_billable_all + total_cache_read_all) * 100) if (total_billable_all + total_cache_read_all) > 0 else 0

        lines.append("Overall Statistics:")
        lines.append(f"  Total billable tokens: {total_billable_all:,}")
        lines.append(f"  Total cache read tokens: {total_cache_read_all:,}")
        lines.append(f"  Overall cache efficiency: {overall_efficiency:.1f}%")
        lines.append("")

        # Cost estimate (using Sonnet pricing)
        cost_per_million_input = 3.00  # $3 per 1M tokens
        cost_per_million_output = 15.00  # $15 per 1M tokens (3x input)
        cost_per_million_cache_read = 0.30  # $0.30 per 1M tokens (90% discount)

        # Calculate component costs
        total_input = sum(t['input_tokens'] for t in self.tool_token_usage.values()) + \
                     sum(a['total_input_tokens'] for a in self.agent_usage.values())
        total_output = sum(t['output_tokens'] for t in self.tool_token_usage.values()) + \
                      sum(a['total_output_tokens'] for a in self.agent_usage.values())
        total_cache_create = sum(t['cache_creation_tokens'] for t in self.tool_token_usage.values()) + \
                            sum(a['total_cache_creation_tokens'] for a in self.agent_usage.values())

        estimated_cost = (
            (total_input / 1_000_000) * cost_per_million_input +
            (total_output / 1_000_000) * cost_per_million_output +
            (total_cache_create / 1_000_000) * cost_per_million_input +
            (total_cache_read_all / 1_000_000) * cost_per_million_cache_read
        )

        lines.append("Estimated Cost (Sonnet 4.5 pricing):")
        lines.append(f"  Input tokens: {total_input:,} × ${cost_per_million_input}/M = ${(total_input / 1_000_000) * cost_per_million_input:.4f}")
        lines.append(f"  Output tokens: {total_output:,} × ${cost_per_million_output}/M = ${(total_output / 1_000_000) * cost_per_million_output:.4f}")
        lines.append(f"  Cache creation: {total_cache_create:,} × ${cost_per_million_input}/M = ${(total_cache_create / 1_000_000) * cost_per_million_input:.4f}")
        lines.append(f"  Cache read: {total_cache_read_all:,} × ${cost_per_million_cache_read}/M = ${(total_cache_read_all / 1_000_000) * cost_per_million_cache_read:.4f}")
        lines.append(f"  Total estimated: ${estimated_cost:.4f}")
        lines.append("")

        lines.append("=" * 80)

        return "\n".join(lines)

    def generate_json_report(self) -> str:
        """Generate a JSON report for programmatic consumption"""
        # Convert sets to lists for JSON serialization
        agent_data = {}
        for agent, data in self.agent_usage.items():
            agent_data[agent] = {
                'count': data['count'],
                'total_input_tokens': data['total_input_tokens'],
                'total_output_tokens': data['total_output_tokens'],
                'total_cache_creation_tokens': data['total_cache_creation_tokens'],
                'total_cache_read_tokens': data['total_cache_read_tokens'],
                'avg_input_tokens': data['total_input_tokens'] // data['count'] if data['count'] > 0 else 0,
                'avg_output_tokens': data['total_output_tokens'] // data['count'] if data['count'] > 0 else 0,
                'sessions': list(data['sessions'])
            }

        report = {
            'analysis_period_days': self.days,
            'sessions_analyzed': len(self.sessions_analyzed),
            'total_session_files': self.total_sessions,
            'agent_usage': agent_data,
            'tool_usage': dict(self.tool_usage),
            'tool_token_usage': dict(self.tool_token_usage),
            'summary': {
                'total_tool_calls': sum(self.tool_usage.values()),
                'unique_tools_used': len(self.tool_usage),
                'total_agent_invocations': sum(d['count'] for d in self.agent_usage.values()),
                'unique_agents_used': len(self.agent_usage)
            }
        }

        return json.dumps(report, indent=2)


def main():
    parser = argparse.ArgumentParser(
        description='Analyze Claude Code session files for tool and agent usage',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument(
        '--days',
        type=int,
        default=7,
        help='Analyze sessions from last N days (default: 7)'
    )
    parser.add_argument(
        '--format',
        choices=['text', 'json'],
        default='text',
        help='Output format (default: text)'
    )
    parser.add_argument(
        '--sessions-dir',
        default='~/.claude/projects/-home-eshields--ai-context-store/',
        help='Path to session files directory'
    )

    args = parser.parse_args()

    # Initialize monitor
    monitor = ClaudeUsageMonitor(args.sessions_dir, args.days)

    # Analyze sessions
    print(f"Analyzing sessions from {args.sessions_dir}...")
    monitor.analyze_all_sessions()

    # Generate report
    if args.format == 'json':
        print(monitor.generate_json_report())
    else:
        print(monitor.generate_text_report())


if __name__ == '__main__':
    main()

