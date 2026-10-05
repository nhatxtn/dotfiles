# ====================================================================
# ONE-CLICK MODERN TERMINAL SETUP SCRIPT FOR WINDOWS
# (Oh My Posh + Meslo Nerd Font + PowerShell 7 + Smart Autocomplete)
# Works on all machines, including restricted corporate laptops!
# ====================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [*] STARTING TERMINAL SETUP FOR CODING (OH MY POSH)" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Install Oh My Posh
Write-Host ""
Write-Host "[1/7] Checking and installing Oh My Posh..." -ForegroundColor Cyan
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    # Try winget first
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Attempting install via winget..." -ForegroundColor Yellow
        winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements 2>$null
    }
    
    # Reload PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # If still not found (common on corporate machines without winget), download binary directly
    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Host "Downloading Oh My Posh binary directly (No-Admin required)..." -ForegroundColor Yellow
        $binDir = "$HOME\AppData\Local\Programs\oh-my-posh\bin"
        if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir -Force | Out-Null }
        $exePath = Join-Path $binDir "oh-my-posh.exe"
        try {
            Invoke-WebRequest -Uri "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-windows-amd64.exe" -OutFile $exePath -UseBasicParsing -TimeoutSec 30
            $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
            if ($userPath -notlike "*$binDir*") {
                [Environment]::SetEnvironmentVariable("Path", "$userPath;$binDir", "User")
            }
            $env:Path += ";$binDir"
            Write-Host "[OK] Oh My Posh downloaded to $binDir" -ForegroundColor Green
        } catch {
            Write-Host "Failed to download Oh My Posh: $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "[OK] Oh My Posh is already installed." -ForegroundColor Green
}

# 2. Install Meslo Nerd Font
Write-Host ""
Write-Host "[2/7] Checking and installing Meslo Nerd Font..." -ForegroundColor Cyan
$fontInstalled = $false
try {
    $fontKeys = (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts', 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -ErrorAction SilentlyContinue).psobject.properties.Name
    if ($fontKeys -match "Meslo") { $fontInstalled = $true }
} catch {}

if (-not $fontInstalled) {
    $success = $false
    # Try CLI font install
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        try {
            oh-my-posh font install Meslo
            $success = $true
            Write-Host "[OK] Meslo Nerd Font installed via oh-my-posh." -ForegroundColor Green
        } catch {}
    }
    
    # Fallback direct download for corporate laptops
    if (-not $success) {
        Write-Host "Downloading Meslo Nerd Font directly (User scope, No-Admin)..." -ForegroundColor Yellow
        try {
            $fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
            if (-not (Test-Path $fontDir)) { New-Item -ItemType Directory -Path $fontDir -Force | Out-Null }
            $tempZip = "$env:TEMP\Meslo.zip"
            $tempFolder = "$env:TEMP\MesloFont"
            Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip" -OutFile $tempZip -UseBasicParsing -TimeoutSec 60
            Expand-Archive -Path $tempZip -DestinationPath $tempFolder -Force
            Get-ChildItem "$tempFolder\*.ttf" | ForEach-Object {
                Copy-Item $_.FullName -Destination $fontDir -Force
                New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "$($_.BaseName) (TrueType)" -Value $_.Name -Force | Out-Null
            }
            Remove-Item $tempZip, $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[OK] Meslo Nerd Font installed to user font directory." -ForegroundColor Green
        } catch {
            Write-Host "Notice: Font download skipped. You can manually install Meslo.zip if needed." -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "[OK] Meslo Nerd Font is already installed." -ForegroundColor Green
}

# 3. Check PowerShell 7
Write-Host ""
Write-Host "[3/7] Checking PowerShell 7..." -ForegroundColor Cyan
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Installing PowerShell 7 via winget..." -ForegroundColor Yellow
        winget install Microsoft.PowerShell -s winget --accept-source-agreements --accept-package-agreements 2>$null
    } else {
        Write-Host "PowerShell 7 not found. Continuing with current PowerShell version." -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] PowerShell 7 is ready." -ForegroundColor Green
}

# 4. Install and upgrade required PowerShell modules
Write-Host ""
Write-Host "[4/7] Installing supporting modules (Terminal-Icons, posh-git, PSReadLine)..." -ForegroundColor Cyan
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction SilentlyContinue

# Ensure PSReadLine is updated to 2.2+ (Windows 10/11 defaults to 2.0 which lacks Predictive IntelliSense)
$currentPsr = Get-Module -ListAvailable -Name PSReadLine | Sort-Object Version -Descending | Select-Object -First 1
if (-not $currentPsr -or $currentPsr.Version -lt [Version]'2.2.0') {
    Write-Host "Upgrading PSReadLine to latest version for predictive suggestions..." -ForegroundColor Yellow
    Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction SilentlyContinue
}

$modules = @("Terminal-Icons", "posh-git")
if ($PSVersionTable.PSEdition -eq "Core") {
    $modules += "CompletionPredictor"
}

foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "Installing module: $mod..." -ForegroundColor Yellow
        Install-Module -Name $mod -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction SilentlyContinue
    } else {
        Write-Host "[OK] Module $mod is already installed." -ForegroundColor Green
    }
}

# 5. Download popular Oh My Posh themes
Write-Host ""
Write-Host "[5/7] Downloading popular Oh My Posh themes into ~/.poshthemes..." -ForegroundColor Cyan
$themesDir = "$HOME\.poshthemes"
if (-not (Test-Path $themesDir)) { New-Item -ItemType Directory -Path $themesDir -Force | Out-Null }
$popularThemes = @("catppuccin", "tokyonight_storm", "atomic", "bubbles", "clean-detailed", "jandedobbeleer")
foreach ($t in $popularThemes) {
    $dest = Join-Path $themesDir "$t.omp.json"
    if (-not (Test-Path $dest)) {
        try {
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$t.omp.json" -OutFile $dest -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
        } catch {}
    }
}
Write-Host "[OK] Themes downloaded successfully." -ForegroundColor Green

# 6. Configure Windows Terminal and VS Code to use MesloLGM Nerd Font
Write-Host ""
Write-Host "[6/7] Applying MesloLGM Nerd Font to Windows Terminal and VS Code..." -ForegroundColor Cyan
# Windows Terminal
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $wtSettings) {
    try {
        $content = Get-Content $wtSettings -Raw
        if ($content -notmatch '"face":\s*"MesloLGM Nerd Font"') {
            $content = $content -replace '"defaults":\s*\{', '"defaults": { "font": { "face": "MesloLGM Nerd Font", "size": 11 }'
            Set-Content -Path $wtSettings -Value $content -Encoding utf8
            Write-Host "[OK] Font updated for Windows Terminal." -ForegroundColor Green
        }
    } catch {}
}

# VS Code
$vscodeSettings = "$env:APPDATA\Code\User\settings.json"
if (Test-Path $vscodeSettings) {
    try {
        $vJson = Get-Content $vscodeSettings -Raw | ConvertFrom-Json
        if (-not $vJson.'terminal.integrated.fontFamily') {
            $vJson | Add-Member -MemberType NoteProperty -Name "terminal.integrated.fontFamily" -Value "MesloLGM Nerd Font"
            $vJson | ConvertTo-Json -Depth 32 | Set-Content -Path $vscodeSettings -Encoding utf8
            Write-Host "[OK] Font updated for VS Code Terminal." -ForegroundColor Green
        }
    } catch {}
}

# 7. Generate complete PowerShell Profile
Write-Host ""
Write-Host "[7/7] Installing PowerShell Profile configuration..." -ForegroundColor Cyan
$profileScript = @'
# ====================================================================
# Modern Developer Profile (Oh My Posh + Predictive IntelliSense + Posh-Git)
# ====================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Terminal Icons
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}

# Posh-Git (Autocomplete Git commands, branches, and flags)
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git -ErrorAction SilentlyContinue
}

# Completion Predictor (PowerShell 7+)
if ($PSVersionTable.PSEdition -eq "Core") {
    if (Get-Module -ListAvailable -Name CompletionPredictor) {
        Import-Module CompletionPredictor -ErrorAction SilentlyContinue
    }
}

# PSReadLine & Predictive Suggestions / History
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue

    $psr = Get-Module PSReadLine
    if ($psr -and $psr.Version -ge [Version]'2.2.0') {
        try {
            if ($PSVersionTable.PSEdition -eq "Core") {
                Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction Stop
            } else {
                Set-PSReadLineOption -PredictionSource History -ErrorAction Stop
            }

            $viewPrefFile = "$HOME\.poshthemes\prediction_style.txt"
            $viewStyle = "ListView"
            if (Test-Path $viewPrefFile) {
                $savedStyle = (Get-Content $viewPrefFile -Raw -ErrorAction SilentlyContinue).Trim()
                if ($savedStyle -in @("InlineView", "ListView")) {
                    $viewStyle = $savedStyle
                }
            }
            Set-PSReadLineOption -PredictionViewStyle $viewStyle -ErrorAction Stop
            Set-PSReadLineOption -Colors @{
                InlinePrediction = "$([char]0x1b)[38;5;246m"
            } -ErrorAction SilentlyContinue
            Set-PSReadLineKeyHandler -Key F2 -Function SwitchPredictionView -ErrorAction SilentlyContinue
            Set-PSReadLineKeyHandler -Key "Ctrl+RightArrow" -Function AcceptNextSuggestionWord -ErrorAction SilentlyContinue
        } catch {}
    }

    # Universal Keybindings (Supported across all PSReadLine versions)
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Chord "Ctrl+Spacebar" -Function MenuComplete -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardChar -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Chord "Ctrl+f" -Function AcceptSuggestion -ErrorAction SilentlyContinue
}

# Oh My Posh Prompt
$env:POSH_THEMES_PATH = "$HOME\.poshthemes"
$currentThemeFile = "$HOME\.poshthemes\current_theme.txt"
$themeName = "catppuccin"
if (Test-Path $currentThemeFile) {
    $saved = (Get-Content $currentThemeFile -Raw -ErrorAction SilentlyContinue).Trim()
    if ($saved) { $themeName = $saved }
}
$themeConfig = "$HOME\.poshthemes\$themeName.omp.json"
if (-not (Test-Path $themeConfig)) {
    $themeConfig = "$HOME\.poshthemes\catppuccin.omp.json"
}

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if ($PSVersionTable.PSEdition -eq "Core") {
        (& oh-my-posh init pwsh --config $themeConfig) | Invoke-Expression
    } else {
        (& oh-my-posh init powershell --config $themeConfig) | Invoke-Expression
    }
}

# Theme & Suggestion Utilities
function Set-SuggestionStyle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("Inline", "List", "InlineView", "ListView")]
        [string]$Style
    )
    if (-not $Style) {
        Write-Host "Usage: Set-SuggestionStyle -Style (Inline or List)" -ForegroundColor Yellow
        Write-Host "  - Inline: Dim ghost text following cursor" -ForegroundColor Cyan
        Write-Host "  - List:   Interactive dropdown menu below prompt" -ForegroundColor Cyan
        Write-Host "Tip: Press F2 while typing to toggle anytime!" -ForegroundColor Green
        return
    }
    $targetStyle = if ($Style -match "List") { "ListView" } else { "InlineView" }
    Set-PSReadLineOption -PredictionViewStyle $targetStyle
    Set-Content -Path "$HOME\.poshthemes\prediction_style.txt" -Value $targetStyle -Force
    Write-Host "Suggestion style set to: $targetStyle" -ForegroundColor Green
}

function Set-PoshTheme {
    [CmdletBinding()]
    param([string]$Name)
    $themes = Get-ChildItem "$HOME\.poshthemes\*.omp.json" -ErrorAction SilentlyContinue | ForEach-Object { $_.Name -replace '\.omp\.json$', '' }
    if (-not $Name) {
        Write-Host "Usage: Set-PoshTheme [theme-name]" -ForegroundColor Yellow
        Write-Host "Available themes: $($themes -join ', ')" -ForegroundColor Cyan
        return
    }
    $target = "$HOME\.poshthemes\$Name.omp.json"
    if (Test-Path $target) {
        Set-Content -Path "$HOME\.poshthemes\current_theme.txt" -Value $Name -Force
        Write-Host "Theme changed to '$Name'! Reloading profile..." -ForegroundColor Green
        . $PROFILE
    } else {
        Write-Host "Theme '$Name' not found." -ForegroundColor Red
        Write-Host "Available themes: $($themes -join ', ')" -ForegroundColor Yellow
    }
}

function Get-PoshThemes {
    Write-Host "Available Oh My Posh themes:" -ForegroundColor Cyan
    Get-ChildItem "$HOME\.poshthemes\*.omp.json" | Select-Object @{Name="Theme";Expression={$_.Name -replace '\.omp\.json$', ''}}
}

# Developer Aliases & Shortcuts
Set-Alias -Name g -Value git -Option AllScope -ErrorAction SilentlyContinue
function reload { . $PROFILE; Write-Host "Profile reloaded!" -ForegroundColor Green }
function ll { Get-ChildItem $args }
'@

$docPath = [System.Environment]::GetFolderPath('MyDocuments')
$winPsDir = Join-Path $docPath "WindowsPowerShell"
$pwshDir = Join-Path $docPath "PowerShell"
if (-not (Test-Path $winPsDir)) { New-Item -ItemType Directory -Path $winPsDir -Force | Out-Null }
if (-not (Test-Path $pwshDir)) { New-Item -ItemType Directory -Path $pwshDir -Force | Out-Null }

Set-Content -Path (Join-Path $winPsDir "Microsoft.PowerShell_profile.ps1") -Value $profileScript -Encoding utf8
Set-Content -Path (Join-Path $pwshDir "Microsoft.PowerShell_profile.ps1") -Value $profileScript -Encoding utf8

# Local Documents fallback
$localDocs = Join-Path $HOME "Documents"
if (Test-Path $localDocs) {
    $localWinPsDir = Join-Path $localDocs "WindowsPowerShell"
    $localPwshDir = Join-Path $localDocs "PowerShell"
    if (Test-Path $localWinPsDir) { Set-Content -Path (Join-Path $localWinPsDir "Microsoft.PowerShell_profile.ps1") -Value $profileScript -Encoding utf8 }
    if (Test-Path $localPwshDir) { Set-Content -Path (Join-Path $localPwshDir "Microsoft.PowerShell_profile.ps1") -Value $profileScript -Encoding utf8 }
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host " [+] TERMINAL ENVIRONMENT SETUP COMPLETED!" -ForegroundColor Green
Write-Host " Please open a new Windows Terminal tab to enjoy." -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green
