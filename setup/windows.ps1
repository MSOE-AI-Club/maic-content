<#
MSOE AI Club (MAIC) member setup for Windows 10 and 11.

Paste this one line into PowerShell (not as Administrator):
  irm https://msoe-ai-club.github.io/maic-content/setup/windows.ps1 | iex

Installs and configures: GlobalProtect VPN, Git, an SSH key, the Rosie SSH config,
passwordless Rosie login, Jernel on Rosie, the GitHub SSH key, uv, Python 3.12,
a ~\maic environment with the data-science packages, VS Code, and its extensions.
It assumes a brand-new laptop. Anything already installed is skipped. Safe to run again.
At the start it asks if you have a Rosie account, then shows a menu: pick what to set up.

Options (set before the paste line):
  $env:MAIC_SETUP_CHECK = 1   only report what is installed, change nothing
  $env:MAIC_SETUP_YES = 1     no prompts and no menu (runs every part); skips the steps
                              that need a person (VPN install, Rosie password, GitHub browser)
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
    RosieHelp     = 'https://msoe-maic.com/library/?nav=Articles&article=1-getting-rosie-access'
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
    NotPicked      = $false
    RosieKey       = ''      # the key Rosie gets: from an existing Rosie entry, else $Cfg.Key
    RosieAccess    = ''      # yes or no, from the question at the start
    Status         = @{}     # part -> done, todo, or unknown
    Info           = @{}     # part -> short note for the menu
    Selected       = @{}     # part -> $true when picked
    StepN          = 0
    StepTotal      = 0
    StepLabel      = ''
    LiveOn         = $false  # a live line is on the screen
    InStep         = $false
    Detail         = ''      # short text for the result line of the running step
    SkipReason     = ''
    AddedNote      = ''
    # Spinners and menus need a real console. CI and pipes get plain lines.
    Tty            = $false
}
try { $State.Tty = -not [Console]::IsOutputRedirected -and -not [Console]::IsInputRedirected } catch { }


# ---------- output ----------
# Windows Terminal draws these symbols. The old console font may not, so it gets plain ones.
$Fancy = [bool]$env:WT_SESSION
if ($Fancy) {
    $G = @{ Ok = [string][char]0x2713; No = [string][char]0x2717; Skip = [string][char]0x2013; Dot = [string][char]0x00B7
            Ptr = [string][char]0x203A; Bar = [string][char]0x2501; BarOff = [string][char]0x2501; Sep = [string][char]0x00B7
            Keys = [string][char]0x2191 + [string][char]0x2193 }
    $SpinFrames = @(0x280B, 0x2819, 0x2839, 0x2838, 0x283C, 0x2834, 0x2826, 0x2827, 0x2807, 0x280F) | ForEach-Object { [string][char]$_ }
} else {
    $G = @{ Ok = '+'; No = 'x'; Skip = '-'; Dot = '.'; Ptr = '>'; Bar = '='; BarOff = '-'; Sep = '-'; Keys = 'Up/Down' }
    $SpinFrames = @('|', '/', '-', '\')
}

function Clear-Live {
    if (-not $State.LiveOn) { return }
    try { [Console]::Write("`r" + (' ' * [Math]::Max(20, [Console]::WindowWidth - 1)) + "`r") } catch { }
    $State.LiveOn = $false
}
function Say($msg)  { Clear-Live; Write-Host ''; Write-Host "  $msg" -ForegroundColor White; Write-Host '' }
function Ok($msg) {
    # Inside a step, Ok sets the short detail shown on the step's result line.
    if ($State.InStep) { if (-not $State.Detail) { $State.Detail = "$msg" }; return }
    Clear-Live
    Write-Host "  $($G.Ok) " -NoNewline -ForegroundColor Cyan
    Write-Host $msg
}
function Set-Detail($msg) { $State.Detail = "$msg" }
function Warn($msg) { Clear-Live; Write-Host '    ! ' -NoNewline -ForegroundColor Yellow; Write-Host $msg }
function Fail($msg) { Clear-Live; Write-Host "    $($G.No) " -NoNewline -ForegroundColor Red; Write-Host $msg }
function Note($msg) { Clear-Live; Write-Host "    $msg" }
function Dim($msg)  { Clear-Live; Write-Host "    $msg" -ForegroundColor DarkGray }
function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Short-Path($path) { return ("$path" -replace [regex]::Escape($HOME), '~') }

function Read-Line($prompt) {
    # Inside a step the prompt sits under the step; elsewhere at the left edge.
    Clear-Live
    $indent = if ($State.InStep) { '    ' } else { '  ' }
    # Read-Host adds ": " itself, so drop a colon at the end of the prompt.
    return "$(Read-Host "$indent$($prompt.TrimEnd(':'))")"
}
function Ask($question, $default = '') {
    if ($State.Yes) { return $default }
    $answer = (Read-Line $question).Trim()
    if ($answer) { return $answer } else { return $default }
}
function Confirm-Step($question) {
    if ($State.Yes) { return $true }
    return -not ((Read-Line "$question [Y/n]") -match '^[nN]')
}
function Pause-Step($msg) {
    if ($State.Yes) { return }
    Read-Line $msg | Out-Null
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
    Write-Host '  MSOE AI Club' -NoNewline -ForegroundColor Cyan
    Write-Host " $($G.Sep) " -NoNewline -ForegroundColor DarkGray
    Write-Host 'Member setup for Windows' -ForegroundColor Magenta
    Write-Host ''
}


# ---------- ROSIE banner ----------
# The letters use box characters. They are made from char codes here, because
# `irm | iex` in Windows PowerShell 5.1 can read the script with the wrong encoding.
$RosieLetters = @(
    '######]  ######] #######]##]#######]',
    '##[==##]##[===##]##[====}##|##[====}',
    '######[}##|   ##|#######]##|#####]  ',
    '##[==##]##|   ##|{====##|##|##[==}  ',
    '##|  ##|{######[}#######|##|#######]',
    '{=}  {=} {=====} {======}{=}{======}'
)
$RosieRose = @('.-""-.', '/ @ @  \', '( @(@)@  )', '\_@_@_/', '__\ | /__', '\__\|/__/')
$RosiePad = @('    ', '   ', '  ', '   ', '  ', '  ')
$BoxMap = [ordered]@{ '#' = [char]0x2588; ']' = [char]0x2557; '[' = [char]0x2554; '}' = [char]0x255D; '{' = [char]0x255A; '=' = [char]0x2550; '|' = [char]0x2551 }

function Show-Rosie {
    Write-Host ''
    for ($i = 0; $i -lt $RosieLetters.Count; $i++) {
        $line = $RosieLetters[$i]
        foreach ($k in $BoxMap.Keys) { $line = $line.Replace($k, [string]$BoxMap[$k]) }
        Write-Host "  $line" -NoNewline -ForegroundColor White
        $color = if ($i -lt 4) { 'Red' } else { 'Green' }
        Write-Host ($RosiePad[$i] + $RosieRose[$i]) -ForegroundColor $color
    }
    Write-Host ''
}

function Format-Elapsed($start) {
    $t = [int]((Get-Date) - $start).TotalSeconds
    if ($t -ge 60) { return ('{0}m {1:00}s' -f [Math]::Floor($t / 60), ($t % 60)) }
    return "${t}s"
}

function Write-Live($frame, $what) {
    # The live line of the running step: spinner, step, overall bar, count, and
    # what is happening. [Console]::Write goes to the screen only, not the log.
    if (-not $State.Tty -or $State.StepTotal -lt 1) { return }
    try {
        $width = [Math]::Max(60, [Console]::WindowWidth - 1)
        $fill = [int][Math]::Floor(($State.StepN - 1) * 16 / $State.StepTotal)
        [Console]::Write("`r  ")
        [Console]::ForegroundColor = 'Cyan'; [Console]::Write("$frame ")
        [Console]::ResetColor(); [Console]::Write($State.StepLabel.PadRight(20) + ' ')
        [Console]::ForegroundColor = 'Cyan'; [Console]::Write($G.Bar * $fill)
        [Console]::ForegroundColor = 'DarkGray'; [Console]::Write($G.BarOff * (16 - $fill))
        $room = $width - 41
        $tail = " $($State.StepN)/$($State.StepTotal)  $what"
        if ($tail.Length -gt $room) { $tail = $tail.Substring(0, $room) }
        [Console]::Write($tail.PadRight($room))
        [Console]::ResetColor()
        $State.LiveOn = $true
    } catch { }
}

function Wait-ProcessSpin($what, $proc) {
    # A spinner on the live line until the process ends. Returns its exit code.
    $null = $proc.Handle   # keeps ExitCode readable after the process ends
    $start = Get-Date; $i = 0
    try {
        while (-not $proc.HasExited) {
            Write-Live $SpinFrames[$i % $SpinFrames.Count] "$what $($G.Sep) $(Format-Elapsed $start)"
            $i++; Start-Sleep -Milliseconds 120
        }
    } catch { $proc.WaitForExit() }
    Write-Live $G.Dot ''
    try { return $proc.ExitCode } catch { return 0 }
}

function Invoke-Spin($what, [scriptblock]$body, $argList = @()) {
    # Runs $body in a background job with a spinner. $body must end with an exit
    # code (for example $LASTEXITCODE). Returns $true when the code is 0.
    $start = Get-Date; $i = 0
    $job = Start-Job -ScriptBlock $body -ArgumentList $argList
    while ($job.State -eq 'Running' -or $job.State -eq 'NotStarted') {
        Write-Live $SpinFrames[$i % $SpinFrames.Count] "$what $($G.Sep) $(Format-Elapsed $start)"
        $i++; Start-Sleep -Milliseconds 120
    }
    Write-Live $G.Dot ''
    $out = @(Receive-Job $job 2>&1)
    Remove-Job $job -Force
    $code = $out | Where-Object { $_ -is [int] } | Select-Object -Last 1
    if ($null -eq $code) { $code = if ($job.State -eq 'Completed') { 0 } else { 1 } }
    if ($code -ne 0) {
        Fail "Failed while $what. Last lines:"
        $out | Where-Object { $_ -isnot [int] } | Select-Object -Last 6 | ForEach-Object { Dim "  $_" }
        return $false
    }
    return $true
}

function Invoke-Quiet($what, $exe, [string[]]$argList, $dir = $PWD.Path) {
    # Runs a program with its output in temp files and a spinner on the live line.
    $o = Join-Path $env:TEMP "maic-setup-$([guid]::NewGuid().ToString('N')).out"
    $e = "$o.err"
    $p = Start-Process -FilePath $exe -ArgumentList $argList -WorkingDirectory $dir -NoNewWindow -PassThru `
        -RedirectStandardOutput $o -RedirectStandardError $e
    $code = Wait-ProcessSpin $what $p
    if ($code -ne 0) {
        Fail "Failed while $what. Last lines:"
        @(Get-Content $o, $e -ErrorAction SilentlyContinue) | Select-Object -Last 6 | ForEach-Object { Dim "  $_" }
    }
    Remove-Item $o, $e -Force -ErrorAction SilentlyContinue
    return ($code -eq 0)
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

function Write-Result($glyph, $glyphColor, $label, $text, $textColor) {
    Write-Host "  $glyph " -NoNewline -ForegroundColor $glyphColor
    Write-Host ("$label".PadRight(20) + ' ') -NoNewline
    Write-Host $text -ForegroundColor $textColor
}

function Run-Step($label, [scriptblock]$body) {
    # While the step runs, one live line shows a spinner and the overall bar.
    # When it ends, that line becomes one result line, for example: Git  2.47.1
    $State.StepN++; $State.StepLabel = $label; $State.Detail = ''; $State.SkipReason = ''
    $State.InStep = $true
    Write-Live $G.Dot ''
    $result = $false
    try {
        $result = & $body |
            ForEach-Object { if ($_ -is [bool]) { $_ } else { Dim "$_" } } |
            Select-Object -Last 1
    } catch { Fail $_.Exception.Message }
    $State.InStep = $false
    Clear-Live
    if ($State.SkipReason) { Write-Result $G.Skip 'Yellow' $label $State.SkipReason 'Yellow' }
    elseif ($result) { Write-Result $G.Ok 'Cyan' $label $State.Detail 'DarkGray' }
    else {
        Write-Result $G.No 'Red' $label 'did not finish' 'Red'
        $State.Failed += $label
    }
}
function Skip-Step($label, $reason) {
    # The result line shows the reason.
    $State.SkipReason = "skipped: $reason"
    $State.Skipped += $(if ($State.StepLabel) { $State.StepLabel } else { $label })
}

function Install-Winget($id, $what, [switch]$UserScope) {
    if (-not (Have 'winget')) { return $false }
    $wingetArgs = @('install', '--exact', '--id', $id, '--silent', '--accept-package-agreements', '--accept-source-agreements')
    if ($UserScope) { $wingetArgs += @('--scope', 'user') }
    $p = Start-Process -FilePath 'winget' -WindowStyle Hidden -PassThru -ArgumentList $wingetArgs
    $code = Wait-ProcessSpin $what $p
    if ($code -ne 0) { Dim "winget exit code $code" }
    Update-SessionPath
    return $true
}

function Download($url, $dest, $what = 'downloading') {
    # Shows the percent on the live line. curl.exe comes with Windows 10 and 11.
    $total = 0
    try {
        $head = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -MaximumRedirection 10
        $total = [int64](@($head.Headers['Content-Length'])[0])
    } catch { }
    $curl = Join-Path $env:SystemRoot 'System32\curl.exe'
    if (Test-Path $curl) {
        $p = Start-Process -FilePath $curl -NoNewWindow -PassThru -ArgumentList '-fsSL', '-o', "`"$dest`"", "`"$url`""
        $null = $p.Handle
        $i = 0
        while (-not $p.HasExited) {
            $have = 0
            if (Test-Path $dest) { $have = (Get-Item $dest).Length }
            $pct = if ($total -gt 0) { " $([int]($have * 100 / $total))%" } else { '' }
            Write-Live $SpinFrames[$i % $SpinFrames.Count] "$what$pct $($G.Sep) $([int]($have / 1MB)) MB"
            $i++; Start-Sleep -Milliseconds 150
        }
        Write-Live $G.Dot ''
        if ($p.ExitCode -eq 0 -and (Test-Path $dest)) { return $true }
    }
    try {
        Write-Live $G.Dot $what
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        return $true
    } catch { return $false }
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
    & $State.Ssh -n -o BatchMode=yes -o ConnectTimeout=10 rosie true 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Test-GitHubLogin {
    if (-not $State.Ssh) { return $false }
    $out = & $State.Ssh -n -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1
    return ("$out" -match 'successfully authenticated')
}

function Get-RosieUser {
    # The user of an existing Host rosie block, without @ad.msoe.edu.
    $e = Get-RosieEntry
    if ($e -and $e.IsRosie) { return $e.User }
    return ''
}

function Select-Key {
    # Use a key the member already has (with its .pub), so no second key is made.
    foreach ($name in @('id_ed25519', 'id_ecdsa', 'id_rsa')) {
        $k = Join-Path $Cfg.SshDir $name
        if ((Test-Path $k) -and (Test-Path "$k.pub")) { $Cfg.Key = $k; return $true }
    }
    $Cfg.Key = Join-Path $Cfg.SshDir 'id_ed25519'
    return $false
}

function Get-RosieEntry {
    # An existing Rosie entry in ~\.ssh\config: a Host block named rosie, or any
    # block for dh-mgmt2.hpc.msoe.edu. Returns $null or @{Alias; User; Key; IsRosie}.
    if (-not (Test-Path $Cfg.SshConfig)) { return $null }
    $found = @(); $cur = $null
    foreach ($line in Get-Content $Cfg.SshConfig) {
        $parts = @($line.Trim() -split '\s+')
        if ($parts.Count -lt 2 -or $parts[0].StartsWith('#')) { continue }
        $word = $parts[0].ToLower()
        if ($word -eq 'host' -or $word -eq 'match') {
            if ($cur -and $cur.Match) { $found += $cur }
            $cur = $null
            if ($word -eq 'match') { continue }
            $names = @($parts[1..($parts.Count - 1)])
            $cur = @{ Alias = $names[0]; User = ''; Key = ''; IsRosie = $false; Match = $false }
            foreach ($n in $names) {
                if ($n -ieq 'rosie') { $cur.IsRosie = $true; $cur.Match = $true; $cur.Alias = $n }
                elseif ($n -ieq $Cfg.RosieHost) { $cur.Match = $true }
            }
            continue
        }
        if (-not $cur) { continue }
        if ($word -eq 'hostname' -and $parts[1] -ieq $Cfg.RosieHost) { $cur.Match = $true }
        if ($word -eq 'user' -and -not $cur.User) { $cur.User = ($parts[1] -replace '@.*$', '') }
        if ($word -eq 'identityfile' -and -not $cur.Key) { $cur.Key = $parts[1] }
    }
    if ($cur -and $cur.Match) { $found += $cur }
    if ($found.Count -eq 0) { return $null }
    $pick = @($found | Where-Object { $_.IsRosie }) + @($found) | Select-Object -First 1
    if ($pick.Key) {
        $k = $pick.Key -replace '^~[/\\]', ($HOME + '\')
        $pick.Key = if (Test-Path $k) { $k } else { '' }
    }
    return $pick
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
        Note 'If Windows asks "Do you want to allow this app to make changes", click Yes.'
        $done = Install-Winget 'Git.Git' 'installing'
        if (-not $done -or -not (Have 'git')) {
            # Per-user install, no admin needed.
            $tmp = Join-Path $env:TEMP 'maic-setup-git.exe'
            try {
                $release = Invoke-RestMethod 'https://api.github.com/repos/git-for-windows/git/releases/latest' -UseBasicParsing
                $asset = $release.assets | Where-Object { $_.name -match '^Git-.*-64-bit\.exe$' } | Select-Object -First 1
                if (-not $asset) { throw 'no 64-bit installer in the latest release' }
                if (-not (Download $asset.browser_download_url $tmp)) { return $false }
                $p = Start-Process -FilePath $tmp -ArgumentList '/VERYSILENT', '/NORESTART', '/CURRENTUSER', '/NOCANCEL' -PassThru
                Wait-ProcessSpin 'installing' $p | Out-Null
                Update-SessionPath
            } catch { Fail "Git install: $($_.Exception.Message)" }
        }
    }
    if (-not (Have 'git')) {
        Fail 'Install Git by hand: https://git-scm.com/download/win'
        return $false
    }
    Set-Detail ((git --version) -replace '^git version ', '' -replace '\.windows.*$', '')

    $name = git config --global user.name
    $email = git config --global user.email
    if (-not $name) {
        $name = Ask 'Your name:'
        if ($name) { git config --global user.name $name }
    }
    if (-not $email) {
        for ($i = 0; $i -lt 3 -and -not $email; $i++) {
            $answer = Ask 'Your email (the one on your GitHub account):'
            if (-not $answer) { break }
            if ($answer -match '^[^@\s]+@[^@\s]+$') { $email = $answer }
            else { Warn 'That is not an email address.' }
        }
        if ($email) { git config --global user.email $email }
    }
    if (-not ($name -and $email)) {
        Warn 'No name or email, so git cannot save commits yet. Run setup again to add them.'
    }
    $State.GitEmail = "$email"
    if (-not (git config --global init.defaultBranch)) { git config --global init.defaultBranch main }
    return $true
}

function Step-SshKey {
    if (-not (Find-Ssh)) {
        Fail 'No ssh.exe. Add it: Settings > System > Optional features > Add a feature > OpenSSH Client.'
        return $false
    }
    New-Item -ItemType Directory -Force -Path $Cfg.SshDir | Out-Null
    if (Select-Key) { Set-Detail "$(Short-Path $Cfg.Key) (already there)"; return $true }
    # No passphrase: ssh rosie and git push work with zero prompts.
    $comment = if ($State.GitEmail) { $State.GitEmail } else { "$env:USERNAME@maic" }
    # '""' passes an empty passphrase. Windows PowerShell drops a plain "".
    & $State.SshKeygen -t ed25519 -N '""' -C $comment -f $Cfg.Key -q
    if (-not (Test-Path $Cfg.Key)) { return $false }
    Set-Detail "made $(Short-Path $Cfg.Key)"
    return $true
}

function Install-RosieCommand {
    # A `rosie` command, so members type `rosie` instead of `ssh rosie`.
    # WindowsApps is on every user's PATH, and a .cmd file needs no script policy.
    $dir = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps'
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $cmd = Join-Path $dir 'rosie.cmd'
    [IO.File]::WriteAllText($cmd, "@echo off`r`nrem Added by the MAIC setup script: ""rosie"" means ""ssh rosie"".`r`nssh rosie %*`r`n")
}

function Step-RosieConfig {
    Select-Key | Out-Null
    $State.RosieKey = $Cfg.Key
    $entry = Get-RosieEntry
    if ($entry -and $entry.IsRosie -and $entry.User) {
        $State.RosieUser = $entry.User
        if ($entry.Key) { $State.RosieKey = $entry.Key }
        Set-Detail "user $($entry.User) (already there)"
        Install-RosieCommand
        return $true
    }
    $user = ''
    if ($entry -and $entry.User) {
        # An entry for dh-mgmt2 under another name: reuse its user and key.
        $user = $entry.User
        if ($entry.Key) { $State.RosieKey = $entry.Key }
    }
    for ($i = 0; $i -lt 3 -and -not $user; $i++) {
        $answer = Ask 'Your MSOE username (before @msoe.edu):' "$env:MAIC_SETUP_USER"
        if (-not $answer) { break }
        $answer = ($answer.ToLower() -replace '@.*$', '') -replace '\s', ''
        if ($answer -match '^[a-z0-9._-]+$') { $user = $answer }
        else { Warn 'Use only letters, numbers, dots, or dashes.' }
    }
    if (-not $user) {
        if ($State.Yes) { Skip-Step 'Rosie SSH config' 'no MSOE username'; return $true }
        return $false
    }
    $State.RosieUser = $user
    $keyPath = ($State.RosieKey -replace [regex]::Escape($HOME), '~') -replace '\\', '/'
    $block = @"

# Added by the MAIC setup script. Rosie is MSOE's supercomputer.
Host rosie ROSIE
    HostName $($Cfg.RosieHost)
    User $user@ad.msoe.edu
    IdentityFile $keyPath
    StrictHostKeyChecking accept-new

# Compute nodes, reached through the login node (for example: ssh dh-node1)
Host dh-node*
    HostName %h
    User $user@ad.msoe.edu
    IdentityFile $keyPath
    ProxyJump rosie
    StrictHostKeyChecking accept-new
"@ -replace "`r`n", "`n"
    $current = if (Test-Path $Cfg.SshConfig) { [IO.File]::ReadAllText($Cfg.SshConfig) } else { '' }
    if ($current -and -not $current.EndsWith("`n")) { $current += "`n" }
    Write-NoBom $Cfg.SshConfig ($current + $block)
    Set-Detail "user $user, added to ~\.ssh\config"
    Install-RosieCommand
    return $true
}

function Step-Vpn {
    # Rosie is only reachable from campus Wi-Fi or the GlobalProtect VPN.
    if (Test-Path $Cfg.GpExe) { Set-Detail 'installed'; return $true }
    if ($State.Yes) { Skip-Step 'GlobalProtect VPN' 'the install needs an admin click'; return $true }
    $msi = Join-Path $env:TEMP 'maic-setup-GlobalProtect.msi'
    if (-not (Download $Cfg.GpMsiUrl $msi)) {
        Fail "Download failed. Install by hand: https://$($Cfg.VpnPortal)/global-protect/getsoftwarepage.esp"
        return $false
    }
    Note 'Windows asks "Do you want to allow this app to make changes". Click Yes.'
    try {
        # PORTAL presets vpn.msoe.edu so the app opens ready to connect.
        $p = Start-Process -FilePath 'msiexec.exe' -Verb RunAs -PassThru -ArgumentList '/i', "`"$msi`"", "PORTAL=$($Cfg.VpnPortal)", '/qn', '/norestart'
        $code = Wait-ProcessSpin 'installing' $p
        if ($code -ne 0 -and $code -ne 3010) { Dim "msiexec exit code $code" }
    } catch { Fail "GlobalProtect install: $($_.Exception.Message)" }
    if (-not (Test-Path $Cfg.GpExe)) {
        Fail "Install by hand: https://$($Cfg.VpnPortal)/global-protect/getsoftwarepage.esp"
        return $false
    }
    Set-Detail 'installed'
    return $true
}

function Step-RosieConnect {
    Write-Live $G.Dot 'checking'
    if (Test-RosieReachable) { $State.RosieReachable = $true; Set-Detail 'reachable'; return $true }
    if ($State.Yes) { Skip-Step 'Rosie connection' 'not on campus or VPN'; return $true }
    if (-not (Test-Path $Cfg.GpExe)) { Warn 'GlobalProtect is not installed. Off campus, Rosie needs it.' }
    try { Start-Process -FilePath $Cfg.GpExe } catch { }
    Note "Off campus? Connect GlobalProtect (taskbar icon) to $($Cfg.VpnPortal)."
    for ($try = 1; $try -le 3; $try++) {
        Pause-Step 'Press Enter when GlobalProtect says Connected'
        Write-Live $G.Dot 'checking'
        if (Test-RosieReachable) { $State.RosieReachable = $true; Set-Detail 'reachable'; return $true }
        if ($try -lt 3) { Warn 'Rosie did not answer yet. Is GlobalProtect connected?' }
    }
    Skip-Step 'Rosie connection' 'Rosie did not answer'
    return $true
}

function Step-RosieKey {
    if (-not $State.RosieUser) { Skip-Step 'Rosie login' 'no MSOE username'; return $true }
    if (-not $State.RosieReachable) { Skip-Step 'Rosie login' 'Rosie is not reachable'; return $true }
    Write-Live $G.Dot 'checking'
    if (Test-RosieLogin) { Set-Detail 'no password needed'; return $true }
    if ($State.Yes) { Skip-Step 'Rosie login' 'needs your MSOE password'; return $true }
    Note 'Type your MSOE password one time (the letters stay hidden).'
    Note 'After this, Rosie lets you in with your key, no password.'
    $rk = if ($State.RosieKey) { $State.RosieKey } else { $Cfg.Key }
    $pub = (Get-Content "$rk.pub" -Raw).Trim()
    $b64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pub + "`n"))
    # Windows has no ssh-copy-id, so add the key over one password login. The key
    # goes in the command as base64: ssh keeps the keyboard for the password (no
    # stdin pipe), and Windows PowerShell 5.1 breaks double quotes in native
    # arguments, so the command has none.
    $remote = "umask 077; mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; echo $b64 | base64 -d > ~/.ssh/maic-key.tmp; " +
        "grep -qxFf ~/.ssh/maic-key.tmp ~/.ssh/authorized_keys || { sed -i -e '`$a\' ~/.ssh/authorized_keys; cat ~/.ssh/maic-key.tmp >> ~/.ssh/authorized_keys; }; " +
        "rm -f ~/.ssh/maic-key.tmp; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys"
    for ($try = 1; $try -le 3; $try++) {
        Clear-Live
        & $State.Ssh -o StrictHostKeyChecking=accept-new -o PreferredAuthentications=keyboard-interactive,password rosie $remote
        if (Test-RosieLogin) { Set-Detail 'no password needed from now on'; return $true }
        if ($try -lt 3) { Warn "That did not work. Check your password (user $($State.RosieUser))." }
    }
    Note 'Test it by hand: ssh rosie. If that fails too, your Rosie account is the problem: ask the eboard.'
    return $false
}

function Step-Jernel {
    if (-not $State.RosieReachable -or -not (Test-RosieLogin)) { Skip-Step 'Jernel on Rosie' 'Rosie login is not set up'; return $true }
    Write-Live $G.Dot 'checking'
    $bin = $Cfg.JernelBin
    # Same line as /data/ai_club/util/setup, added only once.
    # No double quotes: Windows PowerShell 5.1 breaks them in native arguments.
    $remote = "if grep -qsF '$bin' ~/.bashrc; then echo present; else printf '\nexport PATH=$bin/:`$PATH # MAIC tools (jernel). Added by the MAIC setup script.\n' >> ~/.bashrc && echo added; fi; test -x '$bin/jernel' && echo jernel-ok"
    $result = "$(& $State.Ssh -n -o BatchMode=yes rosie $remote 2>$null)"
    if ($result -match 'present') { Set-Detail 'on your PATH (already there)' }
    elseif ($result -match 'added') { Set-Detail 'added to your PATH on Rosie' }
    else { return $false }
    if ($result -notmatch 'jernel-ok') { Warn "$bin/jernel is missing on Rosie. Ask the eboard." }
    return $true
}

function Step-GitHub {
    Select-Key | Out-Null
    Write-Live $G.Dot 'checking'
    if (Test-GitHubLogin) { Set-Detail 'key accepted'; return $true }
    if ($State.Yes) { Skip-Step 'GitHub SSH key' 'needs a browser'; return $true }
    if (-not (Confirm-Step 'Do you have a GitHub account?')) {
        Note 'Make one in the browser page that opens (any email works).'
        Start-Process 'https://github.com/signup'
        Pause-Step 'Press Enter when you have an account'
    }
    $pub = (Get-Content "$($Cfg.Key).pub" -Raw).Trim()
    for ($try = 1; $try -le 3; $try++) {
        try { Set-Clipboard -Value $pub } catch { }
        Note 'Your key is copied. In the page that opens:'
        Note '  Title: MAIC laptop   Key: press Ctrl+V   then click "Add SSH key"'
        Start-Process 'https://github.com/settings/ssh/new'
        Pause-Step 'Press Enter after you click "Add SSH key"'
        Write-Live $G.Dot 'checking'
        if (Test-GitHubLogin) { Set-Detail 'key accepted'; return $true }
        if ($try -lt 3) { Warn 'GitHub does not accept the key yet.' }
    }
    Note 'Guide: https://msoe-maic.com/library/?nav=Articles&article=GitHub-SSH-Keys'
    return $false
}

function Step-Uv {
    if (-not (Have 'uv')) {
        Invoke-Spin 'installing uv' {
            param($url)
            powershell -NoProfile -ExecutionPolicy Bypass -Command "irm $url | iex"
            $LASTEXITCODE
        } @($Cfg.UvInstall) | Out-Null
        Update-SessionPath
        if (-not (Have 'uv')) { Fail 'Could not reach astral.sh. Check your internet connection.'; return $false }
    }
    $v = $Cfg.PythonVersion
    uv python find $v *> $null
    if (-not ($LASTEXITCODE -eq 0 -and (Get-PythonCommand))) {
        # --default also gives `python` and `python3` commands.
        Invoke-Spin "installing Python $v" {
            param($v)
            uv python install $v --default 2>&1
            if ($LASTEXITCODE -ne 0) { uv python install $v --default --preview 2>&1 }
            if ($LASTEXITCODE -ne 0) { uv python install $v 2>&1 }
            $code = $LASTEXITCODE
            uv python update-shell 2>&1 | Out-Null
            $code
        } @($v) | Out-Null
        Update-SessionPath
        uv python find $v *> $null
        if ($LASTEXITCODE -ne 0) { return $false }
        if (-not (Get-PythonCommand)) {
            Warn '"python" opens the Microsoft Store. Turn off its app execution aliases in'
            Note 'Settings > Apps > Advanced app settings > App execution aliases. ~\maic still works.'
        }
    }
    Set-Detail "$v, with uv $(((uv --version) -replace '^uv ', '') -replace ' .*$', '')"
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
        }
        $toml = Get-Content 'pyproject.toml' -Raw
        $missing = @($Cfg.Packages | Where-Object { $toml -notmatch ('"' + [regex]::Escape($_)) })
        if ($missing.Count -gt 0 -or -not (Test-EnvOk)) {
            # torch is a few hundred MB, so this is the longest wait.
            $uvExe = (Get-Command uv).Source
            if (-not (Invoke-Quiet 'downloading (torch is big)' $uvExe (@('add') + $Cfg.Packages) $Cfg.MaicDir)) { return $false }
            $py = Get-MaicPython
            if (-not $py) { return $false }
            & $py -c 'import torch, pandas, sklearn, matplotlib' *> $null
            if ($LASTEXITCODE -ne 0) { Fail 'The packages do not import. Run: cd ~\maic; uv sync'; return $false }
        }
        $kernel = Join-Path $env:APPDATA 'jupyter\kernels\maic\kernel.json'
        if (-not (Test-Path $kernel)) {
            $okKernel = Invoke-Spin 'adding the Jupyter kernel' {
                param($dir, $v)
                Set-Location $dir
                uv run python -m ipykernel install --user --name maic --display-name "MAIC (Python $v)" 2>&1
                $LASTEXITCODE
            } @($Cfg.MaicDir, $Cfg.PythonVersion)
            if (-not $okKernel) { return $false }
        }
        Set-Detail '~\maic, with torch, pandas, and Jupyter'
        return $true
    } finally { Pop-Location }
}

function Step-VsCode {
    if (-not (Find-Code)) {
        $done = Install-Winget 'Microsoft.VisualStudioCode' 'installing' -UserScope
        if (-not $done -or -not (Find-Code)) {
            $exe = Join-Path $env:TEMP 'maic-setup-VSCode.exe'
            if (-not (Download $Cfg.VsCodeUrl $exe)) {
                Fail 'Download failed. Install by hand: https://code.visualstudio.com/download'
                return $false
            }
            $p = Start-Process -FilePath $exe -ArgumentList '/VERYSILENT', '/NORESTART', '/MERGETASKS=!runcode,addtopath' -PassThru
            Wait-ProcessSpin 'installing' $p | Out-Null
            Update-SessionPath
        }
        if (-not (Find-Code)) { return $false }
    }
    Set-Detail "$(& $State.Code --version 2>$null | Select-Object -First 1), and the code command"
    return $true
}

function Step-Extensions {
    if (-not $State.Code -and -not (Find-Code)) { return $false }
    $installed = @(& $State.Code --list-extensions 2>$null | ForEach-Object { "$_".ToLower() })
    foreach ($ext in $Cfg.Extensions) {
        if ($installed -contains $ext) { continue }
        Invoke-Spin "installing $ext" {
            param($code, $ext)
            & $code --install-extension $ext --force 2>&1
            $LASTEXITCODE
        } @($State.Code, $ext) | Out-Null
        $installed = @(& $State.Code --list-extensions 2>$null | ForEach-Object { "$_".ToLower() })
        if ($installed -notcontains $ext) { Fail "In VS Code, open Extensions and install `"$ext`"."; return $false }
    }
    Set-Detail 'Remote SSH, Python, Jupyter'
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
            Warn 'settings.json has comments, so it was not changed.'
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
        Set-Detail 'Rosie timeout and the ~\maic Python'
    } else { Set-Detail 'already set' }
    return $true
}

# ---------- menu ----------
# Menu parts, in run order. Each part runs one or more steps.
$Parts = @('git', 'sshkey', 'vpn', 'rosie', 'github', 'python', 'env', 'vscode')
$PartLabel = @{
    git = 'Git'; sshkey = 'SSH key'; vpn = 'GlobalProtect VPN'; rosie = 'Rosie'; github = 'GitHub key'
    python = "Python $($Cfg.PythonVersion)"; env = 'ML packages (torch, pandas)'; vscode = 'VS Code'
}
$PartNeeds = @{ rosie = @('sshkey', 'vpn'); github = @('sshkey'); env = @('python') }
$PartSteps = @{
    git    = ,@('Git', { Step-Git })
    sshkey = ,@('SSH key', { Step-SshKey })
    vpn    = ,@('GlobalProtect', { Step-Vpn })
    rosie  = @(@('Rosie SSH config', { Step-RosieConfig }), @('Rosie connection', { Step-RosieConnect }),
               @('Rosie login', { Step-RosieKey }), @('Jernel on Rosie', { Step-Jernel }))
    github = ,@('GitHub key', { Step-GitHub })
    python = ,@('Python', { Step-Uv })
    env    = ,@('ML packages', { Step-Env })
    vscode = @(@('VS Code', { Step-VsCode }), @('VS Code extensions', { Step-Extensions }), @('VS Code settings', { Step-Settings }))
}

function Test-EnvOk {
    $py = Get-MaicPython
    if (-not $py) { return $false }
    & $py -c 'import torch, pandas, sklearn, matplotlib' *> $null
    return ($LASTEXITCODE -eq 0 -and (Test-Path (Join-Path $env:APPDATA 'jupyter\kernels\maic\kernel.json')))
}

function Test-VsCodeOk {
    if (-not (Find-Code)) { return $false }
    $installed = @(& $State.Code --list-extensions 2>$null | ForEach-Object { "$_".ToLower() })
    foreach ($ext in $Cfg.Extensions) { if ($installed -notcontains $ext) { return $false } }
    $path = Join-Path $env:APPDATA 'Code\User\settings.json'
    return ((Test-Path $path) -and ((Get-Content $path -Raw) -match 'remote\.SSH\.connectTimeout'))
}

function Write-Tick { if ($State.Tty) { try { [Console]::ForegroundColor = 'DarkGray'; [Console]::Write('.'); [Console]::ResetColor() } catch { } } }

function Get-AllStatus {
    # Each check prints one gray dot, so the member sees it is working.
    if ($State.Tty) { try { [Console]::ForegroundColor = 'DarkGray'; [Console]::Write('  Checking your laptop '); [Console]::ResetColor() } catch { } }
    foreach ($p in $Parts) { $State.Status[$p] = 'todo'; $State.Info[$p] = '' }
    Find-Ssh | Out-Null
    if ((Have 'git') -and (git config --global user.name) -and (git config --global user.email)) { $State.Status.git = 'done' }
    Write-Tick
    if (Select-Key) { $State.Status.sshkey = 'done' }
    Write-Tick
    if (Test-Path $Cfg.GpExe) { $State.Status.vpn = 'done' }
    $entry = Get-RosieEntry
    if ($entry -and $entry.IsRosie -and $entry.User) {
        $State.RosieUser = $entry.User
        if (-not (Test-RosieReachable)) { $State.Status.rosie = 'unknown'; $State.Info.rosie = 'cannot check: VPN off' }
        elseif (Test-RosieLogin) {
            $j = "$(& $State.Ssh -n -o BatchMode=yes rosie "grep -qsF '$($Cfg.JernelBin)' ~/.bashrc && echo ok" 2>$null)"
            if ($j -match 'ok') { $State.Status.rosie = 'done' }
        }
    }
    Write-Tick
    if (Test-GitHubLogin) { $State.Status.github = 'done' }
    if (Have 'uv') { uv python find $Cfg.PythonVersion *> $null; if ($LASTEXITCODE -eq 0) { $State.Status.python = 'done' } }
    Write-Tick
    if (Test-EnvOk) { $State.Status.env = 'done' }
    Write-Tick
    if (Test-VsCodeOk) { $State.Status.vscode = 'done' }
    if ($State.Tty) { try { [Console]::Write("`r" + (' ' * 40) + "`r") } catch { } }
}

function Set-DefaultSelection {
    foreach ($p in $Parts) { $State.Selected[$p] = ($State.Yes -or $State.Status[$p] -ne 'done') }
    if ($State.RosieAccess -eq 'no') {
        $State.Selected.rosie = $false
        if ($State.Status.vpn -ne 'done') { $State.Selected.vpn = $false }
    }
}

function Write-Pad($text, $color, $width) {
    # Write-Host with a fixed width, so a redraw covers the old text.
    if ($text.Length -gt $width) { $text = $text.Substring(0, $width) }
    Write-Host $text.PadRight($width) -NoNewline -ForegroundColor $color
}

function Show-Menu($cur) {
    for ($i = 0; $i -lt $Parts.Count; $i++) {
        $p = $Parts[$i]
        $sel = $State.Selected[$p]
        $statusColor = 'DarkGray'
        switch ($State.Status[$p]) {
            'done'    { if ($sel) { $status = 'done, will run again'; $statusColor = 'Yellow' } else { $status = 'done' } }
            'unknown' { $status = $State.Info[$p]; $statusColor = 'Yellow' }
            default   { $status = '' }
        }
        if ($p -eq 'rosie' -and $State.RosieAccess -eq 'no') { $status = 'needs a Rosie account'; $statusColor = 'DarkGray' }
        $here = ($i -eq $cur)
        Write-Host '  ' -NoNewline
        Write-Pad $(if ($here) { $G.Ptr } else { ' ' }) 'Magenta' 2
        Write-Pad $(if ($sel) { '[x]' } else { '[ ]' }) $(if ($sel) { 'Cyan' } else { 'DarkGray' }) 4
        Write-Pad $PartLabel[$p] $(if ($here) { 'White' } else { 'Gray' }) 31
        Write-Pad $status $statusColor 24
        Write-Host ''
    }
    Write-Host ''
    Write-Host "  $($G.Keys) move   space pick   enter start   q quit" -ForegroundColor DarkGray
}

function Select-Parts {
    # Arrow keys and Space. Returns $false when the member quits.
    # On Enter the menu is erased, so the screen shows only what happens next.
    Write-Host ''
    Write-Host '  Pick what to set up' -ForegroundColor White
    Write-Host ''
    $headTop = [Console]::CursorTop - 3
    $cur = 0
    $lines = $Parts.Count + 2
    Show-Menu $cur
    $top = [Console]::CursorTop - $lines
    try { [Console]::CursorVisible = $false } catch { }
    try {
        while ($true) {
            $k = [Console]::ReadKey($true)
            switch ($k.Key) {
                'UpArrow'   { $cur = ($cur + $Parts.Count - 1) % $Parts.Count }
                'DownArrow' { $cur = ($cur + 1) % $Parts.Count }
                'K'         { $cur = ($cur + $Parts.Count - 1) % $Parts.Count }
                'J'         { $cur = ($cur + 1) % $Parts.Count }
                'Spacebar'  { $p = $Parts[$cur]; $State.Selected[$p] = -not $State.Selected[$p] }
                'A'         { foreach ($p in $Parts) { $State.Selected[$p] = $true } }
                'N'         { foreach ($p in $Parts) { $State.Selected[$p] = $false } }
                'Q'         { return $false }
                'Escape'    { return $false }
                'Enter'     {
                    # Erase the header and the menu, then put the cursor back at the top.
                    $headTop = [Math]::Max(0, $headTop)
                    $width = [Math]::Max(40, [Console]::WindowWidth - 1)
                    [Console]::SetCursorPosition(0, $headTop)
                    for ($r = 0; $r -lt $lines + 3; $r++) { [Console]::Write((' ' * $width) + "`n") }
                    [Console]::SetCursorPosition(0, $headTop)
                    return $true
                }
            }
            [Console]::SetCursorPosition(0, [Math]::Max(0, $top))
            Show-Menu $cur
            $top = [Console]::CursorTop - $lines
            $headTop = $top - 3
        }
    } finally { try { [Console]::CursorVisible = $true } catch { } }
}

function Add-NeededParts {
    # A picked part also picks the parts it needs that are not done yet.
    $State.AddedNote = ''
    foreach ($p in $Parts) {
        if (-not $State.Selected[$p] -or -not $PartNeeds.ContainsKey($p)) { continue }
        foreach ($dep in $PartNeeds[$p]) {
            if (-not $State.Selected[$dep] -and $State.Status[$dep] -ne 'done') {
                $State.Selected[$dep] = $true
                $State.AddedNote += " Added $($PartLabel[$dep]) ($($PartLabel[$p]) needs it)."
            }
        }
    }
}

# ---------- report (MAIC_SETUP_CHECK) ----------
function Get-Need($part) {
    # Required in check mode or when picked; else 'skip'.
    if ($State.Check -or $State.Selected[$part]) { return $true }
    return 'skip'
}

function Report-Row($label, $value, $required) {
    if ($value) { Write-Result $G.Ok 'Cyan' $label $value 'DarkGray' }
    elseif ($required -is [string] -and $required -eq 'skip') { Write-Result $G.Dot 'DarkGray' $label 'not picked' 'DarkGray' }
    elseif ($required -eq $true) { Write-Result $G.No 'Red' $label 'missing' 'Red'; $State.Missing = $true }
    else { Write-Result $G.Skip 'Yellow' $label 'not done' 'Yellow'; $State.NotDone = $true }
}

function Show-Report {
    $State.Missing = $false; $State.NotDone = $false
    Update-SessionPath
    Find-Ssh | Out-Null
    Say 'What you have'
    Report-Row 'GlobalProtect' $(if (Test-Path $Cfg.GpExe) { 'installed' }) (Get-Need 'vpn')
    Report-Row 'Git' $(if (Have 'git') { (git --version) -replace '^git version ', '' -replace '\.windows.*$', '' }) (Get-Need 'git')
    Select-Key | Out-Null
    Report-Row 'SSH key' $(if ($State.Ssh -and (Test-Path $Cfg.Key)) { Short-Path $Cfg.Key }) (Get-Need 'sshkey')
    $ruser = Get-RosieUser
    Report-Row 'Rosie config' $(if ($ruser) { "user $ruser" }) (Get-Need 'rosie')
    if (-not $ruser) {
        Report-Row 'Rosie login' '' $false
        Report-Row 'Jernel' '' $false
    } elseif (Test-RosieReachable) {
        Report-Row 'Rosie login' $(if (Test-RosieLogin) { 'no password needed' }) $false
        $j = "$(& $State.Ssh -n -o BatchMode=yes rosie "grep -qsF '$($Cfg.JernelBin)' ~/.bashrc && echo ok" 2>$null)"
        Report-Row 'Jernel' $(if ($j -match 'ok') { 'on your PATH' }) $false
    } else {
        Report-Row 'Rosie login' '' $false
        Report-Row 'Jernel' '' $false
        Dim '  Rosie did not answer, so these were not tested. Connect GlobalProtect first.'
    }
    Report-Row 'GitHub key' $(if (Test-GitHubLogin) { 'accepted' }) $false
    $pyOk = ''
    if (Have 'uv') {
        uv python find $Cfg.PythonVersion *> $null
        if ($LASTEXITCODE -eq 0) { $pyOk = "uv $(((uv --version) -replace '^uv ', '') -replace ' .*$', '')" }
    }
    Report-Row "Python $($Cfg.PythonVersion)" $pyOk (Get-Need 'python')
    $py = Get-MaicPython
    $envOk = ''
    if ($py) { $envOk = "$(& $py -c 'import torch, pandas; print(''torch'', torch.__version__.split(''+'')[0])' 2>$null)" }
    Report-Row '~\maic packages' $envOk (Get-Need 'env')
    Report-Row 'Jupyter kernel' $(if (Test-Path (Join-Path $env:APPDATA 'jupyter\kernels\maic\kernel.json')) { 'MAIC' }) (Get-Need 'env')
    Report-Row 'VS Code' $(if (Find-Code) { "$(& $State.Code --version 2>$null | Select-Object -First 1)" }) (Get-Need 'vscode')
    Report-Row 'VS Code extensions' $(if (Test-VsCodeOk) { 'Remote SSH, Python, Jupyter' }) (Get-Need 'vscode')
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
                Write-Host '  Some tools are missing.' -NoNewline -ForegroundColor Red
                Write-Host ' To install them, paste:'
                Write-Host "  $($Cfg.PasteLine)"
                return
            }
            Write-Host '  Ready.' -ForegroundColor Cyan
            return
        }

        # 1. What is already done? Done parts start unselected in the menu.
        Get-AllStatus

        # 2. Rosie needs an account first. Ask before anything else.
        if ($State.Status.rosie -eq 'done' -or $State.Yes) { $State.RosieAccess = 'yes' }
        else {
            Show-Rosie
            Write-Host "  Rosie is MSOE's supercomputer. Setup can connect you to it,"
            Write-Host '  but you need a Rosie account first.'
            Write-Host ''
            $reply = Read-Line 'Do you have a Rosie account? [y/N]'
            if ($reply -match '^[yY]') { $State.RosieAccess = 'yes' }
            else {
                $State.RosieAccess = 'no'
                Write-Host ''
                Write-Host '  OK, Rosie is off for now.' -NoNewline -ForegroundColor Yellow
                Write-Host ' How to get an account:'
                Write-Host "  $($Cfg.RosieHelp)" -ForegroundColor DarkGray
            }
        }

        # 3. The menu.
        Set-DefaultSelection
        if (-not $State.Yes -and $State.Tty) {
            $go = $true
            try { $go = Select-Parts } catch { Warn 'The menu needs a console window. Using the default choice.' }
            if (-not $go) { Write-Host ''; Write-Host '  Nothing changed.'; return }
        }
        Add-NeededParts
        $steps = @()
        foreach ($p in $Parts) { if ($State.Selected[$p]) { $steps += $PartSteps[$p] } }
        if ($steps.Count -eq 0) { Write-Host ''; Write-Host '  Nothing picked. Nothing changed.'; return }

        # 4. Run the picked parts. Each step is one line; a live line shows progress.
        $State.StepTotal = $steps.Count
        $State.StepN = 0
        Say 'Setting up'
        if ($State.AddedNote) { Write-Host "  $($State.AddedNote.Trim())" -ForegroundColor DarkGray; Write-Host '' }
        foreach ($st in $steps) { Run-Step $st[0] $st[1] }

        # 5. One short ending.
        Write-Host ''
        if ($State.Failed.Count -gt 0) {
            Write-Host "  $($G.No) Not finished:" -NoNewline -ForegroundColor Red
            Write-Host " $($State.Failed -join ', ')"
            Write-Host '    Fix the problem above, then paste the setup line again. Done parts are skipped.'
        } elseif ($State.Skipped.Count -gt 0) {
            Write-Host "  $($G.Skip) Almost ready." -NoNewline -ForegroundColor Yellow
            Write-Host " Skipped: $($State.Skipped -join ', ')"
            Write-Host '    Connect GlobalProtect (or come to campus), then paste the setup line again.'
        } else {
            Write-Host "  $($G.Ok) Ready. Welcome to MAIC." -ForegroundColor Cyan
        }
        $next = @()
        if ($State.Selected.python -or $State.Selected.vscode) { $next += 'Open a new PowerShell window, so code, uv, and python work.' }
        $entry = Get-RosieEntry
        if ($entry -and $entry.IsRosie -and ($State.Selected.vscode -or $State.Selected.rosie)) {
            $next += 'To use Rosie in VS Code: click >< (bottom left), Connect to Host, rosie.'
        }
        if ($State.RosieAccess -eq 'no') { $next += 'For Rosie: get an account, then run setup again.' }
        if ($next.Count -gt 0) {
            Write-Host ''
            Write-Host '  Next' -ForegroundColor White
            foreach ($n in $next) { Write-Host "    $n" }
        }
        Write-Host ''
        Write-Host "  Log: $(Short-Path $Cfg.Log)" -ForegroundColor DarkGray
        Write-Host ''
    } finally {
        Clear-Live
        try { [Console]::CursorVisible = $true } catch { }
        # Remove every installer this script downloaded. Only ~\maic-setup.log stays.
        Get-ChildItem -Path $env:TEMP -Filter 'maic-setup-*' -File -ErrorAction SilentlyContinue |
            Remove-Item -Force -ErrorAction SilentlyContinue
        try { Stop-Transcript | Out-Null } catch { }
    }
}

Invoke-MaicSetup
