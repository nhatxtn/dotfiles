# ====================================================================
# ONE-CLICK MODERN TERMINAL SETUP SCRIPT FOR WINDOWS
# (Oh My Posh + Meslo Nerd Font + PowerShell 7 + Smart Autocomplete)
# ====================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " 🚀 BẮT ĐẦU THIẾT LẬP TERMINAL CHO CODING (OH MY POSH)" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Cài đặt Oh My Posh qua winget
Write-Host "`n[1/7] Kiểm tra và cài đặt Oh My Posh..." -ForegroundColor Cyan
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host "Đang cài đặt Oh My Posh qua winget..." -ForegroundColor Yellow
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Host "✓ Oh My Posh đã được cài đặt." -ForegroundColor Green
}

# 2. Cài đặt Meslo Nerd Font
Write-Host "`n[2/7] Kiểm tra và cài đặt Meslo Nerd Font..." -ForegroundColor Cyan
try {
    oh-my-posh font install Meslo
    Write-Host "✓ Meslo Nerd Font đã được cài đặt." -ForegroundColor Green
} catch {
    Write-Host "Bỏ qua bước font hoặc đã có sẵn." -ForegroundColor Yellow
}

# 3. Cài đặt PowerShell 7 (nếu đang chạy trên Windows PowerShell cũ)
Write-Host "`n[3/7] Kiểm tra PowerShell 7..." -ForegroundColor Cyan
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    Write-Host "Đang cài đặt PowerShell 7 qua winget..." -ForegroundColor Yellow
    winget install Microsoft.PowerShell -s winget --accept-source-agreements --accept-package-agreements
} else {
    Write-Host "✓ PowerShell 7 đã sẵn sàng." -ForegroundColor Green
}

# 4. Cài đặt các PowerShell Modules cần thiết
Write-Host "`n[4/7] Cài đặt các module hỗ trợ (Terminal-Icons, posh-git, PSReadLine)..." -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction SilentlyContinue

$modules = @("Terminal-Icons", "posh-git", "PSReadLine")
if ($PSVersionTable.PSEdition -eq "Core") {
    $modules += "CompletionPredictor"
}

foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "Đang cài module: $mod..." -ForegroundColor Yellow
        Install-Module -Name $mod -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction SilentlyContinue
    } else {
        Write-Host "✓ Module $mod đã có sẵn." -ForegroundColor Green
    }
}

# 5. Tải bộ theme Oh My Posh phổ biến
Write-Host "`n[5/7] Tải các theme Oh My Posh đẹp vào ~/.poshthemes..." -ForegroundColor Cyan
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
Write-Host "✓ Đã tải xong bộ theme." -ForegroundColor Green

# 6. Cấu hình Windows Terminal & VS Code dùng MesloLGM Nerd Font
Write-Host "`n[6/7] Áp dụng font MesloLGM Nerd Font cho Windows Terminal & VS Code..." -ForegroundColor Cyan
# Windows Terminal
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $wtSettings) {
    try {
        $content = Get-Content $wtSettings -Raw
        if ($content -notmatch '"face":\s*"MesloLGM Nerd Font"') {
            $content = $content -replace '"defaults":\s*\{', '"defaults": { "font": { "face": "MesloLGM Nerd Font", "size": 11 }'
            Set-Content -Path $wtSettings -Value $content -Encoding utf8
            Write-Host "✓ Đã cập nhật font cho Windows Terminal." -ForegroundColor Green
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
            Write-Host "✓ Đã cập nhật font cho VS Code Terminal." -ForegroundColor Green
        }
    } catch {}
}

# 7. Tạo file Profile PowerShell hoàn chỉnh
Write-Host "`n[7/7] Cài đặt file cấu hình PowerShell Profile..." -ForegroundColor Cyan
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

# Posh-Git (Gợi ý lệnh Git, branch, flags)
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
    } catch {}

    Set-PSReadLineOption -Colors @{
        InlinePrediction = "$([char]0x1b)[38;5;246m"
    } -ErrorAction SilentlyContinue

    # Phím tắt
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Chord "Ctrl+Spacebar" -Function MenuComplete -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardChar -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key "Ctrl+RightArrow" -Function AcceptNextSuggestionWord -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Chord "Ctrl+f" -Function AcceptSuggestion -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key F2 -Function SwitchPredictionView -ErrorAction SilentlyContinue
}

# Oh My Posh
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

# Tiện ích đổi giao diện
function Set-SuggestionStyle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("Inline", "List", "InlineView", "ListView")]
        [string]$Style
    )
    if (-not $Style) {
        Write-Host "Cú pháp: Set-SuggestionStyle -Style <Inline | List>" -ForegroundColor Yellow
        Write-Host "  - Inline: Dòng chữ mờ tiếp sau con trỏ" -ForegroundColor Cyan
        Write-Host "  - List:   Menu danh sách lịch sử lệnh bên dưới" -ForegroundColor Cyan
        Write-Host "Mẹo: Bạn có thể bấm phím F2 khi đang gõ để đổi qua lại tức thì!" -ForegroundColor Green
        return
    }
    $targetStyle = if ($Style -match "List") { "ListView" } else { "InlineView" }
    Set-PSReadLineOption -PredictionViewStyle $targetStyle
    Set-Content -Path "$HOME\.poshthemes\prediction_style.txt" -Value $targetStyle -Force
    Write-Host "Đã chuyển kiểu gợi ý thành: $targetStyle" -ForegroundColor Green
}

function Set-PoshTheme {
    [CmdletBinding()]
    param([string]$Name)
    $themes = Get-ChildItem "$HOME\.poshthemes\*.omp.json" -ErrorAction SilentlyContinue | ForEach-Object { $_.Name -replace '\.omp\.json$', '' }
    if (-not $Name) {
        Write-Host "Cú pháp: Set-PoshTheme <tên-theme>" -ForegroundColor Yellow
        Write-Host "Các theme có sẵn: $($themes -join ', ')" -ForegroundColor Cyan
        return
    }
    $target = "$HOME\.poshthemes\$Name.omp.json"
    if (Test-Path $target) {
        Set-Content -Path "$HOME\.poshthemes\current_theme.txt" -Value $Name -Force
        Write-Host "Đã chọn theme '$Name'! Đang tải lại..." -ForegroundColor Green
        . $PROFILE
    } else {
        Write-Host "Không tìm thấy theme '$Name'." -ForegroundColor Red
        Write-Host "Các theme có sẵn: $($themes -join ', ')" -ForegroundColor Yellow
    }
}

function Get-PoshThemes {
    Write-Host "Danh sách theme Oh My Posh:" -ForegroundColor Cyan
    Get-ChildItem "$HOME\.poshthemes\*.omp.json" | Select-Object @{Name="Tên Theme";Expression={$_.Name -replace '\.omp\.json$', ''}}
}

# Phím tắt
Set-Alias -Name g -Value git -Option AllScope -ErrorAction SilentlyContinue
function reload { . $PROFILE; Write-Host "Đã tải lại profile!" -ForegroundColor Green }
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

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host " 🎉 HOÀN TẤT THIẾT LẬP MÔI TRƯỜNG TERMINAL!" -ForegroundColor Green
Write-Host " Hãy mở một tab Windows Terminal mới để trải nghiệm." -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green
