# 🚀 Windows Terminal & PowerShell Dotfiles

Automated setup script for a modern, beautiful, and developer-friendly terminal environment on Windows:
- **Oh My Posh**: Beautiful prompt theme engine (defaults to Catppuccin, includes Git branch/status, Python venv, execution time).
- **MesloLGM Nerd Font**: Full glyphs and developer icons support.
- **PowerShell 7**: Modern, cross-platform, high-performance PowerShell.
- **PSReadLine 2.4.5**: Intelligent Predictive IntelliSense with history suggestions, seamlessly toggleable between ghost text (`InlineView`) and dropdown list (`ListView`) with the `F2` key.
- **posh-git**: Comprehensive Git autocomplete for commands, branches, and flags with an interactive menu on `Tab` / `Ctrl + Space`.
- **Terminal-Icons**: Colorized folder and file icons in directory listings.
- **Windows Terminal & VS Code**: Automatically configured with `MesloLGM Nerd Font`.

---

## ⚡ Quick 1-Line Installation

Open **PowerShell** and run:

```powershell
irm https://raw.githubusercontent.com/nhatxtn/dotfiles/main/setup-terminal.ps1 | iex
```

---

## 🛠️ Keybindings & Helper Commands

| Shortcut / Command | Description |
|---|---|
| `Tab` or `Ctrl + Space` | Open interactive menu to pick Git commands / arguments |
| `F2` | Toggle between `ListView` (menu box) and `InlineView` (ghost text) |
| `→` or `Ctrl + f` | Accept entire suggestion |
| `Ctrl + →` | Accept suggestion word-by-word |
| `↑` / `↓` | Filter and cycle through command history matching typed prefix |
| `Ctrl + r` | Interactive full history search |
| `Get-PoshThemes` | List all downloaded Oh My Posh themes |
| `Set-PoshTheme <name>` | Switch theme instantly (`catppuccin`, `tokyonight_storm`, `atomic`,...) |
| `Set-SuggestionStyle` | Change default prediction style (`-Style List` or `-Style Inline`) |
| `reload` | Reload PowerShell profile immediately |
| `ll` | List files and directories with icons |
| `g` | Alias for `git` |

---

## 📖 Troubleshooting & Corporate Laptop Setup

Encountering errors on restricted company laptops or clean Windows machines (such as `ExecutionPolicy` script blocks, `oh-my-posh is not recognized`, font errors, or `InlinePrediction` color issues)?

👉 See the complete **[Troubleshooting & Known Issues Guide](TROUBLESHOOTING.md)** for root causes, zero-admin workarounds, and step-by-step fixes.

