# reconcile: kind=tap pattern="(ai|llm|agent|claude|codex|hermes)"
# reconcile: kind=brew pattern="(ai|llm|ollama|agent|claude|codex|hermes)"
# reconcile: kind=cask pattern="(claude|chatgpt)"
# reconcile: kind=npm pattern="(ai|agent|claude|codex|codeburn)"
# reconcile: kind=vscode pattern="(anthropic|openai|claude|chatgpt)"

tap "alexsjones/llmfit"
brew "alexsjones/llmfit/llmfit", trusted: true
brew "node"
cask "claude"
npm "@anthropic-ai/claude-code"
npm "@openai/codex"
npm "@alibaba-group/open-code-review"
npm "codeburn"
vscode "anthropic.claude-code"
vscode "openai.chatgpt"

# Claude Code plugin marketplaces
# Parsed by scripts/apply_claude_plugin_selection.py; comments keep this file valid for brew bundle
# claude_marketplace "claude-code-workflows", source: "github:wshobson/agents"
# claude_marketplace "lean4-skills", source: "github:cameronfreer/lean4-skills"
# claude_marketplace "open-code-review", source: "github:alibaba/open-code-review"
# claude_marketplace "posit-dev-skills", source: "github:posit-dev/skills"
# claude_marketplace "understand-anything", source: "github:Lum1104/Understand-Anything"

# Claude Code plugins to install and enable
# claude_plugin "cloud-infrastructure@claude-code-workflows"
# claude_plugin "kubernetes-operations@claude-code-workflows"
# claude_plugin "lean4@lean4-skills"
# claude_plugin "open-code-review@open-code-review"
# claude_plugin "open-source@posit-dev-skills"
# claude_plugin "posit-dev@posit-dev-skills"
# claude_plugin "python-development@claude-code-workflows"
# claude_plugin "quarto@posit-dev-skills"
# claude_plugin "r-lib@posit-dev-skills"
# claude_plugin "shiny@posit-dev-skills"
# claude_plugin "understand-anything@understand-anything"
