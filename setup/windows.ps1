<#
MSOE AI Club (MAIC) member setup for Windows 10 and 11.

Paste this one line into PowerShell (not as Administrator):
  irm https://msoe-ai-club.github.io/maic-content/setup/windows.ps1 | iex

Installs and configures: GlobalProtect VPN, Git, an SSH key, the Rosie SSH config,
passwordless Rosie login, Jernel on Rosie, the GitHub SSH key, uv, Python 3.12,
a ~\maic environment with the data-science packages, VS Code, and its extensions.
It assumes a brand-new laptop. Anything already installed is skipped. Safe to run again.

Options (set before the paste line):
  $env:MAIC_SETUP_CHECK = 1   only report what is installed, change nothing
  $env:MAIC_SETUP_YES = 1     no prompts; skips the steps that need a person
                              (VPN install, Rosie password, GitHub browser)
  $env:MAIC_SETUP_USER = name your MSOE username, so the script does not ask

Read it first: open the URL above in a browser. It is plain text.
No param() block: `irm | iex` drops it. No `exit`: it would close your window.
#>

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'   # the 5.1 progress bar makes downloads very slow
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072  # TLS 1.2

# ---------- settings ----------
$Cfg = @{
    PythonVersion = '3.12'
    MaicDir       = Join-Path $HOME 'maic'
    SshDir        = Join-Path $HOME '.ssh'
    Key           = Join-Path $HOME '.ssh\id_ed25519'
    SshConfig     = Join-Path $HOME '.ssh\config'
    RosieHost     = 'dh-mgmt2.hpc.msoe.edu'
    VpnPortal     = 'vpn.msoe.edu'
    GpExe         = 'C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPA.exe'
    UvInstall     = 'https://astral.sh/uv/install.ps1'
    JernelBin     = '/data/ai_club/util/bin'
    Packages      = @('jupyter', 'ipykernel', 'numpy', 'pandas', 'matplotlib', 'seaborn', 'scikit-learn', 'scipy', 'requests', 'tqdm', 'torch')
    Extensions    = @('ms-vscode-remote.remote-ssh', 'ms-python.python', 'ms-toolsai.jupyter')
    Article       = 'https://msoe-maic.com/library/?nav=Articles&article=005_MAIC_Setup'
    Log           = Join-Path $HOME 'maic-setup.log'
    PasteLine     = 'irm https://msoe-ai-club.github.io/maic-content/setup/windows.ps1 | iex'
}
$Arm = ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64')
$Cfg.GpMsiUrl   = if ($Arm) { "https://$($Cfg.VpnPortal)/global-protect/msi/GlobalProtectARM64.msi" } else { "https://$($Cfg.VpnPortal)/global-protect/msi/GlobalProtect64.msi" }
$Cfg.VsCodeUrl  = if ($Arm) { 'https://update.code.visualstudio.com/latest/win32-arm64-user/stable' } else { 'https://update.code.visualstudio.com/latest/win32-x64-user/stable' }

# Shared state. A hashtable, so functions can change it from any scope under `iex`.
$State = @{
    Check          = [bool]$env:MAIC_SETUP_CHECK
    Yes            = [bool]$env:MAIC_SETUP_YES
    Failed         = @()
    Skipped        = @()
    RosieReachable = $false
    RosieUser      = ''
    GitEmail       = ''
    Ssh            = ''      # path of ssh.exe in use
    SshKeygen      = ''
    SshFromGit     = $false  # true when Windows OpenSSH is missing and Git's ssh is used
    Code           = ''      # path of code.cmd
    Missing        = $false
    NotDone        = $false
}

# ---------- theme: MAIC blue -> cyan -> purple ----------
function Say($msg)  { Write-Host "==> $msg" -ForegroundColor Magenta }
function Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Cyan }
function Warn($msg) { Write-Host "  [!]  $msg" -ForegroundColor Yellow }
function Fail($msg) { Write-Host "  [X]  $msg" -ForegroundColor Red }
function Note($msg) { Write-Host "  $msg" }
function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

function Ask($question, $default = '') {
    if ($State.Yes) { return $default }
    $answer = "$(Read-Host "  $question")".Trim()
    if ($answer) { return $answer } else { return $default }
}
function Confirm-Step($question) {
    if ($State.Yes) { return $true }
    $reply = Read-Host "  $question [Y/n]"
    return -not ($reply -match '^[nN]')
}
function Pause-Step($msg) {
    if ($State.Yes) { return }
    Read-Host "  $msg Press Enter when done" | Out-Null
}

# The MAIC logo: a network-shaped brain. Columns go blue -> cyan -> purple.
$Logo = @'
            o-------------------O
          ./ \               _.-'  \.
       (@)    o------o----v-'       O
       / \   / \    /      \       /|
      O---o-'   \  /        o-----o |
       \   \     o'   M A I C   \   |
        \   |>   |               o--O
         O--+----+---o--------o-'   /
          '.|        |       /  \  /
            o--------o------o----O'
                               \ |
                                \|
                                 o
'@

function Show-Logo {
    try { Clear-Host } catch { }
    $colors = @('Blue', 'Blue', 'Cyan', 'Cyan', 'White', 'Magenta', 'Magenta', 'DarkMagenta', 'DarkMagenta')
    Write-Host ''
    foreach ($line in ($Logo -split "`r?`n")) {
        Write-Host '  ' -NoNewline
        for ($i = 0; $i -lt $line.Length; $i += 5) {
            $color = $colors[[Math]::Min([int][Math]::Floor($i / 5), $colors.Count - 1)]
            $len = [Math]::Min(5, $line.Length - $i)
            Write-Host $line.Substring($i, $len) -NoNewline -ForegroundColor $color
        }
        Write-Host ''
    }
    Write-Host ''
    Write-Host '   MSOE AI Club' -NoNewline -ForegroundColor Cyan
    Write-Host '  |  ' -NoNewline -ForegroundColor DarkGray
    Write-Host 'Member setup (Windows)' -ForegroundColor Magenta
    Write-Host ''
}

# ---------- helpers ----------
function Update-SessionPath {
    # Installers change the saved PATH in the registry. Put new saved folders
    # first so this window finds the new tools.
    $saved = @(
        [Environment]::GetEnvironmentVariable('Path', 'Machine'),
        [Environment]::GetEnvironmentVariable('Path', 'User')
    ) -join ';'
    $current = @($env:Path -split ';' | Where-Object { $_ })
    $new = @($saved -split ';' | Where-Object { $_ -and ($current -notcontains $_) })
    $env:Path = (@($new) + $current) -join ';'
}

function Run-Step($label, [scriptblock]$body) {
    Say $label
    $result = $false
    try {
        $result = & $body |
            ForEach-Object { if ($_ -is [bool]) { $_ } else { Write-Host "  $_" } } |
            Select-Object -Last 1
    } catch { Fail $_.Exception.Message }
    if (-not $result) {
        Fail "$label did not finish. See the messages above."
        $State.Failed += $label
    }
}
function Skip-Step($label, $reason) {
    Warn "$label skipped: $reason"
    $State.Skipped += $label
}

function Install-Winget($id, $label, [switch]$UserScope) {
    if (-not (Have 'winget')) { return $false }
    Note "Installing $label with winget."
    $wingetArgs = @('install', '--exact', '--id', $id, '--silent', '--accept-package-agreements', '--accept-source-agreements')
    if ($UserScope) { $wingetArgs += @('--scope', 'user') }
    # Start-Process gives winget the real console, so its progress bar works.
    $process = Start-Process -FilePath 'winget' -NoNewWindow -Wait -PassThru -ArgumentList $wingetArgs
    if ($process.ExitCode -ne 0) { Warn "winget exit code $($process.ExitCode)" }
    Update-SessionPath
    return $true
}

function Download($url, $dest, $label) {
    Note "Downloading $label."
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        return $true
    } catch {
        Fail "Could not download $url"
        return $false
    }
}

function Find-Ssh {
    # Windows OpenSSH first. Else the ssh that comes with Git for Windows.
    $win = Join-Path $env:SystemRoot 'System32\OpenSSH\ssh.exe'
    if (Test-Path $win) {
        $State.Ssh = $win; $State.SshKeygen = Join-Path $env:SystemRoot 'System32\OpenSSH\ssh-keygen.exe'; $State.SshFromGit = $false
        return $true
    }
    foreach ($root in @((Join-Path $env:ProgramFiles 'Git'), (Join-Path $env:LOCALAPPDATA 'Programs\Git'))) {
        $exe = Join-Path $root 'usr\bin\ssh.exe'
        if (Test-Path $exe) {
            $State.Ssh = $exe; $State.SshKeygen = Join-Path $root 'usr\bin\ssh-keygen.exe'; $State.SshFromGit = $true
            return $true
        }
    }
    return $false
}

function Test-Port($hostName, $port, $seconds = 5) {
    try {
        $client = New-Object Net.Sockets.TcpClient
        $async = $client.BeginConnect($hostName, $port, $null, $null)
        $ok = $async.AsyncWaitHandle.WaitOne($seconds * 1000, $false) -and $client.Connected
        $client.Close()
        return [bool]$ok
    } catch { return $false }
}
function Test-RosieReachable { return (Test-Port $Cfg.RosieHost 22 5) }

function Test-RosieLogin {
    if (-not $State.Ssh) { return $false }
    & $State.Ssh -o BatchMode=yes -o ConnectTimeout=10 rosie true 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Test-GitHubLogin {
    if (-not $State.Ssh) { return $false }
    $out = & $State.Ssh -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1
    return ("$out" -match 'successfully authenticated')
}

function Get-RosieUser {
    # The User from an existing Host rosie block, without @ad.msoe.edu.
    if (-not (Test-Path $Cfg.SshConfig)) { return '' }
    $inBlock = $false
    foreach ($line in Get-Content $Cfg.SshConfig) {
        $parts = $line.Trim() -split '\s+'
        if ($parts.Count -lt 2) { continue }
        if ($parts[0] -ieq 'Host') { $inBlock = @($parts[1..($parts.Count - 1)] | Where-Object { $_ -ieq 'rosie' }).Count -gt 0; continue }
        if ($inBlock -and $parts[0] -ieq 'User') { return ($parts[1] -replace '@.*$', '') }
    }
    return ''
}

function Find-Code {
    foreach ($candidate in @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'),
        (Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd'))) {
        if (Test-Path $candidate) { $State.Code = $candidate; return $true }
    }
    $cmd = Get-Command code.cmd -ErrorAction SilentlyContinue
    if ($cmd) { $State.Code = $cmd.Source; return $true }
    $State.Code = ''
    return $false
}

function Get-MaicPython {
    $py = Join-Path $Cfg.MaicDir '.venv\Scripts\python.exe'
    if (Test-Path $py) { return $py } else { return '' }
}

function Get-PythonCommand {
    # The Microsoft Store alias prints "Python was not found" and fails, so it does not count.
    if (-not (Have 'python')) { return '' }
    $out = python --version 2>&1
    if ($LASTEXITCODE -eq 0 -and "$out" -match '^Python 3') { return "$out".Trim() }
    return ''
}

function Write-NoBom($path, $text) {
    # Windows PowerShell 5.1 adds a byte order mark to UTF8 files. OpenSSH and JSON
    # readers do not like that.
    [IO.File]::WriteAllText($path, $text, (New-Object Text.UTF8Encoding $false))
}

# ---------- steps ----------

function Step-Git {
    if (-not (Have 'git')) {
        Note 'Windows may show "Do you want to allow this app to make changes". Click Yes.'
        $done = Install-Winget 'Git.Git' 'Git'
        if (-not $done -or -not (Have 'git')) {
            # Per-user install, no admin needed.
            $tmp = Join-Path $env:TEMP 'maic-setup-git.exe'
            try {
                $release = Invoke-RestMethod 'https://api.github.com/repos/git-for-windows/git/releases/latest' -UseBasicParsing
                $asset = $release.assets | Where-Object { $_.name -match '^Git-.*-64-bit\.exe$' } | Select-Object -First 1
                if (-not $asset) { throw 'no 64-bit installer in the latest release' }
                if (-not (Download $asset.browser_download_url $tmp 'Git for Windows')) { return $false }
                Start-Process -FilePath $tmp -ArgumentList '/VERYSILENT', '/NORESTART', '/CURRENTUSER', '/NOCANCEL' -Wait
                Update-SessionPath
            } catch { Fail "Git install: $($_.Exception.Message)" }
        }
    }
    if (-not (Have 'git')) {
        Note 'Install by hand: https://git-scm.com/download/win'
        return $false
    }
    Ok (git --version)

    $name = git config --global user.name
    $email = git config --global user.email
    if (-not $name) {
        $name = Ask 'Your name (for git commits):'
        if ($name) { git config --global user.name $name }
    }
    if (-not $email) {
        for ($i = 0; $i -lt 3 -and -not $email; $i++) {
            $answer = Ask 'Your email (for git commits, use the email on your GitHub account):'
            if (-not $answer) { break }
            if ($answer -match '^[^@\s]+@[^@\s]+$') { $email = $answer }
            else { Warn 'That is not an email address (example: name@example.com).' }
        }
        if ($email) { git config --global user.email $email }
    }
    if ($name -and $email) { Ok "git identity: $name <$email>" }
    else {
        Warn 'git identity is not set. Later run: git config --global user.name "Your Name"'
        Warn 'and: git config --global user.email "you@example.com"'
    }
    $State.GitEmail = "$email"
    if (-not (git config --global init.defaultBranch)) { git config --global init.defaultBranch main }
    return $true
}

function Step-SshKey {
    if (-not (Find-Ssh)) {
        Fail 'No ssh.exe found. Windows OpenSSH is missing and Git is not installed.'
        Note 'Settings > System > Optional features > Add a feature > OpenSSH Client.'
        return $false
    }
    if ($State.SshFromGit) { Warn 'Windows OpenSSH is missing. Using the ssh that comes with Git.' }
    New-Item -ItemType Directory -Force -Path $Cfg.SshDir | Out-Null
    if (Test-Path $Cfg.Key) { Ok "SSH key exists: $($Cfg.Key)"; return $true }
    # No passphrase: ssh rosie and git push work with zero prompts.
    $comment = if ($State.GitEmail) { $State.GitEmail } else { "$env:USERNAME@maic" }
    # '""' passes an empty passphrase. Windows PowerShell drops a plain "".
    & $State.SshKeygen -t ed25519 -N '""' -C $comment -f $Cfg.Key -q
    if (-not (Test-Path $Cfg.Key)) { return $false }
    Ok "Made SSH key $($Cfg.Key) (no passphrase)"
    return $true
}

function Install-RosieCommand {
    # A `rosie` command, so members type `rosie` instead of `ssh rosie`.
    # WindowsApps is on every user's PATH, and a .cmd file needs no script policy.
    $dir = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps'
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $cmd = Join-Path $dir 'rosie.cmd'
    [IO.File]::WriteAllText($cmd, "@echo off`r`nrem Added by the MAIC setup script: ""rosie"" means ""ssh rosie"".`r`nssh rosie %*`r`n")
    Ok 'Command "rosie" ready (same as "ssh rosie")'
}

function Step-RosieConfig {
    $existing = Get-RosieUser
    if ($existing) {
        $State.RosieUser = $existing
        Ok "~\.ssh\config already has Host rosie (user $existing). Not changed."
        Install-RosieCommand
        return $true
    }
    $user = ''
    for ($i = 0; $i -lt 3 -and -not $user; $i++) {
        $answer = Ask 'Your MSOE username (the part before @msoe.edu):' "$env:MAIC_SETUP_USER"
        if (-not $answer) { break }
        $answer = ($answer.ToLower() -replace '@.*$', '') -replace '\s', ''
        if ($answer -match '^[a-z0-9._-]+$') { $user = $answer }
        else { Warn 'Use only letters, numbers, dots, or dashes.' }
    }
    if (-not $user) {
        if ($State.Yes) { Warn 'No MSOE username (MAIC_SETUP_YES). Rosie config not written.'; return $true }
        return $false
    }
    $State.RosieUser = $user
    $block = @"

# Added by the MAIC setup script. Rosie is MSOE's supercomputer.
Host rosie ROSIE
    HostName $($Cfg.RosieHost)
    User $user@ad.msoe.edu
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking accept-new

# Compute nodes, reached through the login node (for example: ssh dh-node1)
Host dh-node*
    HostName %h
    User $user@ad.msoe.edu
    IdentityFile ~/.ssh/id_ed25519
    ProxyJump rosie
    StrictHostKeyChecking accept-new
"@ -replace "`r`n", "`n"
    $current = if (Test-Path $Cfg.SshConfig) { [IO.File]::ReadAllText($Cfg.SshConfig) } else { '' }
    if ($current -and -not $current.EndsWith("`n")) { $current += "`n" }
    Write-NoBom $Cfg.SshConfig ($current + $block)
    Ok "Wrote Host rosie to ~\.ssh\config (user $user@ad.msoe.edu)"
    Install-RosieCommand
    return $true
}

function Step-Vpn {
    # Rosie is only reachable from campus Wi-Fi or the GlobalProtect VPN.
    if (Test-Path $Cfg.GpExe) {
        Ok 'GlobalProtect is installed'
    } else {
        if ($State.Yes) { Skip-Step 'GlobalProtect VPN' 'install needs an admin click (MAIC_SETUP_YES is set)'; return $true }
        $msi = Join-Path $env:TEMP 'maic-setup-GlobalProtect.msi'
        if (-not (Download $Cfg.GpMsiUrl $msi 'GlobalProtect (about 65 MB)')) {
            Note "Install by hand: https://$($Cfg.VpnPortal)/global-protect/getsoftwarepage.esp"
            return $false
        }
        Note 'Installing. Windows asks "Do you want to allow this app to make changes". Click Yes.'
        try {
            # PORTAL presets vpn.msoe.edu so the app opens ready to connect.
            $p = Start-Process -FilePath 'msiexec.exe' -Verb RunAs -Wait -PassThru -ArgumentList '/i', "`"$msi`"", "PORTAL=$($Cfg.VpnPortal)", '/qn', '/norestart'
            if ($p.ExitCode -ne 0 -and $p.ExitCode -ne 3010) { Warn "msiexec exit code $($p.ExitCode)" }
        } catch { Fail "GlobalProtect install: $($_.Exception.Message)" }
        if (-not (Test-Path $Cfg.GpExe)) {
            Note "Install by hand: https://$($Cfg.VpnPortal)/global-protect/getsoftwarepage.esp"
            return $false
        }
        Ok 'GlobalProtect installed'
    }

    if (Test-RosieReachable) { $State.RosieReachable = $true; Ok 'Rosie is reachable (campus network or VPN is on)'; return $true }
    if ($State.Yes) { Skip-Step 'Rosie connection' 'not on campus or VPN (MAIC_SETUP_YES is set)'; return $true }
    try { Start-Process -FilePath $Cfg.GpExe } catch { }
    for ($try = 1; $try -le 3; $try++) {
        Note "In the GlobalProtect window (taskbar icon), connect to $($Cfg.VpnPortal) with your MSOE login."
        Pause-Step 'Connect now.'
        if (Test-RosieReachable) { $State.RosieReachable = $true; Ok 'Rosie is reachable'; return $true }
        Warn "Rosie did not answer (try $try of 3). Is GlobalProtect connected?"
    }
    Skip-Step 'Rosie connection' 'Rosie is not reachable. Connect GlobalProtect, then paste the setup line again.'
    return $true
}

function Step-RosieKey {
    if (-not $State.RosieUser) { Skip-Step 'Rosie login' 'no MSOE username'; return $true }
    if (-not $State.RosieReachable) { Skip-Step 'Rosie login' 'Rosie is not reachable'; return $true }
    if (Test-RosieLogin) { Ok 'Rosie accepts your SSH key. No password needed.'; return $true }
    if ($State.Yes) { Skip-Step 'Rosie login' 'needs your MSOE password (MAIC_SETUP_YES is set)'; return $true }
    Note 'Type your MSOE password ONE time to copy the key to Rosie (nothing shows while typing).'
    $pub = (Get-Content "$($Cfg.Key).pub" -Raw).Trim()
    # Windows has no ssh-copy-id. Append the key once, over one password login.
    $remote = 'read -r k; mkdir -p ~/.ssh && chmod 700 ~/.ssh && touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys; grep -qsF "$k" ~/.ssh/authorized_keys || echo "$k" >> ~/.ssh/authorized_keys'
    for ($try = 1; $try -le 3; $try++) {
        $pub | & $State.Ssh -o StrictHostKeyChecking=accept-new rosie $remote
        if (Test-RosieLogin) { Ok 'Rosie accepts your SSH key. No password needed from now on.'; return $true }
        Warn "That did not work (try $try of 3). Check the password and the username $($State.RosieUser)."
    }
    return $false
}

function Step-Jernel {
    if (-not $State.RosieReachable -or -not (Test-RosieLogin)) { Skip-Step 'Jernel on Rosie' 'Rosie login is not set up'; return $true }
    $bin = $Cfg.JernelBin
    # Same line as /data/ai_club/util/setup, added only once.
    $remote = "if grep -qsF '$bin' ~/.bashrc; then echo present; else printf '\nexport PATH=\`"$bin/:`$PATH\`" # MAIC tools (jernel). Added by the MAIC setup script.\n' >> ~/.bashrc && echo added; fi; test -x '$bin/jernel' && echo jernel-ok"
    $result = "$(& $State.Ssh -o BatchMode=yes rosie $remote 2>$null)"
    if ($result -match 'present') { Ok 'Jernel PATH line already in ~/.bashrc on Rosie' }
    elseif ($result -match 'added') { Ok 'Added the Jernel PATH line to ~/.bashrc on Rosie' }
    else { return $false }
    if ($result -notmatch 'jernel-ok') { Warn "$bin/jernel was not found on Rosie. Ask an eboard member." }
    return $true
}

function Step-GitHub {
    if (Test-GitHubLogin) { Ok 'GitHub accepts your SSH key'; return $true }
    if ($State.Yes) { Skip-Step 'GitHub SSH key' 'needs a browser (MAIC_SETUP_YES is set)'; return $true }
    if (-not (Confirm-Step 'Do you have a GitHub account?')) {
        Note 'Make one with any email, then come back here.'
        Start-Process 'https://github.com/signup'
        Pause-Step 'Finish the sign-up.'
    }
    $pub = (Get-Content "$($Cfg.Key).pub" -Raw).Trim()
    for ($try = 1; $try -le 3; $try++) {
        try { Set-Clipboard -Value $pub; Note 'Your public key is on the clipboard.' } catch { }
        Note 'In the browser page that opens: Title = "MAIC laptop", Key = paste (Ctrl+V), click "Add SSH key".'
        Note 'If the clipboard is empty, copy this line:'
        Write-Host ''; Write-Host "  $pub"; Write-Host ''
        Start-Process 'https://github.com/settings/ssh/new'
        Pause-Step 'Add the key on GitHub.'
        if (Test-GitHubLogin) { Ok 'GitHub accepts your SSH key'; return $true }
        Warn "GitHub did not accept the key yet (try $try of 3)."
    }
    Note 'Guide: https://msoe-maic.com/library/?nav=Articles&article=GitHub-SSH-Keys'
    return $false
}

function Step-Uv {
    if (-not (Have 'uv')) {
        Note 'Installing uv (Python package manager).'
        powershell -NoProfile -ExecutionPolicy Bypass -Command "irm $($Cfg.UvInstall) | iex" | Out-Null
        Update-SessionPath
        if (-not (Have 'uv')) { Fail "Could not install uv from $($Cfg.UvInstall) (offline, or the network blocks astral.sh)."; return $false }
    }
    Ok "uv $((uv --version) -replace '^uv ', '')"
    $v = $Cfg.PythonVersion
    uv python find $v *> $null
    if ($LASTEXITCODE -eq 0 -and (Get-PythonCommand)) { Ok "Python $v is installed"; return $true }
    Note "Installing Python $v."
    # --default also gives `python` and `python3` commands.
    uv python install $v --default *> $null
    if ($LASTEXITCODE -ne 0) { uv python install $v --default --preview *> $null }
    if ($LASTEXITCODE -ne 0) { uv python install $v *> $null }
    uv python update-shell *> $null
    Update-SessionPath
    uv python find $v *> $null
    if ($LASTEXITCODE -ne 0) { return $false }
    if (-not (Get-PythonCommand)) {
        Warn '"python" opens the Microsoft Store. Turn off the python.exe and python3.exe app execution aliases'
        Warn 'in Settings > Apps > Advanced app settings > App execution aliases. The ~\maic environment still works.'
    }
    Ok "Python $v installed"
    return $true
}

function Step-Env {
    if (-not (Have 'uv')) { return $false }
    New-Item -ItemType Directory -Force -Path $Cfg.MaicDir | Out-Null
    Push-Location $Cfg.MaicDir
    try {
        if (-not (Test-Path 'pyproject.toml')) {
            uv init --bare --name maic --python $Cfg.PythonVersion *> $null
            if ($LASTEXITCODE -ne 0) { return $false }
            Ok "Made $($Cfg.MaicDir)\pyproject.toml"
        }
        Note "Installing $($Cfg.Packages -join ' ')"
        Note 'torch is the big one (a few hundred MB). This can take a few minutes.'
        uv add @($Cfg.Packages) 2>&1 | Where-Object { "$_" -notmatch '^(Resolved|Prepared|Installed|Audited| \+|Using)' } | ForEach-Object { "$_" }
        $py = Get-MaicPython
        if (-not $py) { return $false }
        & $py -c 'import torch, pandas, sklearn, matplotlib' *> $null
        if ($LASTEXITCODE -ne 0) { Fail 'Packages did not import. Run: cd ~\maic; uv sync'; return $false }
        Ok "~\maic environment is ready ($(& $py --version))"
        $kernel = Join-Path $env:APPDATA 'jupyter\kernels\maic\kernel.json'
        if (-not (Test-Path $kernel)) {
            uv run python -m ipykernel install --user --name maic --display-name "MAIC (Python $($Cfg.PythonVersion))" *> $null
            if ($LASTEXITCODE -ne 0) { return $false }
        }
        Ok 'Jupyter kernel "MAIC (Python 3.12)" is registered'
        return $true
    } finally { Pop-Location }
}

function Step-VsCode {
    if (Find-Code) {
        Ok "VS Code is installed ($(Split-Path (Split-Path $State.Code)))"
        return $true
    }
    $done = Install-Winget 'Microsoft.VisualStudioCode' 'VS Code' -UserScope
    if (-not $done -or -not (Find-Code)) {
        $exe = Join-Path $env:TEMP 'maic-setup-VSCode.exe'
        if (-not (Download $Cfg.VsCodeUrl $exe 'VS Code (about 100 MB)')) {
            Note 'Install by hand: https://code.visualstudio.com/download'
            return $false
        }
        Start-Process -FilePath $exe -ArgumentList '/VERYSILENT', '/NORESTART', '/MERGETASKS=!runcode,addtopath' -Wait
        Update-SessionPath
    }
    if (-not (Find-Code)) { return $false }
    Ok "VS Code installed ($(Split-Path (Split-Path $State.Code)))"
    return $true
}

function Step-Extensions {
    if (-not $State.Code -and -not (Find-Code)) { return $false }
    $installed = @(& $State.Code --list-extensions 2>$null | ForEach-Object { "$_".ToLower() })
    foreach ($ext in $Cfg.Extensions) {
        if ($installed -contains $ext) { Ok "$ext already installed"; continue }
        & $State.Code --install-extension $ext --force *> $null
        $installed = @(& $State.Code --list-extensions 2>$null | ForEach-Object { "$_".ToLower() })
        if ($installed -contains $ext) { Ok "Installed $ext" }
        else { Fail "Could not install $ext. In VS Code: Extensions view, search `"$ext`"."; return $false }
    }
    return $true
}

function Step-Settings {
    # Only add keys that are absent. Never change what a member already set.
    $path = Join-Path $env:APPDATA 'Code\User\settings.json'
    New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
    $wanted = [ordered]@{ 'remote.SSH.connectTimeout' = 120 }
    $py = Get-MaicPython
    if ($py) { $wanted['python.defaultInterpreterPath'] = $py }
    if ($State.SshFromGit -and $State.Ssh) { $wanted['remote.SSH.path'] = $State.Ssh }
    $data = $null
    if ((Test-Path $path) -and (Get-Item $path).Length -gt 0) {
        try { $data = Get-Content $path -Raw | ConvertFrom-Json }
        catch {
            Warn 'settings.json has comments or is not valid JSON. Not changed.'
            Note 'Add by hand: "remote.SSH.connectTimeout": 120'
            return $true
        }
    }
    if ($null -eq $data) { $data = New-Object PSObject }
    $added = @()
    foreach ($k in $wanted.Keys) {
        if ($null -eq $data.PSObject.Properties[$k]) { $data | Add-Member -NotePropertyName $k -NotePropertyValue $wanted[$k]; $added += $k }
    }
    if ($added.Count -gt 0) {
        Write-NoBom $path (($data | ConvertTo-Json -Depth 30) + "`n")
        Ok "VS Code settings added: $($added -join ', ')"
    } else { Ok 'VS Code settings already set' }
    return $true
}

# ---------- report ----------
function Report-Row($label, $value, $required) {
    if ($value) {
        Write-Host ("  [OK] {0,-18} {1}" -f $label, $value) -ForegroundColor Cyan
    } elseif ($required) {
        Write-Host ("  [X]  {0,-18} missing" -f $label) -ForegroundColor Red
        $State.Missing = $true
    } else {
        Write-Host ("  [-]  {0,-18} not done" -f $label) -ForegroundColor Yellow
        $State.NotDone = $true
    }
}

function Show-Report {
    $State.Missing = $false; $State.NotDone = $false
    Update-SessionPath
    Find-Ssh | Out-Null
    Say 'What you have'
    Report-Row 'GlobalProtect' $(if (Test-Path $Cfg.GpExe) { 'installed' }) $true
    Report-Row 'Git' $(if (Have 'git') { (git --version) -replace 'git version ', '' }) $true
    Report-Row 'ssh' $(if ($State.Ssh) { if ($State.SshFromGit) { 'from Git' } else { 'Windows OpenSSH' } }) $true
    Report-Row 'SSH key' $(if (Test-Path $Cfg.Key) { $Cfg.Key }) $true
    $ruser = Get-RosieUser
    Report-Row 'Rosie config' $(if ($ruser) { "rosie -> $ruser@ad.msoe.edu" }) $true
    if (-not $ruser) {
        Report-Row 'Rosie login' '' $false
        Note '     (not tested: no Rosie config yet)'
        Report-Row 'Jernel' '' $false
    } elseif (Test-RosieReachable) {
        Report-Row 'Rosie login' $(if (Test-RosieLogin) { 'no password needed' }) $false
        $j = "$(& $State.Ssh -o BatchMode=yes rosie "grep -qsF '$($Cfg.JernelBin)' ~/.bashrc && echo ok" 2>$null)"
        Report-Row 'Jernel' $(if ($j -match 'ok') { 'ok' }) $false
    } else {
        Report-Row 'Rosie login' '' $false
        Note '     (not tested: Rosie is not reachable. Connect GlobalProtect first.)'
        Report-Row 'Jernel' '' $false
    }
    Report-Row 'GitHub login' $(if (Test-GitHubLogin) { 'key accepted' }) $false
    Report-Row 'uv' $(if (Have 'uv') { (uv --version) -replace '^uv ', '' }) $true
    $pyOk = ''
    if (Have 'uv') { uv python find $Cfg.PythonVersion *> $null; if ($LASTEXITCODE -eq 0) { $pyOk = 'installed' } }
    Report-Row "Python $($Cfg.PythonVersion)" $pyOk $true
    Report-Row 'python command' (Get-PythonCommand) $false
    $py = Get-MaicPython
    $envOk = ''
    if ($py) { $envOk = "$(& $py -c 'import torch, pandas; print("torch", torch.__version__, "pandas", pandas.__version__)' 2>$null)" }
    Report-Row '~\maic env' $envOk $true
    Report-Row 'MAIC kernel' $(if (Test-Path (Join-Path $env:APPDATA 'jupyter\kernels\maic\kernel.json')) { 'registered' }) $true
    Report-Row 'VS Code' $(if (Find-Code) { "$(& $State.Code --version 2>$null | Select-Object -First 1)" }) $true
    if ($State.Code) {
        $installed = @(& $State.Code --list-extensions 2>$null | ForEach-Object { "$_".ToLower() })
        $missing = @($Cfg.Extensions | Where-Object { $installed -notcontains $_ })
        Report-Row 'Extensions' $(if ($missing.Count -eq 0) { $Cfg.Extensions -join ' ' }) $true
        if ($missing.Count -gt 0) { Note "     missing: $($missing -join ' ')" }
    } else { Report-Row 'Extensions' '' $true }
    Note "Log: $($Cfg.Log)"
}

# ---------- main ----------
function Invoke-MaicSetup {
    try { Start-Transcript -Path $Cfg.Log -Append | Out-Null } catch { }
    try {
        Update-SessionPath
        Show-Logo

        if ($State.Check) {
            Show-Report
            Write-Host ''
            if ($State.Missing) {
                Fail 'Some required tools are missing. To install them, paste:'
                Note $Cfg.PasteLine
                return
            }
            if ($State.NotDone) { Warn 'Some optional steps are not done (see [-] above).' }
            Ok 'Ready.'
            return
        }

        $winVer = [Environment]::OSVersion.Version
        Say "MAIC member setup (Windows $($winVer.Major).$($winVer.Build), $env:PROCESSOR_ARCHITECTURE)"
        Note 'This installs: GlobalProtect VPN, Git, SSH key, Rosie SSH config, GitHub SSH key,'
        Note "uv, Python $($Cfg.PythonVersion), a ~\maic environment (pandas, torch, ...), VS Code and extensions."
        Note 'Tools you already have are skipped. It asks for: your name, email, MSOE username,'
        Note 'your MSOE password one time (for Rosie), a GitHub browser step, and one or two "allow changes" clicks.'
        Note "Estimated time: 10 to 25 minutes. Everything is logged to $($Cfg.Log)"
        if (-not (Confirm-Step 'Continue?')) { return }

        Run-Step 'Git'                 { Step-Git }
        Run-Step 'SSH key'             { Step-SshKey }
        Run-Step 'Rosie SSH config'    { Step-RosieConfig }
        Run-Step 'GlobalProtect VPN'   { Step-Vpn }
        Run-Step 'Rosie login'         { Step-RosieKey }
        Run-Step 'Jernel on Rosie'     { Step-Jernel }
        Run-Step 'GitHub SSH key'      { Step-GitHub }
        Run-Step 'uv and Python'       { Step-Uv }
        Run-Step '~\maic environment'  { Step-Env }
        Run-Step 'VS Code'             { Step-VsCode }
        Run-Step 'VS Code extensions'  { Step-Extensions }
        Run-Step 'VS Code settings'    { Step-Settings }

        Write-Host ''
        Show-Report
        Write-Host ''
        if ($State.Failed.Count -gt 0) {
            Fail ('Not ready. These steps did not finish: ' + ($State.Failed -join ', '))
            Note 'Fix the error (the article lists each tool), then paste the line again. Done steps are skipped:'
            Note $Cfg.PasteLine
            Note "Article: $($Cfg.Article)"
            return
        }
        if ($State.Skipped.Count -gt 0) {
            Warn ('Almost ready. Skipped: ' + ($State.Skipped -join ', '))
            Note 'Connect GlobalProtect (or come to campus), then paste the same line again to finish the Rosie steps:'
            Note $Cfg.PasteLine
        } else {
            Ok 'Ready. Welcome to MAIC.'
        }
        Note 'Open a NEW PowerShell window so the new commands (code, uv, python) are found.'
        Note 'In VS Code: click the blue >< icon bottom-left, "Connect to Host", choose rosie.'
    } finally {
        # Remove every installer this script downloaded. Only ~\maic-setup.log stays.
        Get-ChildItem -Path $env:TEMP -Filter 'maic-setup-*' -File -ErrorAction SilentlyContinue |
            Remove-Item -Force -ErrorAction SilentlyContinue
        try { Stop-Transcript | Out-Null } catch { }
    }
}

Invoke-MaicSetup
