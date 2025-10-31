# agentx zsh plugin

a quick switcher for multiple ai agent cli tools. press `ctrl+x` to open an interactive menu, select an agent, and run commands through it.

## supported agents

- claude
- codex
- opencode
- kimi
- crush
- cursor
- droid
- gemini
- qwen

## installation

### oh-my-zsh

clone the repository into your oh-my-zsh custom plugins directory:

```bash
git clone https://github.com/githubesson/agentx.git ~/.oh-my-zsh/custom/plugins/agentx
```

add `agentx` to your `.zshrc` plugins list:

```bash
plugins=(... ai-agents)
```

### manual

clone the repository to your preferred location:

```bash
git clone https://github.com/githubesson/agentx.git ~/path/to/agentx
```

source the plugin in your `.zshrc`:

```bash
source ~/path/to/agentx/agentx.plugin.zsh
```

## usage

### keybinding

- press `ctrl+x` to open the agent selection menu
- press the corresponding key for your desired agent:
  - `c` for claude
  - `x` for codex
  - `o` for opencode
  - `k` for kimi
  - `r` for crush
  - `u` for cursor
  - `d` for droid
  - `g` for gemini
  - `q` for qwen

### running commands

once you select an agent, a `[agent-name]` prefix appears in your prompt. type a command or natural language request, and the plugin will route it to the selected agent's cli tool.

press `ctrl+x` again to deselect the current agent and return to normal shell behavior.

## requirements

you must have the corresponding ai agent cli tools installed on your system. the plugin will only show available agents in the menu based on what's actually installed.
