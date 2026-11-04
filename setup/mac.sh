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
# At the start it asks if you have a Rosie account, then shows a menu: pick what to set up.
#
# Options (set before the paste line):
#   MAIC_SETUP_CHECK=1   only report what is installed, change nothing
#   MAIC_SETUP_YES=1     no prompts and no menu (runs every part); skips the steps
#                        that need a person (VPN install, Rosie password, GitHub browser)
#   MAIC_SETUP_USER=name your MSOE username, so the script does not ask
#
# Read it first: open the URL above in a browser. It is plain text.

# No `set -e`: a failed step is reported and the script continues.
# No `set -u`: macOS ships bash 3.2, where empty arrays trip it.
# shellcheck disable=SC2088,SC2034  # "~/" only in messages; ST_, SEL_, INFO_ vars are read by name.

# ---------- settings ----------
PYTHON_VERSION='3.12'
MAIC_DIR="$HOME/maic"
KEY="$HOME/.ssh/id_ed25519"   # pick_key changes this to a key the member already has
ROSIE_KEY=''                  # the key Rosie gets; from an existing Rosie entry, else $KEY
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
ROSIE_HELP='https://msoe-maic.com/library/?nav=Articles&article=1-getting-rosie-access'

CHECK="${MAIC_SETUP_CHECK:-}"
YES="${MAIC_SETUP_YES:-}"

# ---------- colors: MAIC blue -> cyan -> purple ----------
IS_TTY=''
[ -t 1 ] && IS_TTY=1
if [ -n "$IS_TTY" ]; then
    C_BLUE=$'\e[38;5;33m'; C_CYAN=$'\e[38;5;51m'; C_WHITE=$'\e[38;5;255m'
    C_MAGENTA=$'\e[38;5;207m'; C_PURPLE=$'\e[38;5;135m'; C_GRAY=$'\e[38;5;245m'
    C_YELLOW=$'\e[38;5;220m'; C_RED=$'\e[38;5;203m'; C_RESET=$'\e[0m'
    C_ROSE=$'\e[38;5;160m'; C_LEAF=$'\e[38;5;70m'
else
    C_BLUE=''; C_CYAN=''; C_WHITE=''; C_MAGENTA=''; C_PURPLE=''; C_GRAY=''
    C_YELLOW=''; C_RED=''; C_RESET=''; C_ROSE=''; C_LEAF=''
fi
# Spinners, menus, and live step lines draw on the terminal only, not in the log.
TTY_OUT=/dev/null
if [ -n "$IS_TTY" ] && [ -w /dev/tty ]; then TTY_OUT=/dev/tty; fi
# On a terminal the script writes straight to the screen and copies its own lines
# to the log (no tee, so lines never arrive out of order). Elsewhere, tee logs all.
LOG_DIRECT=''
[ "$TTY_OUT" = /dev/tty ] && LOG_DIRECT=1

emit() {
    # emit TEXT: show TEXT, and log it without colors.
    clear_live
    printf '%s' "$1"
    [ -n "$LOG_DIRECT" ] && printf '%s' "$1" | sed $'s/\e\\[[0-9;?]*[A-Za-z]//g' >> "$LOG"
    return 0
}
line() { local s; printf -v s "$@"; emit "$s"; }

# Inside a step, ok sets the short detail shown on the step's result line.
IN_STEP=''
STEP_DETAIL=''
say()  { line '\n  %s%s%s\n\n' "$C_WHITE" "$*" "$C_RESET"; }
ok() {
    if [ -n "$IN_STEP" ]; then [ -n "$STEP_DETAIL" ] || STEP_DETAIL=$*; return 0; fi
    line '  %s✓%s %s\n' "$C_CYAN" "$C_RESET" "$*"
}
detail() { STEP_DETAIL=$*; }
warn() { line '    %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*"; }
fail() { line '    %s✗%s %s\n' "$C_RED" "$C_RESET" "$*"; }
note() { line '    %s\n' "$*"; }
dim()  { line '    %s%s%s\n' "$C_GRAY" "$*" "$C_RESET"; }
have() { command -v "$1" >/dev/null 2>&1; }

# Prompts read from the terminal, so both "bash -c" and "curl | bash" work.
ask() {
    # ask VAR "question" "default"
    local var=$1 question=$2 default=${3:-} answer=''
    if [ -n "$YES" ]; then printf -v "$var" '%s' "$default"; return 0; fi
    if [ -r /dev/tty ]; then
        clear_live
        # Inside a step the prompt sits under the step; elsewhere at the left edge.
        if [ -n "$IN_STEP" ]; then printf '    %s ' "$question" > /dev/tty; else printf '  %s ' "$question" > /dev/tty; fi
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
    ask _x "$1"
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
    printf '\n  %sMSOE AI Club%s %s·%s %sMember setup for macOS%s\n' \
        "$C_CYAN" "$C_RESET" "$C_GRAY" "$C_RESET" "$C_WHITE" "$C_RESET"
}

# ---------- step runner ----------
FAILED=()
SKIPPED=()
ROSIE_REACHABLE=''
ROSIE_USER=''
GIT_EMAIL=''
CODE_BIN=''

STEP_N=0
STEP_TOTAL=0
STEP_LABEL=''
STEP_SKIP=''
run_step() {
    # run_step "label" function
    # While the step runs, one live line shows a spinner and the overall bar.
    # When it ends, that line becomes one result line:  ✓ Git   2.54.0
    local label=$1 fn=$2 rc
    STEP_N=$((STEP_N + 1)); STEP_LABEL=$label; STEP_DETAIL=''; STEP_SKIP=''
    IN_STEP=1
    live_draw '·' ''
    "$fn"; rc=$?
    IN_STEP=''
    if [ -n "$STEP_SKIP" ]; then
        line '  %s–%s %-20s %s%s%s\n' "$C_YELLOW" "$C_RESET" "$label" "$C_YELLOW" "$STEP_SKIP" "$C_RESET"
    elif [ "$rc" -eq 0 ]; then
        line '  %s✓%s %-20s %s%s%s\n' "$C_CYAN" "$C_RESET" "$label" "$C_GRAY" "$STEP_DETAIL" "$C_RESET"
    else
        line '  %s✗%s %-20s %sdid not finish%s\n' "$C_RED" "$C_RESET" "$label" "$C_RED" "$C_RESET"
        FAILED+=("$label")
    fi
    return 0
}
skip_step() {
    # skip_step "label" "reason": the result line shows the reason.
    STEP_SKIP="skipped: $2"
    SKIPPED+=("${STEP_LABEL:-$1}")
}

LIVE_ON=''
live_draw() {
    # live_draw FRAME "what is happening": redraw the current step's live line.
    [ "$TTY_OUT" = /dev/tty ] && [ "$STEP_TOTAL" -gt 0 ] || return 0
    printf '\r  %s%s%s %-20s %s %s%d/%d%s  %s%s%s\e[K' "$C_CYAN" "$1" "$C_RESET" "$STEP_LABEL" \
        "$(progress_bar $((STEP_N - 1)) "$STEP_TOTAL")" "$C_GRAY" "$STEP_N" "$STEP_TOTAL" "$C_RESET" \
        "$C_GRAY" "$2" "$C_RESET" > /dev/tty
    LIVE_ON=1
}
clear_live() {
    [ -n "$LIVE_ON" ] || return 0
    printf '\r\e[K' > /dev/tty
    LIVE_ON=''
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
    ssh -n -o BatchMode=yes -o ConnectTimeout=10 rosie true >/dev/null 2>&1
}

github_login_ok() {
    local out
    out=$(ssh -n -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1)
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

show_rosie() {
    # The ROSIE banner with a rose, shown with the Rosie account question.
    local w=$C_WHITE r=$C_ROSE g=$C_LEAF x=$C_RESET
    printf '  %s██████╗  ██████╗ ███████╗██╗███████╗%s    %s.-""-.%s\n' "$w" "$x" "$r" "$x"
    printf '  %s██╔══██╗██╔═══██╗██╔════╝██║██╔════╝%s   %s/ @ @  \\%s\n' "$w" "$x" "$r" "$x"
    printf '  %s██████╔╝██║   ██║███████╗██║█████╗%s    %s( @(@)@  )%s\n' "$w" "$x" "$r" "$x"
    printf '  %s██╔══██╗██║   ██║╚════██║██║██╔══╝%s     %s\\_@_@_/%s\n' "$w" "$x" "$r" "$x"
    printf '  %s██║  ██║╚██████╔╝███████║██║███████╗%s  %s__\\ | /__%s\n' "$w" "$x" "$g" "$x"
    printf '  %s╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝╚══════╝%s  %s\\__\\|/__/%s\n' "$w" "$x" "$g" "$x"
    printf '\n'
}

SPIN_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

elapsed() {
    # elapsed START_SECONDS -> "1m 05s" or "12s"
    local t=$((SECONDS - $1))
    if [ "$t" -ge 60 ]; then printf '%dm %02ds' $((t / 60)) $((t % 60)); else printf '%ds' "$t"; fi
}

spin() {
    # spin "what is happening" command args...
    # Runs the command with a spinner and the time used on the step's live line.
    # The command output goes to the log; on failure its last lines are shown.
    local label=$1 out pid rc i=0 start=$SECONDS l
    shift
    out="$WORK/spin.$RANDOM.out"
    "$@" > "$out" 2>&1 &
    pid=$!
    printf '\e[?25l' > "$TTY_OUT"
    while kill -0 "$pid" 2>/dev/null; do
        live_draw "${SPIN_FRAMES[$((i % 10))]}" "$label · $(elapsed "$start")"
        i=$((i + 1))
        sleep 0.1
    done
    wait "$pid"; rc=$?
    printf '\e[?25h' > "$TTY_OUT"
    live_draw '·' ''
    cat "$out" >> "$LOG"
    if [ "$rc" -ne 0 ]; then
        fail "Failed while $label. Last lines:"
        tail -n 6 "$out" | while IFS= read -r l; do dim "  $l"; done
    fi
    rm -f "$out"
    return "$rc"
}

download() {
    # download URL FILE "what": fetch with the percent on the live line.
    local url=$1 file=$2 what=$3 total pid rc i=0 have pct
    total=$(curl -fsIL "$url" 2>/dev/null | tr -d '\r' |
        awk 'tolower($1) == "content-length:" { n = $2 } END { print n + 0 }')
    curl -fsSL -o "$file" "$url" 2>> "$LOG" &
    pid=$!
    printf '\e[?25l' > "$TTY_OUT"
    while kill -0 "$pid" 2>/dev/null; do
        have=$(stat -f %z "$file" 2>/dev/null || echo 0)
        pct=''
        [ "$total" -gt 0 ] && pct=" $((have * 100 / total))%"
        live_draw "${SPIN_FRAMES[$((i % 10))]}" "$what$pct · $((have / 1048576)) MB"
        i=$((i + 1))
        sleep 0.1
    done
    wait "$pid"; rc=$?
    printf '\e[?25h' > "$TTY_OUT"
    live_draw '·' ''
    return "$rc"
}

spin_bg_start() {
    # A spinner in the background while this shell does work that sets variables.
    [ "$TTY_OUT" = /dev/tty ] || { dim "$1..."; return 0; }
    local label=$1
    (
        i=0; start=$SECONDS
        printf '\e[?25l'
        while :; do
            printf '\r  %s%s%s %s%s %s%s\e[K' "$C_CYAN" "${SPIN_FRAMES[$((i % 10))]}" "$C_RESET" \
                "$C_GRAY" "$label" "$(elapsed "$start")" "$C_RESET"
            i=$((i + 1)); sleep 0.1
        done
    ) > /dev/tty &
    SPIN_BG_PID=$!
}
spin_bg_stop() {
    [ -n "${SPIN_BG_PID:-}" ] || return 0
    kill "$SPIN_BG_PID" 2>/dev/null; wait "$SPIN_BG_PID" 2>/dev/null
    SPIN_BG_PID=''
    printf '\r\e[K\e[?25h' > /dev/tty
}

progress_bar() {
    # progress_bar DONE TOTAL -> a 16-cell bar: cyan for done, gray for to do.
    local done=$1 total=$2 width=16 fill i on='' off=''
    [ "$total" -gt 0 ] || total=1
    fill=$((done * width / total))
    # Braces matter: in a UTF-8 locale bash 3.2 reads "$on━" as one variable name.
    for ((i = 0; i < width; i++)); do
        if [ "$i" -lt "$fill" ]; then on="${on}━"; else off="${off}━"; fi
    done
    printf '%s%s%s%s%s' "$C_CYAN" "$on" "$C_GRAY" "$off" "$C_RESET"
}

pick_key() {
    # Use a key the member already has (with its .pub), so no second key is made.
    local k
    for k in "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_ecdsa" "$HOME/.ssh/id_rsa"; do
        if [ -f "$k" ] && [ -f "$k.pub" ]; then KEY=$k; return 0; fi
    done
    KEY="$HOME/.ssh/id_ed25519"
    return 1
}

rosie_entry() {
    # Find an existing Rosie entry in ~/.ssh/config: a Host block named rosie, or
    # any block for dh-mgmt2.hpc.msoe.edu. Sets RE_ALIAS, RE_USER (no @domain),
    # RE_KEY (path, or empty), and RE_IS_ROSIE (1 when the alias is "rosie").
    RE_ALIAS=''; RE_USER=''; RE_KEY=''; RE_IS_ROSIE=''
    [ -f "$SSH_CONFIG" ] || return 1
    local line alias user key isr
    # "|" separates the fields: a tab is IFS white space, so empty fields would collapse.
    while IFS='|' read -r alias user key isr; do
        [ -n "$alias" ] || continue
        if [ -z "$RE_ALIAS" ] || { [ -n "$isr" ] && [ -z "$RE_IS_ROSIE" ]; }; then
            RE_ALIAS=$alias; RE_USER=${user%%@*}; RE_KEY=$key; RE_IS_ROSIE=$isr
        fi
    done < <(awk -v h="$ROSIE_HOST" '
        function flush() { if (m) print al "|" u "|" f "|" r; m = 0 }
        tolower($1) == "host" {
            flush(); al = $2; u = ""; f = ""; r = ""
            for (i = 2; i <= NF; i++) {
                a = tolower($i)
                if (a == "rosie") { m = 1; r = 1; al = $i } else if (a == h) m = 1
            }
            next
        }
        tolower($1) == "match" { flush(); al = ""; next }
        tolower($1) == "hostname" && tolower($2) == h { m = 1 }
        tolower($1) == "user" && u == "" { u = $2 }
        tolower($1) == "identityfile" && f == "" { f = $2 }
        END { flush() }
    ' "$SSH_CONFIG")
    # shellcheck disable=SC2088
    case "$RE_KEY" in "~/"*) RE_KEY="$HOME/${RE_KEY#\~/}" ;; esac
    [ -n "$RE_KEY" ] && [ ! -f "$RE_KEY" ] && RE_KEY=''
    [ -n "$RE_ALIAS" ]
}

env_ok() {
    local py
    py=$(python_bin) || return 1
    "$py" -c 'import torch, pandas, sklearn, matplotlib' >/dev/null 2>&1 &&
        [ -f "$HOME/Library/Jupyter/kernels/maic/kernel.json" ]
}

vscode_ok() {
    find_code || return 1
    local installed ext
    installed=$("$CODE_BIN" --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')
    for ext in "${EXTENSIONS[@]}"; do printf '%s\n' "$installed" | grep -qx "$ext" || return 1; done
    grep -qsF 'remote.SSH.connectTimeout' "$HOME/Library/Application Support/Code/User/settings.json"
}

# ---------- steps ----------

step_git() {
    # Apple's Command Line Tools provide git. On a new Mac `git` is a stub that
    # opens the install dialog, so check xcode-select first to avoid two dialogs.
    if ! { xcode-select -p >/dev/null 2>&1 && git --version >/dev/null 2>&1; }; then
        if [ -n "$YES" ]; then
            fail 'Git is missing. Install it by hand: xcode-select --install'
            return 1
        fi
        note 'A macOS window opens. Click Install, then Agree.'
        xcode-select --install >/dev/null 2>&1 || true
        # Apple's installer gives no percent, so show a spinner and the time used.
        local start=$SECONDS i=0
        printf '\e[?25l' > "$TTY_OUT"
        while ! xcode-select -p >/dev/null 2>&1; do
            if [ $((SECONDS - start)) -ge 1200 ]; then
                printf '\e[?25h' > "$TTY_OUT"
                fail 'Not finished after 20 minutes. Finish the window, then run setup again.'
                return 1
            fi
            live_draw "${SPIN_FRAMES[$((i % 10))]}" "installing (5 to 15 min) · $(elapsed "$start")"
            i=$((i + 1))
            sleep 0.5
        done
        printf '\e[?25h' > "$TTY_OUT"
        git --version >/dev/null 2>&1 || return 1
    fi
    detail "$(git --version | sed 's/^git version //; s/ (.*//')"

    # git needs a name and email before it can save a commit.
    local name email
    name=$(git config --global user.name || true)
    email=$(git config --global user.email || true)
    if [ -z "$name" ]; then
        ask name 'Your name:'
        [ -n "$name" ] && git config --global user.name "$name"
    fi
    if [ -z "$email" ]; then
        local tries=0
        while [ "$tries" -lt 3 ] && [ -z "$email" ]; do
            ask email 'Your email (the one on your GitHub account):'
            tries=$((tries + 1))
            if [[ ! "$email" =~ ^[^@[:space:]]+@[^@[:space:]]+$ ]]; then
                [ -n "$email" ] && warn 'That is not an email address.'
                email=''
            fi
        done
        [ -n "$email" ] && git config --global user.email "$email"
    fi
    if [ -z "$name" ] || [ -z "$email" ]; then
        warn 'No name or email, so git cannot save commits yet. Run setup again to add them.'
    fi
    GIT_EMAIL=$email
    if [ -z "$(git config --global init.defaultBranch || true)" ]; then
        git config --global init.defaultBranch main
    fi
    return 0
}

step_ssh_key() {
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    if pick_key; then
        detail "${KEY/#$HOME/~} (already there)"
        return 0
    fi
    # No passphrase: ssh rosie and git push work with zero prompts.
    local comment="${GIT_EMAIL:-$USER@maic}"
    ssh-keygen -t ed25519 -N '' -C "$comment" -f "$KEY" -q || return 1
    detail "made ${KEY/#$HOME/~}"
    return 0
}

install_rosie_cmd() {
    # A `rosie` command, so members type `rosie` instead of `ssh rosie`.
    # A script in ~/.local/bin works in every shell; no alias or rc edit needed.
    local cmd="$HOME/.local/bin/rosie"
    mkdir -p "$HOME/.local/bin"
    printf '#!/bin/sh\n# Added by the MAIC setup script: "rosie" means "ssh rosie".\nexec ssh rosie "$@"\n' > "$cmd"
    chmod +x "$cmd"
    ensure_path
}

step_rosie_config() {
    pick_key || true
    ROSIE_KEY=$KEY
    if rosie_entry && [ -n "$RE_IS_ROSIE" ] && [ -n "$RE_USER" ]; then
        ROSIE_USER=$RE_USER
        [ -n "$RE_KEY" ] && ROSIE_KEY=$RE_KEY
        detail "user $ROSIE_USER (already there)"
        install_rosie_cmd
        return 0
    fi
    local user='' tries=0 default=${MAIC_SETUP_USER:-}
    if [ -n "$RE_ALIAS" ] && [ -n "$RE_USER" ]; then
        # An entry for dh-mgmt2 under another name: reuse its user and key.
        user=$RE_USER
        [ -n "$RE_KEY" ] && ROSIE_KEY=$RE_KEY
    fi
    while [ "$tries" -lt 3 ] && [ -z "$user" ]; do
        ask user 'Your MSOE username (before @msoe.edu):' "$default"
        tries=$((tries + 1))
        user=$(printf '%s' "$user" | tr '[:upper:]' '[:lower:]' | sed 's/@.*//; s/[[:space:]]//g')
        if [[ ! "$user" =~ ^[a-z0-9._-]+$ ]]; then
            [ -n "$user" ] && warn 'Use only letters, numbers, dots, or dashes.'
            user=''
        fi
    done
    if [ -z "$user" ]; then
        if [ -n "$YES" ]; then skip_step 'Rosie SSH config' 'no MSOE username'; return 0; fi
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
    IdentityFile $ROSIE_KEY
    StrictHostKeyChecking accept-new

# Compute nodes, reached through the login node (for example: ssh dh-node1)
Host dh-node*
    HostName %h
    User $ROSIE_USER@ad.msoe.edu
    IdentityFile $ROSIE_KEY
    ProxyJump rosie
    StrictHostKeyChecking accept-new
EOF
    detail "user $ROSIE_USER, added to ~/.ssh/config"
    install_rosie_cmd
    return 0
}

step_vpn() {
    # Rosie is only reachable from campus Wi-Fi or the GlobalProtect VPN.
    if [ -d "$GP_APP" ]; then
        detail 'installed'
    else
        if [ -n "$YES" ]; then
            skip_step 'GlobalProtect VPN' 'the install needs your Mac password'
            return 0
        fi
        local tmp pkg
        tmp="$WORK/globalprotect"
        mkdir -p "$tmp" || return 1
        pkg="$tmp/GlobalProtect.pkg"
        if ! download "$GP_PKG_URL" "$pkg" 'downloading'; then
            fail "Download failed. Install by hand: https://$VPN_PORTAL/global-protect/getsoftwarepage.esp"
            return 1
        fi
        note 'Type your Mac password to install (the letters stay hidden).'
        clear_live
        sudo -v -p '    Password: ' || { fail 'No password, so GlobalProtect was not installed.'; return 1; }
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
        if ! spin 'installing' sudo -n installer -pkg "$pkg" -target /; then
            fail "Install by hand: https://$VPN_PORTAL/global-protect/getsoftwarepage.esp"
            return 1
        fi
        detail 'installed (if macOS asks to allow it, click Allow)'
    fi
    return 0
}

step_rosie_connect() {
    live_draw '·' 'checking'
    if rosie_probe; then
        ROSIE_REACHABLE=1
        detail 'reachable'
        return 0
    fi
    if [ -n "$YES" ]; then
        skip_step 'Rosie connection' 'not on campus or VPN'
        return 0
    fi
    [ -d "$GP_APP" ] || warn 'GlobalProtect is not installed. Off campus, Rosie needs it.'
    open -a GlobalProtect >/dev/null 2>&1 || true
    note "Off campus? Connect GlobalProtect (menu bar icon) to $VPN_PORTAL."
    local try
    for try in 1 2 3; do
        pause 'Press Enter when GlobalProtect says Connected.'
        live_draw '·' 'checking'
        if rosie_probe; then
            ROSIE_REACHABLE=1
            detail 'reachable'
            return 0
        fi
        [ "$try" -lt 3 ] && warn 'Rosie did not answer yet. Is GlobalProtect connected?'
    done
    skip_step 'Rosie connection' 'Rosie did not answer'
    return 0
}

step_rosie_key() {
    if [ -z "$ROSIE_USER" ]; then skip_step 'Rosie login' 'no MSOE username'; return 0; fi
    if [ -z "$ROSIE_REACHABLE" ]; then skip_step 'Rosie login' 'Rosie is not reachable'; return 0; fi
    live_draw '·' 'checking'
    if rosie_login_ok; then
        detail 'no password needed'
        return 0
    fi
    if [ -n "$YES" ]; then skip_step 'Rosie login' 'needs your MSOE password'; return 0; fi
    note 'Type your MSOE password one time (the letters stay hidden).'
    note 'After this, Rosie lets you in with your key, no password.'
    local try err="$WORK/copy-id.err"
    for try in 1 2 3; do
        clear_live
        if ssh-copy-id -i "${ROSIE_KEY:-$KEY}.pub" rosie >/dev/null 2> "$err" && rosie_login_ok; then
            detail 'no password needed from now on'
            return 0
        fi
        # Show ssh's own reason (for example "Permission denied"), not its INFO lines.
        grep -v 'INFO:' "$err" | tail -n 2 | while IFS= read -r l; do dim "$l"; done
        [ "$try" -lt 3 ] && warn "That did not work. Check your password (user $ROSIE_USER)."
    done
    note "Test it by hand: ssh rosie. If that fails too, your Rosie account is the problem: ask the eboard."
    return 1
}

step_jernel() {
    if [ -z "$ROSIE_REACHABLE" ] || ! rosie_login_ok; then
        skip_step 'Jernel on Rosie' 'Rosie login is not set up'
        return 0
    fi
    live_draw '·' 'checking'
    # Same line as /data/ai_club/util/setup, added only once.
    local result
    result=$(ssh -n -o BatchMode=yes rosie "
        if grep -qsF '$JERNEL_BIN' ~/.bashrc; then echo present
        else printf '\nexport PATH=\"$JERNEL_BIN/:\$PATH\" # MAIC tools (jernel). Added by the MAIC setup script.\n' >> ~/.bashrc && echo added
        fi
        test -x '$JERNEL_BIN/jernel' && echo jernel-ok" 2>/dev/null) || return 1
    case "$result" in
        *present*) detail 'on your PATH (already there)' ;;
        *added*) detail 'added to your PATH on Rosie' ;;
        *) return 1 ;;
    esac
    [[ "$result" == *jernel-ok* ]] || warn "$JERNEL_BIN/jernel is missing on Rosie. Ask the eboard."
    return 0
}

step_github() {
    pick_key || true
    live_draw '·' 'checking'
    if github_login_ok; then
        detail 'key accepted'
        return 0
    fi
    if [ -n "$YES" ]; then skip_step 'GitHub SSH key' 'needs a browser'; return 0; fi
    if ! confirm 'Do you have a GitHub account?'; then
        note 'Make one in the browser page that opens (any email works).'
        open 'https://github.com/signup' >/dev/null 2>&1 || true
        pause 'Press Enter when you have an account.'
    fi
    local try
    for try in 1 2 3; do
        pbcopy < "$KEY.pub" 2>/dev/null
        note 'Your key is copied. In the page that opens:'
        note "  Title: MAIC laptop   Key: press Cmd+V   then click \"Add SSH key\""
        open 'https://github.com/settings/ssh/new' >/dev/null 2>&1 || note 'Open https://github.com/settings/ssh/new'
        pause 'Press Enter after you click "Add SSH key".'
        live_draw '·' 'checking'
        if github_login_ok; then
            detail 'key accepted'
            return 0
        fi
        [ "$try" -lt 3 ] && warn 'GitHub does not accept the key yet.'
    done
    note 'Guide: https://msoe-maic.com/library/?nav=Articles&article=GitHub-SSH-Keys'
    return 1
}

step_uv() {
    ensure_path
    if ! have uv; then
        spin 'installing uv' sh -c "curl -LsSf '$UV_INSTALL_URL' | sh" || {
            fail 'Could not reach astral.sh. Check your internet connection.'
            return 1
        }
        ensure_path
        have uv || return 1
    fi
    # uv installs Python itself. On a Mac with no python3 command, --default also
    # gives `python` and `python3` commands in ~/.local/bin.
    if ! { uv python find "$PYTHON_VERSION" >/dev/null 2>&1 && have python3; }; then
        if have python3; then
            spin "installing Python $PYTHON_VERSION" uv python install "$PYTHON_VERSION" || return 1
        else
            spin "installing Python $PYTHON_VERSION" sh -c "uv python install '$PYTHON_VERSION' --default \
                || uv python install '$PYTHON_VERSION' --default --preview \
                || uv python install '$PYTHON_VERSION'" || return 1
        fi
        uv python find "$PYTHON_VERSION" >/dev/null 2>&1 || return 1
    fi
    detail "$PYTHON_VERSION, with uv $(uv --version | sed 's/^uv //; s/ .*//')"
    return 0
}

step_env() {
    have uv || return 1
    mkdir -p "$MAIC_DIR"
    if [ ! -f "$MAIC_DIR/pyproject.toml" ]; then
        (cd "$MAIC_DIR" && uv init --bare --name maic --python "$PYTHON_VERSION" >/dev/null 2>&1) || return 1
    fi
    local pkg missing=''
    for pkg in "${PACKAGES[@]}"; do grep -qs "\"$pkg" "$MAIC_DIR/pyproject.toml" || missing=1; done
    if [ -n "$missing" ] || ! env_ok; then
        # torch is a few hundred MB, so this is the longest wait.
        spin 'downloading (torch is big)' sh -c "cd '$MAIC_DIR' && uv add ${PACKAGES[*]}" || return 1
        "$MAIC_DIR/.venv/bin/python" -c 'import torch, pandas, sklearn, matplotlib' >/dev/null 2>&1 || {
            fail 'The packages do not import. Run: cd ~/maic && uv sync'
            return 1
        }
    fi
    # A Jupyter kernel VS Code can pick for any notebook.
    if [ ! -f "$HOME/Library/Jupyter/kernels/maic/kernel.json" ]; then
        spin 'adding the Jupyter kernel' sh -c "cd '$MAIC_DIR' && uv run python -m ipykernel install --user --name maic --display-name 'MAIC (Python $PYTHON_VERSION)'" || return 1
    fi
    detail "~/maic, with torch, pandas, and Jupyter"
    return 0
}

step_vscode() {
    if ! find_code; then
        local dest='/Applications' tmp
        [ -w /Applications ] || { dest="$HOME/Applications"; mkdir -p "$dest"; }
        tmp="$WORK/vscode"
        mkdir -p "$tmp" || return 1
        if ! download "$VSCODE_URL" "$tmp/vscode.zip" 'downloading'; then
            fail 'Download failed. Install by hand: https://code.visualstudio.com/download'
            return 1
        fi
        spin 'unpacking' ditto -xk "$tmp/vscode.zip" "$dest" || return 1
        find_code || return 1
    fi
    # The `code` command for Terminal.
    ensure_path
    mkdir -p "$HOME/.local/bin"
    if [ ! -x "$HOME/.local/bin/code" ]; then
        ln -sf "$CODE_BIN" "$HOME/.local/bin/code"
    fi
    detail "$("$CODE_BIN" --version 2>/dev/null | head -1), and the code command"
    return 0
}

step_extensions() {
    [ -n "$CODE_BIN" ] || find_code || return 1
    local installed ext n=0
    installed=$("$CODE_BIN" --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')
    for ext in "${EXTENSIONS[@]}"; do
        printf '%s\n' "$installed" | grep -qx "$ext" && continue
        if spin "installing $ext" "$CODE_BIN" --install-extension "$ext" --force; then
            n=$((n + 1))
        else
            fail "In VS Code, open Extensions and install \"$ext\"."
            return 1
        fi
    done
    detail 'Remote SSH, Python, Jupyter'
    return 0
}

step_settings() {
    # Only add keys that are absent. Never change what a member already set.
    local py settings out
    py=$(python_bin) || { skip_step 'VS Code settings' 'no ~/maic Python yet'; return 0; }
    settings="$HOME/Library/Application Support/Code/User/settings.json"
    mkdir -p "$(dirname "$settings")"
    out=$("$py" - "$settings" "$MAIC_DIR/.venv/bin/python" <<'PY'
import json, sys, os
path, interp = sys.argv[1], sys.argv[2]
wanted = {"remote.SSH.connectTimeout": 120, "python.defaultInterpreterPath": interp}
data = {}
if os.path.exists(path) and os.path.getsize(path) > 0:
    try:
        with open(path) as f:
            data = json.load(f)
    except Exception:
        print("invalid")
        sys.exit(0)
added = [k for k, v in wanted.items() if k not in data]
for k in added:
    data[k] = wanted[k]
if added:
    with open(path, "w") as f:
        json.dump(data, f, indent=4)
        f.write("\n")
    print("added")
else:
    print("present")
PY
)
    case "$out" in
        added) detail 'Rosie timeout and the ~/maic Python' ;;
        present) detail 'already set' ;;
        *)
            warn 'settings.json has comments, so it was not changed.'
            note 'Add by hand: "remote.SSH.connectTimeout": 120'
            ;;
    esac
    return 0
}

# ---------- menu ----------
# Menu parts, in run order. Each part runs one or more step functions.
ITEMS=(git sshkey vpn rosie github python env vscode)
ROSIE_ACCESS=''
reply=''

label_of() {
    case $1 in
        git) printf 'Git' ;;
        sshkey) printf 'SSH key' ;;
        vpn) printf 'GlobalProtect VPN' ;;
        rosie) printf 'Rosie' ;;
        github) printf 'GitHub key' ;;
        python) printf 'Python %s' "$PYTHON_VERSION" ;;
        env) printf 'ML packages (torch, pandas)' ;;
        vscode) printf 'VS Code' ;;
    esac
}
needs_of() {
    case $1 in
        rosie) printf 'sshkey vpn' ;;
        github) printf 'sshkey' ;;
        env) printf 'python' ;;
    esac
}
steps_of() {
    case $1 in
        git) printf 'step_git' ;;
        sshkey) printf 'step_ssh_key' ;;
        vpn) printf 'step_vpn' ;;
        rosie) printf 'step_rosie_config step_rosie_connect step_rosie_key step_jernel' ;;
        github) printf 'step_github' ;;
        python) printf 'step_uv' ;;
        env) printf 'step_env' ;;
        vscode) printf 'step_vscode step_extensions step_settings' ;;
    esac
}
step_label() {
    case $1 in
        step_git) printf 'Git' ;;
        step_ssh_key) printf 'SSH key' ;;
        step_vpn) printf 'GlobalProtect' ;;
        step_rosie_config) printf 'Rosie SSH config' ;;
        step_rosie_connect) printf 'Rosie connection' ;;
        step_rosie_key) printf 'Rosie login' ;;
        step_jernel) printf 'Jernel on Rosie' ;;
        step_github) printf 'GitHub key' ;;
        step_uv) printf 'Python' ;;
        step_env) printf 'ML packages' ;;
        step_vscode) printf 'VS Code' ;;
        step_extensions) printf 'VS Code extensions' ;;
        step_settings) printf 'VS Code settings' ;;
    esac
}

detect_all() {
    # Sets ST_<part> to done, todo, or unknown, and INFO_<part> to a short note.
    local id
    for id in "${ITEMS[@]}"; do printf -v "ST_$id" '%s' todo; printf -v "INFO_$id" '%s' ''; done
    if xcode-select -p >/dev/null 2>&1 && git --version >/dev/null 2>&1 &&
        [ -n "$(git config --global user.name)" ] && [ -n "$(git config --global user.email)" ]; then
        ST_git='done'
    fi
    if pick_key; then ST_sshkey='done'; INFO_sshkey="${KEY/#$HOME/~}"; fi
    [ -d "$GP_APP" ] && ST_vpn='done'
    if rosie_entry && [ -n "$RE_IS_ROSIE" ] && [ -n "$RE_USER" ]; then
        if ! rosie_probe; then
            ST_rosie=unknown; INFO_rosie='cannot check: VPN off'
        elif rosie_login_ok && ssh -n -o BatchMode=yes rosie "grep -qsF '$JERNEL_BIN' ~/.bashrc" 2>/dev/null; then
            ST_rosie='done'; INFO_rosie="user $RE_USER"
        fi
    elif [ -n "$RE_ALIAS" ]; then
        INFO_rosie="found Host $RE_ALIAS"
    fi
    github_login_ok && ST_github='done'
    path_now
    have uv && uv python find "$PYTHON_VERSION" >/dev/null 2>&1 && ST_python='done'
    env_ok && ST_env='done'
    vscode_ok && ST_vscode='done'
    return 0
}

default_selection() {
    # Everything not done is selected. MAIC_SETUP_YES selects everything.
    local id st
    for id in "${ITEMS[@]}"; do
        st="ST_$id"
        if [ -n "$YES" ] || [ "${!st}" != 'done' ]; then printf -v "SEL_$id" '%s' 1; else printf -v "SEL_$id" '%s' ''; fi
    done
    if [ "$ROSIE_ACCESS" = no ]; then
        SEL_rosie=''
        [ "$ST_vpn" = 'done' ] || SEL_vpn=''
    fi
}

draw_menu() {
    # draw_menu CURSOR
    local cur=$1 i id sel st info mark status pointer name
    for i in "${!ITEMS[@]}"; do
        id=${ITEMS[$i]}
        sel="SEL_$id"; st="ST_$id"; info="INFO_$id"
        if [ -n "${!sel}" ]; then mark="${C_CYAN}[x]${C_RESET}"; else mark="${C_GRAY}[ ]${C_RESET}"; fi
        case "${!st}" in
            done) if [ -n "${!sel}" ]; then status="${C_YELLOW}done, will run again${C_RESET}"; else status="${C_GRAY}done${C_RESET}"; fi ;;
            unknown) status="${C_YELLOW}${!info}${C_RESET}" ;;
            *) status='' ;;
        esac
        [ "$id" = rosie ] && [ "$ROSIE_ACCESS" = no ] && status="${C_GRAY}needs a Rosie account${C_RESET}"
        name=$(label_of "$id")
        if [ "$i" -eq "$cur" ]; then
            pointer="${C_MAGENTA}›${C_RESET}"; name="${C_WHITE}$(printf '%-30s' "$name")${C_RESET}"
        else
            pointer=' '; name=$(printf '%-30s' "$name")
        fi
        printf '  %s %s %s %s\n' "$pointer" "$mark" "$name" "$status"
    done
    printf '\n  %s↑↓ move   space pick   enter start   q quit%s\n' "$C_GRAY" "$C_RESET"
}

choose_items() {
    # Arrow keys and Space on /dev/tty. Returns 1 when the member quits.
    # On Enter the menu is erased, so the screen shows only what happens next.
    local cur=0 n=${#ITEMS[@]} key rest drawn=0 id sel
    printf '\n  %sPick what to set up%s\n\n' "$C_WHITE" "$C_RESET" > /dev/tty
    printf '\e[?25l' > /dev/tty
    while :; do
        [ "$drawn" -gt 0 ] && printf '\e[%dA\e[J' "$drawn" > /dev/tty
        draw_menu "$cur" > /dev/tty
        drawn=$((n + 2))
        key=''
        IFS= read -rsn1 key < /dev/tty || key=q
        if [ "$key" = $'\e' ]; then
            rest=''
            IFS= read -rsn2 -t 1 rest < /dev/tty || true
            key="$key$rest"
        fi
        case "$key" in
            $'\e[A' | $'\eOA' | k) cur=$(((cur + n - 1) % n)) ;;
            $'\e[B' | $'\eOB' | j) cur=$(((cur + 1) % n)) ;;
            ' ')
                id=${ITEMS[$cur]}; sel="SEL_$id"
                if [ -n "${!sel}" ]; then printf -v "SEL_$id" '%s' ''; else printf -v "SEL_$id" '%s' 1; fi
                ;;
            a | A) for id in "${ITEMS[@]}"; do printf -v "SEL_$id" '%s' 1; done ;;
            n | N) for id in "${ITEMS[@]}"; do printf -v "SEL_$id" '%s' ''; done ;;
            q | Q) printf '\e[?25h' > /dev/tty; return 1 ;;
            '') break ;;
        esac
    done
    printf '\e[%dA\e[J\e[?25h' $((drawn + 3)) > /dev/tty
    return 0
}

add_needed() {
    # A picked part also picks the parts it needs that are not done yet.
    local id dep sel dsel dst
    ADDED_NOTE=''
    for id in "${ITEMS[@]}"; do
        sel="SEL_$id"
        [ -n "${!sel}" ] || continue
        for dep in $(needs_of "$id"); do
            dsel="SEL_$dep"; dst="ST_$dep"
            if [ -z "${!dsel}" ] && [ "${!dst}" != 'done' ]; then
                printf -v "SEL_$dep" '%s' 1
                ADDED_NOTE="$ADDED_NOTE  Added $(label_of "$dep") ($(label_of "$id") needs it)."
            fi
        done
    done
}

selected_steps() {
    STEPS=()
    local id sel fn
    for id in "${ITEMS[@]}"; do
        sel="SEL_$id"
        [ -n "${!sel}" ] || continue
        for fn in $(steps_of "$id"); do STEPS+=("$fn"); done
    done
}

# ---------- report (MAIC_SETUP_CHECK) ----------
need() {
    # need PART -> 1 (required) in check mode or when picked, else "skip".
    local sel="SEL_$1"
    if [ -n "$CHECK" ] || [ -n "${!sel:-}" ]; then printf 1; else printf skip; fi
}
row() {
    # row "label" "value or empty" required(1/0/skip)
    local label=$1 value=$2 required=$3
    if [ -n "$value" ]; then
        line '  %s✓%s %-20s %s%s%s\n' "$C_CYAN" "$C_RESET" "$label" "$C_GRAY" "$value" "$C_RESET"
    elif [ "$required" = skip ]; then
        line '  %s·%s %-20s %snot picked%s\n' "$C_GRAY" "$C_RESET" "$label" "$C_GRAY" "$C_RESET"
    elif [ "$required" = 1 ]; then
        line '  %s✗%s %-20s %smissing%s\n' "$C_RED" "$C_RESET" "$label" "$C_RED" "$C_RESET"
        MISSING=1
    else
        line '  %s–%s %-20s %snot done%s\n' "$C_YELLOW" "$C_RESET" "$label" "$C_YELLOW" "$C_RESET"
        NOT_DONE=1
    fi
}

show_report() {
    MISSING=''; NOT_DONE=''
    path_now
    say 'What you have'
    row 'GlobalProtect' "$([ -d "$GP_APP" ] && echo installed)" "$(need vpn)"
    row 'Git' "$(xcode-select -p >/dev/null 2>&1 && git --version 2>/dev/null | sed 's/^git version //; s/ (.*//')" "$(need git)"
    pick_key || true
    row 'SSH key' "$([ -f "$KEY" ] && echo "${KEY/#$HOME/~}")" "$(need sshkey)"
    local ruser=''
    rosie_entry && [ -n "$RE_IS_ROSIE" ] && ruser=$RE_USER
    row 'Rosie config' "$([ -n "$ruser" ] && echo "user $ruser")" "$(need rosie)"
    if [ -z "$ruser" ]; then
        row 'Rosie login' '' 0
        row 'Jernel' '' 0
    elif rosie_probe; then
        row 'Rosie login' "$(rosie_login_ok && echo 'no password needed')" 0
        row 'Jernel' "$(ssh -n -o BatchMode=yes rosie "grep -qsF '$JERNEL_BIN' ~/.bashrc && echo 'on your PATH'" 2>/dev/null)" 0
    else
        row 'Rosie login' '' 0
        row 'Jernel' '' 0
        dim '  Rosie did not answer, so these were not tested. Connect GlobalProtect first.'
    fi
    row 'GitHub key' "$(github_login_ok && echo accepted)" 0
    row "Python $PYTHON_VERSION" "$(have uv && uv python find "$PYTHON_VERSION" >/dev/null 2>&1 && echo "uv $(uv --version | sed 's/^uv //; s/ .*//')")" "$(need python)"
    local py; py=$(python_bin || true)
    row '~/maic packages' "$([ -n "$py" ] && "$py" -c 'import torch, pandas; print("torch", torch.__version__.split("+")[0])' 2>/dev/null)" "$(need env)"
    row 'Jupyter kernel' "$([ -f "$HOME/Library/Jupyter/kernels/maic/kernel.json" ] && echo MAIC)" "$(need env)"
    # find_code must run in this shell, not inside $(...), so CODE_BIN is set below.
    find_code || true
    row 'VS Code' "$([ -n "$CODE_BIN" ] && "$CODE_BIN" --version 2>/dev/null | head -1)" "$(need vscode)"
    row 'VS Code extensions' "$(vscode_ok && echo 'Remote SSH, Python, Jupyter')" "$(need vscode)"
}

# ---------- main ----------
mkdir -p "$(dirname "$LOG")"
printf '\n===== MAIC setup run %s =====\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"
[ -n "$LOG_DIRECT" ] || exec > >(tee -a "$LOG") 2>&1

# One scratch folder for every download. It is removed when the script ends,
# whatever the reason (done, error, Ctrl-C). Only ~/maic-setup.log stays.
WORK=$(mktemp -d "${TMPDIR:-/tmp}/maic-setup.XXXXXX") || { fail 'Could not make a temp folder.'; exit 1; }
cleanup() {
    [ -n "${SPIN_BG_PID:-}" ] && kill "$SPIN_BG_PID" 2>/dev/null
    printf '\e[?25h' > "$TTY_OUT" 2>/dev/null  # show the cursor again
    if [ -n "$WORK" ] && [ -d "$WORK" ]; then rm -rf "$WORK"; fi
    [ -n "$LOG_DIRECT" ] || sleep 0.3  # let tee write the last lines
}
trap cleanup EXIT
trap 'printf "\n"; exit 130' INT

show_logo

if [ -n "$CHECK" ]; then
    show_report
    printf '\n'
    if [ -n "$MISSING" ]; then
        line '  %sSome tools are missing.%s To install them, paste:\n' "$C_RED" "$C_RESET"
        line '  %s\n\n' "$PASTE_LINE"
        exit 1
    fi
    line '  %sReady.%s\n\n' "$C_CYAN" "$C_RESET"
    exit 0
fi

line '  %sAbout 10 to 25 minutes on a new Mac.%s\n\n' "$C_GRAY" "$C_RESET"

# 1. What is already done? Done parts start unselected in the menu.
spin_bg_start 'Checking your Mac '
detect_all
spin_bg_stop

# 2. Rosie needs an account first. Ask before anything else.
if [ "$ST_rosie" = 'done' ]; then
    ROSIE_ACCESS=yes
elif [ -n "$YES" ]; then
    ROSIE_ACCESS=yes
else
    show_rosie
    printf '  Rosie is MSOE'"'"'s supercomputer. Setup can connect you to it,\n'
    printf '  but you need a Rosie account first.\n\n'
    ask reply 'Do you have a Rosie account? [y/N]'
    case "$reply" in
        y* | Y*) ROSIE_ACCESS=yes ;;
        *)
            ROSIE_ACCESS=no
            line '\n  %sOK, Rosie is off for now.%s How to get an account:\n  %s%s%s\n' "$C_YELLOW" "$C_RESET" "$C_GRAY" "$ROSIE_HELP" "$C_RESET"
            ;;
    esac
fi

# 3. The menu.
default_selection
if [ -z "$YES" ] && [ "$TTY_OUT" = /dev/tty ] && [ -r /dev/tty ]; then
    choose_items || { line '\n  Nothing changed.\n\n'; exit 0; }
fi
add_needed
selected_steps
if [ ${#STEPS[@]} -eq 0 ]; then
    line '\n  Nothing picked. Nothing changed.\n\n'
    exit 0
fi

# 4. Run the picked parts. Each part is one line; a live line shows progress.
STEP_TOTAL=${#STEPS[@]}
STEP_N=0
say 'Setting up'
[ -n "$ADDED_NOTE" ] && dim "${ADDED_NOTE#  }" && printf '\n'
for fn in "${STEPS[@]}"; do
    run_step "$(step_label "$fn")" "$fn"
done

# 5. One short ending.
printf '\n'
if [ ${#FAILED[@]} -gt 0 ]; then
    line '  %s✗ Not finished:%s %s\n' "$C_RED" "$C_RESET" "$(IFS=,; printf '%s' "${FAILED[*]}" | sed 's/,/, /g')"
    line '    Fix the problem above, then paste the setup line again. Done parts are skipped.\n'
elif [ ${#SKIPPED[@]} -gt 0 ]; then
    line '  %s– Almost ready.%s Skipped: %s\n' "$C_YELLOW" "$C_RESET" "$(IFS=,; printf '%s' "${SKIPPED[*]}" | sed 's/,/, /g')"
    line '    Connect GlobalProtect (or come to campus), then paste the setup line again.\n'
else
    line '  %s✓ Ready. Welcome to MAIC.%s\n' "$C_CYAN" "$C_RESET"
fi
NEXT=()
[ -n "$SEL_python$SEL_vscode" ] && NEXT+=('Open a new Terminal window, so code, uv, and python work.')
rosie_entry && [ -n "$RE_IS_ROSIE" ] && [ -n "$SEL_vscode$SEL_rosie" ] &&
    NEXT+=('To use Rosie in VS Code: click >< (bottom left), Connect to Host, rosie.')
[ "$ROSIE_ACCESS" = no ] && NEXT+=('For Rosie: get an account, then run setup again.')
if [ ${#NEXT[@]} -gt 0 ]; then
    line '\n  %sNext%s\n' "$C_WHITE" "$C_RESET"
    for n in "${NEXT[@]}"; do line '    %s\n' "$n"; done
fi
line '\n  %sLog: %s%s\n\n' "$C_GRAY" "${LOG/#$HOME/~}" "$C_RESET"
[ ${#FAILED[@]} -gt 0 ] && exit 1
exit 0
