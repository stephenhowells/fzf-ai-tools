<div align="center">
  <img src="https://raw.githubusercontent.com/stephenhowells/fzf-ai-tools/refs/heads/images/fzf-ai-tools.svg" alt="fzf-ai-tools" width="60%">
</div>

<br>
<br>

> _Smart Z shell super-powers for fzf._

`fzf-ai-tools` glues together [`fzf`](https://github.com/junegunn/fzf) and [`aichat`](https://github.com/sigoden/aichat) to add _explain-this-for-me_ goodness to your Z shell. Pipe your history, aliases, or any file through fuzzy-finder search and ask an LLM for a quick human-readable explanation.

## 🎥 Demo

<div align="center">
  <img src="https://raw.githubusercontent.com/stephenhowells/fzf-ai-tools/refs/heads/images/demo.gif" alt="fzf-ai-tools" width="100%">
</div>

## ✨ Features

- **`ai:h`** — History: Fuzzy-search your shell history and have AI explain the chosen command.
- **`ai:a`** — Aliases: Browse your defined aliases and let AI decode what that cryptic one-liner does.
- **`ai:f`** — Files: Fuzzy-find project files and get a top-of-file interpretation.
- **`ai:i`** — Input: Type arbitrary input and ask AI about it (bound to <kbd>Ctrl-A</kbd> by default).
- Dependency check that politely yells at you if `fzf` or `aichat` are missing.

## 🚀 Installation

### 1. Install the runtime dependencies

```bash
brew install fzf        # or your package manager of choice
brew install aichat     # https://github.com/sigoden/aichat
```

The `aichat` tool requires an API key for an LLM. Consult the [aichat repository](https://github.com/sigoden/aichat) for more information.

### 2. Grab the plugin

<details>
<summary>Antidote</summary>

```zsh
antidote bundle stephenhowells/fzf-ai-tools
```

</details>

<details>
<summary>Oh My Zsh</summary>

Clone into `~/.oh-my-zsh/custom/plugins` and add `fzf-ai-tools` to the `plugins=(...)` array in `.zshrc`.

```zsh
git clone https://github.com/stephenhowells/fzf-ai-tools ~/.oh-my-zsh/custom/plugins/fzf-ai-tools
```

</details>

<details>
<summary>Zinit</summary>

```zsh
zinit light stephenhowells/fzf-ai-tools
```

</details>

<details>
<summary>Manual (no plugin manager)</summary>

Clone the repo anywhere (for example `~/.zsh/fzf-ai-tools`) and source the plugin file from your `.zshrc`:

```zsh
# Grab the plugin
git clone https://github.com/stephenhowells/fzf-ai-tools ~/.zsh/fzf-ai-tools

# Add to your .zshrc
source ~/.zsh/fzf-ai-tools/fzf-ai-tools.plugin.zsh
```

</details>

### 3. Reload Zsh

```zsh
exec zsh
```

## 📖 Usage

| Alias  | Long-form        | What it does                                                                                       |
| ------ | ---------------- | -------------------------------------------------------------------------------------------------- |
| `ai:h` | `fzf-ai-history` | Fuzzy search your command history. The highlighted line is sent to AI: _"Explain this command: …"_ |
| `ai:a` | `fzf-ai-aliases` | Search your defined aliases and ask: _"Explain this alias: …"_                                     |
| `ai:f` | `fzf-ai-files`   | Fuzzy search files (ignoring dot-files) and request an AI summary of the first 100 lines.          |
| `ai:i` | `fzf-ai-input`   | Inline prompt: type anything, hit <kbd>Enter</kbd>, receive enlightenment.                         |

#### Keybindings

| Key               | Action                                              |
| ----------------- | --------------------------------------------------- |
| <kbd>Ctrl-A</kbd> | Trigger `fzf-ai-input` from anywhere in the prompt. |

## ⚙️ Customization

```zsh
# Change the keybinding to Ctrl-E for the fzf-ai-input command

bindkey '^E' fzf-ai-input
```

## 🤔 Troubleshooting

| Symptom        | Likely Cause                         | Fix                                                            |
| -------------- | ------------------------------------ | -------------------------------------------------------------- |
| Blank previews | `aichat` lacks API key / network.    | Configure `AICHAT_OPENAI_KEY` or whatever AI provider you use. |
| Slowness       | Some LLM responses can take a while. | Try switching to a different AI model in `aichat`.             |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.
