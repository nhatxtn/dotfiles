# 🛠️ Troubleshooting & Known Issues Guide

This document covers common issues encountered when setting up and running **Oh My Posh**, **PowerShell**, and modern terminal tools on Windows—especially on **restricted corporate laptops** (e.g. managed by IT Group Policy, AppLocker, or Intune)—along with their root causes and verified solutions.

---

## Table of Contents
1. [Script Execution Disabled (`PSSecurityException` / `UnauthorizedAccess`)](#1-script-execution-disabled-pssecurityexception--unauthorizedaccess)
2. [Unicode / Emoji Parser Errors in Windows PowerShell 5.1](#2-unicode--emoji-parser-errors-in-windows-powershell-51)
3. [`InlinePrediction is not a valid color property`](#3-inlineprediction-is-not-a-valid-color-property)
4. [`The term 'oh-my-posh' is not recognized` / Winget Blocked](#4-the-term-oh-my-posh-is-not-recognized--winget-blocked)
5. [Font Not Valid / Missing Icons & Glyphs](#5-font-not-valid--missing-icons--glyphs)
6. [OneDrive Sync Redirection of `$PROFILE`](#6-onedrive-sync-redirection-of-profile)
7. [Corporate Proxy / VPN SSL Certificate Errors](#7-corporate-proxy--vpn-ssl-certificate-errors)
8. [Slow Terminal Startup Time](#8-slow-terminal-startup-time)
9. [VS Code Integrated Terminal Shows Broken Icons](#9-vs-code-integrated-terminal-shows-broken-icons)
10. [How to Update Everything in the Future](#10-how-to-update-everything-in-the-future)

---

## 1. Script Execution Disabled (`PSSecurityException` / `UnauthorizedAccess`)

### Symptom
When opening PowerShell or running a script, you see:
```text
File ...\setup-terminal.ps1 cannot be loaded because running scripts is disabled on this system.
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

### Cause
Windows sets `ExecutionPolicy` to `Restricted` by default for security, preventing `.ps1` scripts from running. On corporate laptops, IT administrators often lock this policy via Group Policy.

### Solution

#### Option A: One-time Bypass (Recommended — No Admin needed)
Run the script using the `-ExecutionPolicy Bypass` flag:
```powershell
powershell -ExecutionPolicy Bypass -File .\setup-terminal.ps1
```
Or when running directly from GitHub:
```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/nhatxtn/dotfiles/main/setup-terminal.ps1 | iex"
```

#### Option B: Enable permanently for Current User (No Admin needed)
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

#### Option C: Windows Terminal Permanent Bypass (Corporate Workaround)
If IT Group Policy locks `Set-ExecutionPolicy`:
1. Open Windows Terminal settings (`Ctrl + ,`).
2. Select your profile (e.g. **PowerShell** or **PowerShell 7**).
3. Change **Command line** to:
   ```text
   powershell.exe -ExecutionPolicy Bypass -NoLogo
   ```
   *(or `pwsh.exe -ExecutionPolicy Bypass -NoLogo`)*.
4. Save. Windows Terminal will now bypass the restriction automatically on launch.

---

## 2. Unicode / Emoji Parser Errors in Windows PowerShell 5.1

### Symptom
When running a script on a clean machine:
```text
At line:42 char:66: Missing argument in parameter list.
The ampersand (&) character is not allowed...
The '<' operator is reserved for future use...
The string is missing the terminator: ".
```

### Cause
Windows PowerShell 5.1 (the preinstalled default shell) reads `.ps1` files without a UTF-8 BOM as **Windows-1252 (ANSI)**. When multi-byte UTF-8 characters (like emojis `🚀`, `🎉`, or checkmarks `✓`) are interpreted as ANSI, byte offsets shift and quotation marks `"` become desynchronized, causing the parser to treat the remainder of the script as unquoted code.

### Solution
- All scripts in this repository are strictly encoded in **pure ASCII** (e.g., using `[OK]`, `[*]`, `[+]` instead of emojis) and saved with clean quoting.
- Always use single quotes `'...'` for literal strings and avoided raw `<` or unescaped `&` characters in console output.

---

## 3. `InlinePrediction is not a valid color property`

### Symptom
When loading `$PROFILE`:
```text
Set-PSReadLineOption : Cannot validate argument on parameter 'Colors'.
"InlinePrediction" is not a valid color property.
```

### Cause
Older Windows 10 and 11 installations ship with **PSReadLine 2.0.0** preinstalled in `C:\Program Files\WindowsPowerShell\Modules\PSReadLine\2.0.0`. Predictive IntelliSense and the `InlinePrediction` color property were only introduced in **PSReadLine 2.2.0+**.

### Solution

#### Step 1: Upgrade PSReadLine to latest version
Run in PowerShell (Current User scope, no admin required):
```powershell
Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
```

#### Step 2: Use version-guarded profile configuration
In `$PROFILE`, always wrap predictive settings in a version check:
```powershell
$psr = Get-Module PSReadLine
if ($psr -and $psr.Version -ge [Version]'2.2.0') {
    Set-PSReadLineOption -Colors @{ InlinePrediction = "$([char]0x1b)[38;5;246m" }
}
```
*(This is already built into our `setup-terminal.ps1` script).*

---

## 4. `The term 'oh-my-posh' is not recognized` / Winget Blocked

### Symptom
```text
The term 'oh-my-posh' is not recognized as the name of a cmdlet, function, script file, or operable program.
```

### Cause
On corporate laptops, `winget` (Windows Package Manager) is often disabled by IT Group Policy, or Microsoft Store is blocked. As a result, Oh My Posh was never downloaded, or its binary folder was never added to the user's `PATH`.

### Solution (Zero-Admin Standalone Installer)
Download `oh-my-posh.exe` directly from GitHub releases and register it to your User `PATH`:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# 1. Create binary folder
$binDir = "$HOME\AppData\Local\Programs\oh-my-posh\bin"
if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir -Force | Out-Null }
$exePath = Join-Path $binDir "oh-my-posh.exe"

# 2. Download executable directly from GitHub
Invoke-WebRequest -Uri "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-windows-amd64.exe" -OutFile $exePath -UseBasicParsing

# 3. Add to User PATH permanently
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$binDir", "User")
}
$env:Path += ";$binDir"

# 4. Verify
oh-my-posh --version
```

---

## 5. Font Not Valid / Missing Icons & Glyphs

### Symptom
- Windows Terminal displays: `Could not find the selected font "MesloLGM Nerd Font". Falling back to "Cascadia Mono"...`
- Oh My Posh shows broken rectangles (``), question marks, or boxes instead of Git branch icons, folders, or OS logos.

### Cause
Nerd Fonts contain special PUA (Private Use Area) icon glyphs. Standard fonts (like Arial, Consolas, or Courier New) do not have these glyphs.

### Solution

#### Method 1: Automatic via Oh My Posh CLI
```powershell
oh-my-posh font install Meslo
```

#### Method 2: Manual Install (Zero-Admin)
1. Download [Meslo.zip from Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip).
2. Extract the archive.
3. Select `MesloLGM Nerd Font Regular.ttf` (or all `.ttf` files).
4. Right-click and select **"Install for me"** *(do NOT choose "Install for all users" to avoid admin prompts)*.
5. **Restart Windows Terminal completely**.

---

## 6. OneDrive Sync Redirection of `$PROFILE`

### Symptom
- Changes made to `$PROFILE` don't seem to apply, or you see sync conflicts in your profile file.
- The path shows: `C:\Users\<user>\OneDrive - Company\Documents\PowerShell\...`

### Cause
When Windows Known Folder Move (KFM) / OneDrive folder backup is enabled, the `Documents` directory is redirected into OneDrive. PowerShell `$PROFILE` automatically points to the redirected path:
- WinPS: `$HOME\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
- PWSH 7: `$HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

### Solution
Our setup script automatically detects the true location of `[Environment]::GetFolderPath('MyDocuments')` and writes the profile to **both** the OneDrive-redirected folder and local `Documents` folder to guarantee synchronization regardless of cloud status.

---

## 7. Corporate Proxy / VPN SSL Certificate Errors

### Symptom
When downloading themes, fonts, or modules:
```text
The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel.
```

### Cause
Corporate firewalls / Zscaler / Netskope perform SSL decryption and re-sign certificates using a company root CA that PowerShell might not trust by default, or TLS 1.0 is selected.

### Solution
Enforce TLS 1.2 and TLS 1.3 at the start of your PowerShell session:
```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
```
If your company requires a proxy:
```powershell
$proxy = [System.Net.WebRequest]::GetSystemWebProxy()
$proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
[System.Net.WebRequest]::DefaultWebProxy = $proxy
```

---

## 8. Slow Terminal Startup Time

### Symptom
When opening a new tab, it takes several seconds to load:
```text
Loading personal and system profiles took 2500ms.
```

### Cause
Importing multiple modules (`Terminal-Icons`, `posh-git`, `PSReadLine`) and initializing Oh My Posh can introduce startup overhead if module caches are cold or if Git checks a large repository.

### Solution
1. **Use PowerShell 7 (`pwsh`)**: PowerShell 7 starts 3x to 5x faster than legacy Windows PowerShell 5.1.
2. **Lazy-load non-essential modules**: Only import heavy modules on demand.
3. **Use cache for Oh My Posh**: Ensure Oh My Posh cache is writable in `$env:LOCALAPPDATA\oh-my-posh`.
4. Test profile execution time:
   ```powershell
   Measure-Command { . $PROFILE }
   ```
   *(A well-optimized profile should load in under 600ms on modern hardware).*

---

## 9. VS Code Integrated Terminal Shows Broken Icons

### Symptom
Icons look great in Windows Terminal, but in VS Code's integrated terminal, you see squares or question marks.

### Cause
VS Code has its own separate terminal font setting that defaults to the editor font or system monospace font rather than the Windows Terminal settings.

### Solution
Open VS Code `settings.json` (`Ctrl + Shift + P` ➔ `Preferences: Open User Settings (JSON)`) and add:
```json
"terminal.integrated.fontFamily": "MesloLGM Nerd Font"
```
*(Our `setup-terminal.ps1` script automates this step).*

---

## 10. How to Update Everything in the Future

Keep your terminal environment modern and updated with these quick commands:

| Tool | Update Command |
|---|---|
| **Oh My Posh** | `oh-my-posh upgrade` *(or `winget upgrade JanDeDobbeleer.OhMyPosh`)* |
| **PowerShell 7** | `winget upgrade Microsoft.PowerShell` |
| **PSReadLine** | `Update-Module -Name PSReadLine` |
| **posh-git** | `Update-Module -Name posh-git` |
| **Terminal-Icons** | `Update-Module -Name Terminal-Icons` |
| **Dotfiles Profile** | `irm https://raw.githubusercontent.com/nhatxtn/dotfiles/main/setup-terminal.ps1 \| iex` |
