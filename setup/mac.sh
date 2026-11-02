#!/usr/bin/env bash
# MSOE AI Club (MAIC) member setup for macOS.
#
# Paste this one line into Terminal:
#   bash -c "$(curl -fsSL https://msoe-ai-club.github.io/maic-content/setup/mac.sh)"
#
# Installs and configures: GlobalProtect VPN, Git, an SSH key, the Rosie SSH config,
# passwordless Rosie login, Jernel on Rosie, the GitHub SSH key, uv, Python 3.12,
# a ~/maic environment with the data-science packages, VS Code, and its extensions.
# It assumes a brand-new Mac. Anything already installed is skipped. Safe to run again.
#
# Options (set before the paste line):
#   MAIC_SETUP_CHECK=1   only report what is installed, change nothing
#   MAIC_SETUP_YES=1     no prompts; skips the steps that need a person
#                        (VPN install, Rosie password, GitHub browser)
#   MAIC_SETUP_USER=name your MSOE username, so the script does not ask
#
# Read it first: open the URL above in a browser. It is plain text.

# No `set -e`: a failed step is reported and the script continues.
# No `set -u`: macOS ships bash 3.2, where empty arrays trip it.
# shellcheck disable=SC2088  # "~/" appears only inside messages.

# ---------- settings ----------
PYTHON_VERSION='3.12'
MAIC_DIR="$HOME/maic"
KEY="$HOME/.ssh/id_ed25519"
SSH_CONFIG="$HOME/.ssh/config"
ROSIE_HOST='dh-mgmt2.hpc.msoe.edu'
VPN_PORTAL='vpn.msoe.edu'
GP_PKG_URL="https://$VPN_PORTAL/global-protect/msi/GlobalProtect.pkg"
GP_APP='/Applications/GlobalProtect.app'
GP_PREFS='/Library/Preferences/com.paloaltonetworks.GlobalProtect.settings.plist'
UV_INSTALL_URL='https://astral.sh/uv/install.sh'
VSCODE_URL='https://update.code.visualstudio.com/latest/darwin-universal/stable'
JERNEL_BIN='/data/ai_club/util/bin'
PACKAGES=(jupyter ipykernel numpy pandas matplotlib seaborn scikit-learn scipy requests tqdm torch)
EXTENSIONS=(ms-vscode-remote.remote-ssh ms-python.python ms-toolsai.jupyter)
ARTICLE='https://msoe-maic.com/library/?nav=Articles&article=005_MAIC_Setup'
LOG="$HOME/maic-setup.log"
PASTE_LINE='bash -c "$(curl -fsSL https://msoe-ai-club.github.io/maic-content/setup/mac.sh)"'

CHECK="${MAIC_SETUP_CHECK:-}"
YES="${MAIC_SETUP_YES:-}"

# ---------- colors: MAIC blue -> cyan -> purple ----------
IS_TTY=''
[ -t 1 ] && IS_TTY=1
if [ -n "$IS_TTY" ]; then
    C_BLUE=$'\e[38;5;33m'; C_CYAN=$'\e[38;5;51m'; C_WHITE=$'\e[38;5;255m'
    C_MAGENTA=$'\e[38;5;207m'; C_PURPLE=$'\e[38;5;135m'; C_GRAY=$'\e[38;5;245m'
    C_YELLOW=$'\e[38;5;220m'; C_RED=$'\e[38;5;203m'; C_RESET=$'\e[0m'
else
    C_BLUE=''; C_CYAN=''; C_WHITE=''; C_MAGENTA=''; C_PURPLE=''; C_GRAY=''
    C_YELLOW=''; C_RED=''; C_RESET=''
fi

say()  { printf '%s==> %s%s\n' "$C_PURPLE" "$*" "$C_RESET"; }
ok()   { printf '  %s[OK]%s %s\n' "$C_CYAN" "$C_RESET" "$*"; }
warn() { printf '  %s[!]%s  %s\n' "$C_YELLOW" "$C_RESET" "$*"; }
fail() { printf '  %s[X]%s  %s\n' "$C_RED" "$C_RESET" "$*"; }
note() { printf '  %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# Prompts read from the terminal, so both "bash -c" and "curl | bash" work.
ask() {
    # ask VAR "question" "default"
    local var=$1 question=$2 default=${3:-} answer=''
    if [ -n "$YES" ]; then printf -v "$var" '%s' "$default"; return 0; fi
    if [ -r /dev/tty ]; then
        printf '  %s ' "$question" > /dev/tty
        IFS= read -r answer < /dev/tty || answer=''
    fi
    [ -z "$answer" ] && answer=$default
    printf -v "$var" '%s' "$answer"
}
confirm() {
    # confirm "question" -> 0 for yes (default yes)
    local reply=''
    [ -n "$YES" ] && return 0
    ask reply "$1 [Y/n]"
    case "$reply" in n* | N*) return 1 ;; *) return 0 ;; esac
}
pause() {
    [ -n "$YES" ] && return 0
    local _x=''
    ask _x "$1 Press Enter when done."
}

# ---------- logo ----------
LOGO='            o-------------------O
          ./ \               _.-'"'"'  \.
       (@)    o------o----v-'"'"'       O
       / \   / \    /      \       /|
      O---o-'"'"'   \  /        o-----o |
       \   \     o'"'"'   M A I C   \   |
        \   |>   |               o--O
         O--+----+---o--------o-'"'"'   /
          '"'"'.|        |       /  \  /
            o--------o------o----O'"'"'
                               \ |
                                \|
                                 o'

show_logo() {
    local colors=("$C_BLUE" "$C_BLUE" "$C_CYAN" "$C_CYAN" "$C_WHITE" "$C_MAGENTA" "$C_MAGENTA" "$C_PURPLE" "$C_PURPLE")
    local line i chunk
    [ -n "$IS_TTY" ] && printf '\e[2J\e[H'
    printf '\n'
    while IFS= read -r line; do
        printf '  '
        for ((i = 0; i < ${#line}; i += 5)); do
            chunk=$i; ((chunk /= 5)); [ "$chunk" -gt 8 ] && chunk=8
            printf '%s%s' "${colors[$chunk]}" "${line:$i:5}"
        done
        printf '%s\n' "$C_RESET"
    done <<< "$LOGO"
    printf '\n   %sMSOE AI Club%s  %s|%s  %sMember setup (macOS)%s\n\n' \
        "$C_CYAN" "$C_RESET" "$C_GRAY" "$C_RESET" "$C_MAGENTA" "$C_RESET"
}

# ---------- step runner ----------
FAILED=()
SKIPPED=()
ROSIE_REACHABLE=''
ROSIE_USER=''
GIT_EMAIL=''
CODE_BIN=''

run_step() {
    # run_step "label" function
    local label=$1 fn=$2
    say "$label"
    if "$fn"; then return 0; fi
    fail "$label did not finish. See the messages above."
    FAILED+=("$label")
    return 0
}
skip_step() {
    # skip_step "label" "reason"
    warn "$1 skipped: $2"
    SKIPPED+=("$1")
}

path_now() {
    # Put ~/.local/bin on PATH for this run only.
    case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac
    export PATH
}

ensure_path() {
    # Put ~/.local/bin on PATH for this run and for new Terminal windows.
    path_now
    local line='export PATH="$HOME/.local/bin:$PATH"' rc
    for rc in "$HOME/.zprofile" "$HOME/.bash_profile"; do
        if ! grep -qsF '.local/bin' "$rc"; then
            printf '\n# Added by the MAIC setup script\n%s\n' "$line" >> "$rc"
        fi
    done
}

rosie_probe() {
    # 0 when dh-mgmt2 answers on port 22 within 5 seconds.
    nc -z -G 5 -w 5 "$ROSIE_HOST" 22 >/dev/null 2>&1
}

rosie_login_ok() {
    ssh -o BatchMode=yes -o ConnectTimeout=10 rosie true >/dev/null 2>&1
}

github_login_ok() {
    local out
    out=$(ssh -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1)
    [[ "$out" == *"successfully authenticated"* ]]
}

find_code() {
    local app
    for app in '/Applications/Visual Studio Code.app' "$HOME/Applications/Visual Studio Code.app"; do
        if [ -x "$app/Contents/Resources/app/bin/code" ]; then
            CODE_BIN="$app/Contents/Resources/app/bin/code"
            return 0
        fi
    done
    CODE_BIN=''
    return 1
}

python_bin() {
    # The Python inside ~/maic, else nothing.
    if [ -x "$MAIC_DIR/.venv/bin/python" ]; then printf '%s' "$MAIC_DIR/.venv/bin/python"; return 0; fi
    return 1
}

# ---------- steps ----------

step_git() {
    # Apple's Command Line Tools provide git. On a new Mac `git` is a stub that
    # opens the install dialog, so check xcode-select first to avoid two dialogs.
    if xcode-select -p >/dev/null 2>&1 && git --version >/dev/null 2>&1; then
        ok "$(git --version)"
    else
        if [ -n "$YES" ]; then
            fail 'Git is missing and MAIC_SETUP_YES is set, so the install dialog was not opened.'
            note 'Install by hand: xcode-select --install'
            return 1
        fi
        note "A macOS dialog opens. Click Install, then Agree. It takes 5 to 15 minutes."
        note 'This is the one step that may ask for your Mac password.'
        xcode-select --install >/dev/null 2>&1 || true
        local waited=0
        while ! xcode-select -p >/dev/null 2>&1; do
            sleep 10; waited=$((waited + 10))
            if [ "$waited" -ge 1200 ]; then
                fail 'Command Line Tools did not finish in 20 minutes.'
                note 'Finish the dialog, then paste the setup line again.'
                return 1
            fi
            if [ $((waited % 60)) -eq 0 ]; then note "Still waiting for the Command Line Tools install ($((waited / 60)) min)."; fi
        done
        git --version >/dev/null 2>&1 || return 1
        ok "$(git --version)"
    fi

    # git needs a name and email before it can save a commit.
    local name email
    name=$(git config --global user.name || true)
    email=$(git config --global user.email || true)
    if [ -z "$name" ]; then
        ask name 'Your name (for git commits):'
        [ -n "$name" ] && git config --global user.name "$name"
    fi
    if [ -z "$email" ]; then
        local tries=0
        while [ $tries -lt 3 ] && [ -z "$email" ]; do
            ask email 'Your email (for git commits, use the email on your GitHub account):'
            tries=$((tries + 1))
            if [[ ! "$email" =~ ^[^@[:space:]]+@[^@[:space:]]+$ ]]; then
                [ -n "$email" ] && warn 'That is not an email address (example: name@example.com).'
                email=''
            fi
        done
        [ -n "$email" ] && git config --global user.email "$email"
    fi
    if [ -n "$name" ] && [ -n "$email" ]; then
        ok "git identity: $name <$email>"
    else
        warn 'git identity is not set. Later run: git config --global user.name "Your Name"'
        warn 'and: git config --global user.email "you@example.com"'
    fi
    GIT_EMAIL=$email
    if [ -z "$(git config --global init.defaultBranch || true)" ]; then
        git config --global init.defaultBranch main
    fi
    return 0
}

step_ssh_key() {
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    if [ -f "$KEY" ]; then
        ok "SSH key exists: $KEY"
        return 0
    fi
    # No passphrase: ssh rosie and git push work with zero prompts.
    local comment="${GIT_EMAIL:-$USER@maic}"
    ssh-keygen -t ed25519 -N '' -C "$comment" -f "$KEY" -q || return 1
    ok "Made SSH key $KEY (no passphrase)"
    return 0
}

existing_rosie_user() {
    # The User line from an existing Host rosie block, without @ad.msoe.edu.
    [ -f "$SSH_CONFIG" ] || return 1
    awk '
        tolower($1)=="host" { inblock=0; for (i=2;i<=NF;i++) if (tolower($i)=="rosie") inblock=1 }
        inblock && tolower($1)=="user" { print $2; exit }
    ' "$SSH_CONFIG" | sed 's/@.*//'
}

install_rosie_cmd() {
    # A `rosie` command, so members type `rosie` instead of `ssh rosie`.
    # A script in ~/.local/bin works in every shell; no alias or rc edit needed.
    local cmd="$HOME/.local/bin/rosie"
    mkdir -p "$HOME/.local/bin"
    printf '#!/bin/sh\n# Added by the MAIC setup script: "rosie" means "ssh rosie".\nexec ssh rosie "$@"\n' > "$cmd"
    chmod +x "$cmd"
    ensure_path
    ok 'Command "rosie" ready (same as "ssh rosie")'
}

step_rosie_config() {
    local existing
    existing=$(existing_rosie_user || true)
    if [ -n "$existing" ]; then
        ROSIE_USER=$existing
        ok "~/.ssh/config already has Host rosie (user $ROSIE_USER). Not changed."
        install_rosie_cmd
        return 0
    fi
    local user='' tries=0
    while [ $tries -lt 3 ] && [ -z "$user" ]; do
        ask user 'Your MSOE username (the part before @msoe.edu):' "${MAIC_SETUP_USER:-}"
        tries=$((tries + 1))
        user=$(printf '%s' "$user" | tr '[:upper:]' '[:lower:]' | sed 's/@.*//; s/[[:space:]]//g')
        if [[ ! "$user" =~ ^[a-z0-9._-]+$ ]]; then
            [ -n "$user" ] && warn 'Use only letters, numbers, dots, or dashes.'
            user=''
        fi
    done
    if [ -z "$user" ]; then
        if [ -n "$YES" ]; then warn 'No MSOE username (MAIC_SETUP_YES). Rosie config not written.'; return 0; fi
        return 1
    fi
    ROSIE_USER=$user
    touch "$SSH_CONFIG" && chmod 600 "$SSH_CONFIG"
    # Keep the file tidy if it does not end with a newline.
    [ -s "$SSH_CONFIG" ] && [ "$(tail -c1 "$SSH_CONFIG" | wc -l)" -eq 0 ] && printf '\n' >> "$SSH_CONFIG"
    cat >> "$SSH_CONFIG" <<EOF

# Added by the MAIC setup script. Rosie is MSOE's supercomputer.
Host rosie ROSIE
    HostName $ROSIE_HOST
    User $ROSIE_USER@ad.msoe.edu
    IdentityFile $KEY
    StrictHostKeyChecking accept-new

# Compute nodes, reached through the login node (for example: ssh dh-node1)
Host dh-node*
    HostName %h
    User $ROSIE_USER@ad.msoe.edu
    IdentityFile $KEY
    ProxyJump rosie
    StrictHostKeyChecking accept-new
EOF
    ok "Wrote Host rosie to ~/.ssh/config (user $ROSIE_USER@ad.msoe.edu)"
    install_rosie_cmd
    return 0
}

step_vpn() {
    # Rosie is only reachable from campus Wi-Fi or the GlobalProtect VPN.
    if [ -d "$GP_APP" ]; then
        ok 'GlobalProtect is installed'
    else
        if [ -n "$YES" ]; then
            skip_step 'GlobalProtect VPN' 'install needs your Mac password (MAIC_SETUP_YES is set)'
            return 0
        fi
        note "Downloading GlobalProtect from $VPN_PORTAL (about 90 MB)."
        local tmp pkg
        tmp="$WORK/globalprotect"
        mkdir -p "$tmp" || return 1
        pkg="$tmp/GlobalProtect.pkg"
        if ! curl -fL --progress-bar -o "$pkg" "$GP_PKG_URL"; then
            fail "Could not download $GP_PKG_URL"
            note "Install by hand: https://$VPN_PORTAL/global-protect/getsoftwarepage.esp"
            return 1
        fi
        note 'Installing. macOS asks for your Mac password (nothing shows while typing).'
        # Preset the portal so the app opens ready to connect to vpn.msoe.edu.
        if [ ! -f "$GP_PREFS" ]; then
            cat > "$tmp/prefs.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Palo Alto Networks</key>
  <dict>
    <key>GlobalProtect</key>
    <dict>
      <key>PanSetup</key>
      <dict>
        <key>Portal</key>
        <string>$VPN_PORTAL</string>
        <key>Prelogon</key>
        <integer>0</integer>
      </dict>
    </dict>
  </dict>
</dict>
</plist>
EOF
            sudo cp "$tmp/prefs.plist" "$GP_PREFS" || warn 'Could not preset the portal. Type vpn.msoe.edu in the app.'
        fi
        if ! sudo installer -pkg "$pkg" -target / >/dev/null; then
            fail 'The GlobalProtect installer did not finish.'
            note "Install by hand: https://$VPN_PORTAL/global-protect/getsoftwarepage.esp"
            return 1
        fi
        ok 'GlobalProtect installed'
        note 'macOS may ask to allow a system extension or VPN configuration. Click Allow.'
    fi

    if rosie_probe; then
        ROSIE_REACHABLE=1
        ok 'Rosie is reachable (campus network or VPN is on)'
        return 0
    fi
    if [ -n "$YES" ]; then
        skip_step 'Rosie connection' 'not on campus or VPN (MAIC_SETUP_YES is set)'
        return 0
    fi
    open -a GlobalProtect >/dev/null 2>&1 || true
    local try
    for try in 1 2 3; do
        note "In the GlobalProtect window (menu bar icon), connect to $VPN_PORTAL with your MSOE login."
        pause 'Connect now.'
        if rosie_probe; then
            ROSIE_REACHABLE=1
            ok 'Rosie is reachable'
            return 0
        fi
        warn "Rosie did not answer (try $try of 3). Is GlobalProtect connected?"
    done
    skip_step 'Rosie connection' 'Rosie is not reachable. Connect GlobalProtect, then paste the setup line again.'
    return 0
}

step_rosie_key() {
    if [ -z "$ROSIE_USER" ]; then skip_step 'Rosie login' 'no MSOE username'; return 0; fi
    if [ -z "$ROSIE_REACHABLE" ]; then skip_step 'Rosie login' 'Rosie is not reachable'; return 0; fi
    if rosie_login_ok; then
        ok 'Rosie accepts your SSH key. No password needed.'
        return 0
    fi
    if [ -n "$YES" ]; then skip_step 'Rosie login' 'needs your MSOE password (MAIC_SETUP_YES is set)'; return 0; fi
    note 'Type your MSOE password ONE time to copy the key to Rosie (nothing shows while typing).'
    local try
    for try in 1 2 3; do
        if ssh-copy-id -i "$KEY.pub" rosie >/dev/null && rosie_login_ok; then
            ok 'Rosie accepts your SSH key. No password needed from now on.'
            return 0
        fi
        warn "That did not work (try $try of 3). Check the password and the username $ROSIE_USER."
    done
    note 'By hand later: ssh-copy-id rosie'
    return 1
}

step_jernel() {
    if [ -z "$ROSIE_REACHABLE" ] || ! rosie_login_ok; then
        skip_step 'Jernel on Rosie' 'Rosie login is not set up'
        return 0
    fi
    # Same line as /data/ai_club/util/setup, added only once.
    local result
    result=$(ssh -o BatchMode=yes rosie "
        if grep -qsF '$JERNEL_BIN' ~/.bashrc; then echo present
        else printf '\nexport PATH=\"$JERNEL_BIN/:\$PATH\" # MAIC tools (jernel). Added by the MAIC setup script.\n' >> ~/.bashrc && echo added
        fi
        test -x '$JERNEL_BIN/jernel' && echo jernel-ok" 2>/dev/null) || return 1
    case "$result" in
        *present*) ok 'Jernel PATH line already in ~/.bashrc on Rosie' ;;
        *added*) ok 'Added the Jernel PATH line to ~/.bashrc on Rosie' ;;
        *) return 1 ;;
    esac
    [[ "$result" == *jernel-ok* ]] || warn "$JERNEL_BIN/jernel was not found on Rosie. Ask an eboard member."
    return 0
}

step_github() {
    if github_login_ok; then
        ok 'GitHub accepts your SSH key'
        return 0
    fi
    if [ -n "$YES" ]; then skip_step 'GitHub SSH key' 'needs a browser (MAIC_SETUP_YES is set)'; return 0; fi
    if ! confirm 'Do you have a GitHub account?'; then
        note 'Make one with any email, then come back here.'
        open 'https://github.com/signup' >/dev/null 2>&1 || true
        pause 'Finish the sign-up.'
    fi
    local try
    for try in 1 2 3; do
        pbcopy < "$KEY.pub" 2>/dev/null && note 'Your public key is on the clipboard.'
        note 'In the browser page that opens: Title = "MAIC laptop", Key = paste (Cmd+V), click "Add SSH key".'
        note 'If the clipboard is empty, copy this line:'
        printf '\n%s\n\n' "$(cat "$KEY.pub")"
        open 'https://github.com/settings/ssh/new' >/dev/null 2>&1 || note 'Open https://github.com/settings/ssh/new'
        pause 'Add the key on GitHub.'
        if github_login_ok; then
            ok 'GitHub accepts your SSH key'
            return 0
        fi
        warn "GitHub did not accept the key yet (try $try of 3)."
    done
    note 'Guide: https://msoe-maic.com/library/?nav=Articles&article=GitHub-SSH-Keys'
    return 1
}

step_uv() {
    ensure_path
    if ! have uv; then
        note 'Installing uv (Python package manager).'
        curl -LsSf "$UV_INSTALL_URL" | sh >/dev/null 2>&1 || {
            fail "Could not install uv from $UV_INSTALL_URL (offline, or the network blocks astral.sh)."
            return 1
        }
        ensure_path
        have uv || return 1
    fi
    ok "uv $(uv --version | sed 's/^uv //')"

    # uv installs Python itself. On a Mac with no python3 command, --default also
    # gives `python` and `python3` commands in ~/.local/bin.
    if uv python find "$PYTHON_VERSION" >/dev/null 2>&1 && have python3; then
        ok "Python $PYTHON_VERSION is installed"
        return 0
    fi
    note "Installing Python $PYTHON_VERSION."
    if have python3; then
        uv python install "$PYTHON_VERSION" >/dev/null 2>&1 || return 1
    else
        uv python install "$PYTHON_VERSION" --default >/dev/null 2>&1 \
            || uv python install "$PYTHON_VERSION" --default --preview >/dev/null 2>&1 \
            || uv python install "$PYTHON_VERSION" >/dev/null 2>&1 || return 1
    fi
    uv python find "$PYTHON_VERSION" >/dev/null 2>&1 || return 1
    ok "Python $PYTHON_VERSION installed"
    return 0
}

step_env() {
    have uv || return 1
    mkdir -p "$MAIC_DIR"
    if [ ! -f "$MAIC_DIR/pyproject.toml" ]; then
        (cd "$MAIC_DIR" && uv init --bare --name maic --python "$PYTHON_VERSION" >/dev/null 2>&1) || return 1
        ok "Made $MAIC_DIR/pyproject.toml"
    fi
    note "Installing ${PACKAGES[*]}"
    note 'torch is the big one (a few hundred MB). This can take a few minutes.'
    (cd "$MAIC_DIR" && uv add "${PACKAGES[@]}" 2>&1 | grep -Ev '^(Resolved|Prepared|Installed|Audited| \+|Using)' | sed 's/^/  /')
    [ -x "$MAIC_DIR/.venv/bin/python" ] || return 1
    "$MAIC_DIR/.venv/bin/python" -c 'import torch, pandas, sklearn, matplotlib' >/dev/null 2>&1 || {
        fail 'Packages did not import. Run: cd ~/maic && uv sync'
        return 1
    }
    ok "~/maic environment is ready (Python $("$MAIC_DIR/.venv/bin/python" --version | sed 's/^Python //'))"
    # A Jupyter kernel VS Code can pick for any notebook.
    if [ ! -f "$HOME/Library/Jupyter/kernels/maic/kernel.json" ]; then
        (cd "$MAIC_DIR" && uv run python -m ipykernel install --user --name maic --display-name "MAIC (Python $PYTHON_VERSION)" >/dev/null 2>&1) || return 1
    fi
    ok 'Jupyter kernel "MAIC (Python 3.12)" is registered'
    return 0
}

step_vscode() {
    if find_code; then
        ok "VS Code is installed (${CODE_BIN%/Contents/Resources/app/bin/code})"
    else
        local dest='/Applications' tmp
        [ -w /Applications ] || { dest="$HOME/Applications"; mkdir -p "$dest"; }
        tmp="$WORK/vscode"
        mkdir -p "$tmp" || return 1
        note 'Downloading VS Code (about 150 MB).'
        if ! curl -fL --progress-bar -o "$tmp/vscode.zip" "$VSCODE_URL"; then
            fail "Could not download $VSCODE_URL"
            note 'Install by hand: https://code.visualstudio.com/download'
            return 1
        fi
        ditto -xk "$tmp/vscode.zip" "$dest" || return 1
        find_code || return 1
        ok "VS Code installed in $dest"
    fi
    # The `code` command for Terminal.
    ensure_path
    mkdir -p "$HOME/.local/bin"
    if [ ! -x "$HOME/.local/bin/code" ]; then
        ln -sf "$CODE_BIN" "$HOME/.local/bin/code"
    fi
    ok '`code` command is on PATH for new Terminal windows'
    return 0
}

step_extensions() {
    [ -n "$CODE_BIN" ] || find_code || return 1
    local installed ext
    installed=$("$CODE_BIN" --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')
    for ext in "${EXTENSIONS[@]}"; do
        if printf '%s\n' "$installed" | grep -qx "$ext"; then
            ok "$ext already installed"
            continue
        fi
        if "$CODE_BIN" --install-extension "$ext" --force >/dev/null 2>&1; then
            ok "Installed $ext"
        else
            fail "Could not install $ext. In VS Code: Extensions view, search \"$ext\"."
            return 1
        fi
    done
    return 0
}

step_settings() {
    # Only add keys that are absent. Never change what a member already set.
    local py settings
    py=$(python_bin) || { warn 'No ~/maic Python, so VS Code settings were not edited.'; return 0; }
    settings="$HOME/Library/Application Support/Code/User/settings.json"
    mkdir -p "$(dirname "$settings")"
    "$py" - "$settings" "$MAIC_DIR/.venv/bin/python" <<'PY'
import json, sys, os
path, interp = sys.argv[1], sys.argv[2]
wanted = {"remote.SSH.connectTimeout": 120, "python.defaultInterpreterPath": interp}
data = {}
if os.path.exists(path) and os.path.getsize(path) > 0:
    try:
        with open(path) as f:
            data = json.load(f)
    except Exception:
        print("  [!]  settings.json has comments or is not valid JSON. Not changed.")
        print('       Add by hand: "remote.SSH.connectTimeout": 120')
        sys.exit(0)
added = [k for k, v in wanted.items() if k not in data]
for k in added:
    data[k] = wanted[k]
if added:
    with open(path, "w") as f:
        json.dump(data, f, indent=4)
        f.write("\n")
    print("  [OK] VS Code settings added: " + ", ".join(added))
else:
    print("  [OK] VS Code settings already set")
PY
}

# ---------- report ----------
row() {
    # row "label" "value or empty" required(1/0)
    local label=$1 value=$2 required=$3
    if [ -n "$value" ]; then
        printf '  %s[OK]%s %-18s %s\n' "$C_CYAN" "$C_RESET" "$label" "$value"
    elif [ "$required" = 1 ]; then
        printf '  %s[X]%s  %-18s missing\n' "$C_RED" "$C_RESET" "$label"
        MISSING=1
    else
        printf '  %s[-]%s  %-18s not done\n' "$C_YELLOW" "$C_RESET" "$label"
        NOT_DONE=1
    fi
}

show_report() {
    MISSING=''; NOT_DONE=''
    path_now
    say 'What you have'
    row 'GlobalProtect' "$([ -d "$GP_APP" ] && echo installed)" 1
    row 'Git' "$(xcode-select -p >/dev/null 2>&1 && git --version 2>/dev/null | sed 's/^git version //')" 1
    row 'SSH key' "$([ -f "$KEY" ] && echo "$KEY")" 1
    local ruser; ruser=$(existing_rosie_user || true)
    row 'Rosie config' "$([ -n "$ruser" ] && echo "rosie -> $ruser@ad.msoe.edu")" 1
    if [ -z "$ruser" ]; then
        row 'Rosie login' '' 0
        note '     (not tested: no Rosie config yet)'
        row 'Jernel' '' 0
    elif rosie_probe; then
        row 'Rosie login' "$(rosie_login_ok && echo 'no password needed')" 0
        row 'Jernel' "$(ssh -o BatchMode=yes rosie "grep -qsF '$JERNEL_BIN' ~/.bashrc && echo ok" 2>/dev/null)" 0
    else
        row 'Rosie login' '' 0
        note '     (not tested: Rosie is not reachable. Connect GlobalProtect first.)'
        row 'Jernel' '' 0
    fi
    row 'GitHub login' "$(github_login_ok && echo 'key accepted')" 0
    row 'uv' "$(have uv && uv --version | sed 's/^uv //')" 1
    row "Python $PYTHON_VERSION" "$(have uv && uv python find "$PYTHON_VERSION" >/dev/null 2>&1 && echo installed)" 1
    local py; py=$(python_bin || true)
    row '~/maic env' "$([ -n "$py" ] && "$py" -c 'import torch, pandas; print("torch", torch.__version__, "pandas", pandas.__version__)' 2>/dev/null)" 1
    row 'MAIC kernel' "$([ -f "$HOME/Library/Jupyter/kernels/maic/kernel.json" ] && echo registered)" 1
    # find_code must run in this shell, not inside $(...), so CODE_BIN is set for the rows below.
    find_code || true
    row 'VS Code' "$([ -n "$CODE_BIN" ] && "$CODE_BIN" --version 2>/dev/null | head -1)" 1
    local ext missing_ext=''
    if [ -n "$CODE_BIN" ]; then
        local installed; installed=$("$CODE_BIN" --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')
        for ext in "${EXTENSIONS[@]}"; do printf '%s\n' "$installed" | grep -qx "$ext" || missing_ext="$missing_ext $ext"; done
        row 'Extensions' "$([ -z "$missing_ext" ] && echo "${EXTENSIONS[*]}")" 1
        [ -n "$missing_ext" ] && note "     missing:$missing_ext"
    else
        row 'Extensions' '' 1
    fi
    note "Log: $LOG"
}

# ---------- main ----------
mkdir -p "$(dirname "$LOG")"
printf '\n===== MAIC setup run %s =====\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"
exec > >(tee -a "$LOG") 2>&1

# One scratch folder for every download. It is removed when the script ends,
# whatever the reason (done, error, Ctrl-C). Only ~/maic-setup.log stays.
WORK=$(mktemp -d "${TMPDIR:-/tmp}/maic-setup.XXXXXX") || { fail 'Could not make a temp folder.'; exit 1; }
cleanup() {
    if [ -n "$WORK" ] && [ -d "$WORK" ]; then rm -rf "$WORK"; fi
    sleep 0.3  # let tee write the last lines
}
trap cleanup EXIT
trap 'exit 130' INT

show_logo

if [ -n "$CHECK" ]; then
    show_report
    printf '\n'
    if [ -n "$MISSING" ]; then
        fail 'Some required tools are missing. To install them, paste:'
        note "$PASTE_LINE"
        exit 1
    fi
    [ -n "$NOT_DONE" ] && warn 'Some optional steps are not done (see [-] above).'
    ok 'Ready.'
    exit 0
fi

say "MAIC member setup (macOS $(sw_vers -productVersion 2>/dev/null), $(uname -m))"
note 'This installs: GlobalProtect VPN, Git, SSH key, Rosie SSH config, GitHub SSH key,'
note "uv, Python $PYTHON_VERSION, a ~/maic environment (pandas, torch, ...), VS Code and extensions."
note 'Tools you already have are skipped. It asks for: your name, email, MSOE username,'
note 'your MSOE password one time (for Rosie), and a GitHub browser step.'
note "Estimated time: 10 to 25 minutes. Everything is logged to $LOG"
confirm 'Continue?' || exit 0

run_step 'Git'                 step_git
run_step 'SSH key'             step_ssh_key
run_step 'Rosie SSH config'    step_rosie_config
run_step 'GlobalProtect VPN'   step_vpn
run_step 'Rosie login'         step_rosie_key
run_step 'Jernel on Rosie'     step_jernel
run_step 'GitHub SSH key'      step_github
run_step 'uv and Python'       step_uv
run_step '~/maic environment'  step_env
run_step 'VS Code'             step_vscode
run_step 'VS Code extensions'  step_extensions
run_step 'VS Code settings'    step_settings

printf '\n'
show_report
printf '\n'
if [ ${#FAILED[@]} -gt 0 ]; then
    fail "Not ready. These steps did not finish: ${FAILED[*]}"
    note 'Fix the error (the article lists each tool), then paste the line again. Done steps are skipped:'
    note "$PASTE_LINE"
    note "Article: $ARTICLE"
    exit 1
fi
if [ ${#SKIPPED[@]} -gt 0 ]; then
    warn "Almost ready. Skipped: ${SKIPPED[*]}"
    note 'Connect GlobalProtect (or come to campus), then paste the same line again to finish the Rosie steps:'
    note "$PASTE_LINE"
else
    ok 'Ready. Welcome to MAIC.'
fi
note 'Open a NEW Terminal window so the new commands (code, uv, python) are found.'
note 'In VS Code: click the blue >< icon bottom-left, "Connect to Host", choose rosie.'
exit 0
