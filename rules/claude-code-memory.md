# User Memory - Claude Code

## Personalities and interactions
### Who is the user?
* A Senior Front End Engineer who typically writes code in React and Typescript.
* They have extensive software dev experience, but it is largely depth, not breadth. 
  * He will likely need better explanations and more help with coding tasks that are not JavaScript, React, or Typescript.
  * He has a very poor memory for CLI syntax. 

### How Claude interacts with the user
* Prefer responses to be educational, but not repetitive. For example, there is no need to repeat the user's request back to them.
* ALWAYS use the Oxford comma when working on documents or code comments!
* Don't be a sycophant.
  * Don't start off each response by saying "perfect!" "Of course!" or that the user is right. Let the analysis speak for itself.
  * The user makes mistakes too.
  * Do your own analysis tell the user if you think they are wrong.

## Memory Management

**CRITICAL**: Every time the user requests adding content to memory files, follow context efficiency principles.

For complete guidelines, see [context-efficiency.md](context-efficiency.md)

**Quick reminder**: Memory files are loaded in every conversation. Each line added consumes context in every future session - make it count.

## Coding Standards
**IMPORTANT**: If the local conventions/structure/frameworks/etc don't match what is documented in these files, prefer following the local ones over forcing new ones.
  * However, always mention the misalignment to the user.
  * Chances are it would be good to update, but would require a separate task/PR.
  * When mentioning the misalignment, the goal MUST follow the universal principles documented in:
    * `coding-principles.md` - Core principles (Error Handling, Observability, Type Safety, TDD, YAGNI, Security, Quality Gates)
    * `development-practices.md` - Daily practices (Git workflow, Testing, Documentation, Code Review)

### Additional Personal Preferences
* Use existing test infrastructure. If none exists, default to Jest and React Testing Library for JS/TS projects.
* Ensure code works with the in-use version of languages and frameworks.
* Use modern packages with wide support, unless there's a good reason otherwise.
* Use modern coding techniques, unless they differ significantly from existing code.
* Write modular code that can be reused or genericized when possible.
* Double check for duplication and redundancy before generating final output.
* Always proofread final responses to ensure alignment with thinking steps.

## Advanced Patterns

When working on complex tasks, consider these patterns:

* **Multi-Agent Coordination**: See [multi-agent-orchestration.md](multi-agent-orchestration.md) for patterns on coordinating multiple specialized agents in parallel
* **Agent Instructions**: See [agent-instruction-patterns.md](../templates/agent-instruction-patterns.md) for templates when defining custom agents or commands

## Workflows

### Google Docs Editing
See `workflows/google-docs-setup.md` for complete documentation on:
- rclone + pandoc setup and configuration
- Step-by-step workflow for editing Google Docs
- Command reference and troubleshooting

### Quick Command Reference
See `workflows/one-liners.md` for common commands:
- Tool version checks and updates
- rclone, pandoc, and gh CLI commands
- Git safety and backup patterns
- Troubleshooting commands