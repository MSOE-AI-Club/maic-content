<br>
<a href='/learning-tree?node=85' style='
    background-color: #31313a;
    color: gainsboro;
    padding: 6px 16px;
    border: none
    border-radius: 4px;
    text-transform: uppercase;
    font-family: "Roboto", sans-serif;
    font-size: 1em;
    font-weight: bold;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;'
>
  View in Learning Tree
</a>

<br>
<br>
<br>

<div style='
  position: relative;
  padding: 10px; 
  border-radius: 5px;
  background-color: rgba(0, 0, 0, 0.85); 
  border: 4px solid transparent;
  background-image: linear-gradient(90deg, rgba(0, 0, 0, 0.85), rgba(0, 0, 0, 0.85)), linear-gradient(90deg, gold, orange, gold);
  background-origin: border-box;
  background-clip: padding-box, border-box;
'>

<svg width='200' height='50' style='display: block; margin-bottom: 5px;'>
  <text x='0' y='35' font-size='35' font-family='Arial' font-weight='bold' fill='gold'>
    Why Read?
    <animate attributeName='fill' values='gold; orange; gold' dur='3s' repeatCount='indefinite' />
  </text>
</svg>

<p style='color: white; margin-top: 2px;'>Every MAIC workshop needs the same tools: the VPN, Git, VS Code, Python, and a working connection to Rosie. This article gives you one line to paste that sets up all of it. It also explains what each piece is, and how to install any one piece by hand if something breaks.</p>

</div>

<br/>

<br/>

## Before You Start

Read this section before you paste anything. The script stops to ask you questions, so have these ready first.

### What you need

- **Rosie access.** The script sets up your Rosie login, so you need a Rosie account first. It asks "Do you have a Rosie account?" before it does anything. If you do not have an account, answer **n**, then read [ROSIE Pt1: Getting Access](/library?nav=Articles&article=1-getting-rosie-access) and come back when Dr. Retert's email arrives. The script sets up everything else now and turns off the Rosie steps. Run it again later to add Rosie.
- **Your MSOE password.** The script asks for it one time, to copy your key to Rosie.
- **A GitHub account.** Make one at [github.com/signup](https://github.com/signup) with any email. The script opens this page for you if you say you have no account.
- **Your laptop password.** On Windows, you click Yes on "Allow this app to make changes?". On a Mac, macOS asks for it to install GlobalProtect and the Command Line Tools.
- **10 to 25 minutes and a good network.** Most of the time is downloads. Plug in your laptop. The script installs GlobalProtect and asks you to connect it before the Rosie steps.

### What it asks you

| When | Question | Why |
| --- | --- | --- |
| Start | Do you have a Rosie account? | Rosie steps need an account. Answer **n** if you have none; those steps are turned off. |
| Start | The menu: pick what to set up | See **The menu** below. Press Enter to accept the default choice. |
| Git | Your name and email | Git puts them on every commit. |
| Rosie | Your MSOE username | The part before `@msoe.edu`. It goes in the SSH config. |
| VPN | Connect GlobalProtect, then press Enter | Rosie is only reachable on campus or through the VPN. |
| Rosie | Your MSOE password, one time | To copy your SSH key to Rosie. After this, no more passwords. |
| GitHub | Add the key in the browser, then press Enter | GitHub needs your public key once. The script copies it to your clipboard. |
| Windows only | "Allow this app to make changes?" | Click Yes. GlobalProtect and Git install for the whole machine. |
| Mac only | Your Mac password | macOS asks for it to install GlobalProtect and the Command Line Tools. |

It skips anything you already have. If a step fails, the script keeps going, prints what failed at the end, and tells you to paste the line again after you fix it.

### The menu

Before it installs anything, the script checks what you already have and shows a menu:

```
  Pick what to set up

  › [x] Git
    [ ] SSH key                        done
    [x] GlobalProtect VPN
    [x] Rosie
    ...

  ↑↓ move   space pick   enter start   q quit
```

- Parts marked **done** start unselected. Select one again to run it again.
- Parts that are not done start selected. On a new laptop, press **Enter** to install everything.
- If you pick a part that needs another part, the script picks that one too. For example, Rosie needs the SSH key and the VPN.
- While a step runs, one line shows a spinner, a bar for the whole run, and what is happening (for example the download percent). When the step ends, that line becomes one short result, for example `✓ Git  2.47.1`.

You can read the script before you run it: [windows.ps1](https://msoe-ai-club.github.io/maic-content/setup/windows.ps1) and [mac.sh](https://msoe-ai-club.github.io/maic-content/setup/mac.sh) are plain text.

## Run the Script

Open a terminal and paste the line for your computer. Press Enter. Answer the questions from the table above.

**Windows** (open **PowerShell**: press the Windows key, type `PowerShell`, press Enter. Do not use "Run as Administrator"):

```powershell
irm https://msoe-ai-club.github.io/maic-content/setup/windows.ps1 | iex
```

**Mac** (open **Terminal**: press Cmd+Space, type `Terminal`, press Enter):

```bash
bash -c "$(curl -fsSL https://msoe-ai-club.github.io/maic-content/setup/mac.sh)"
```

When it ends, go to **After the Script** below.

## What It Installs

| Tool | What it is | Why MAIC uses it | Where it goes |
| --- | --- | --- | --- |
| **GlobalProtect** | MSOE's VPN app | Rosie is only reachable from the campus network. GlobalProtect puts your laptop on that network from anywhere. | Windows: `C:\Program Files\Palo Alto Networks\GlobalProtect`. Mac: `/Applications/GlobalProtect.app`. Portal is preset to `vpn.msoe.edu`. |
| **Git** | Version control | Every workshop repo is on GitHub. | Windows: Git for Windows (includes Git Bash). Mac: Apple's Command Line Tools. |
| **SSH key** | A key pair that logs you in without a password | One key works for both Rosie and GitHub. | `~/.ssh/id_ed25519` (private, never share) and `~/.ssh/id_ed25519.pub` (public). No passphrase. If you already have a key (`id_ed25519`, `id_ecdsa`, or `id_rsa`), the script uses it and makes no new one. |
| **Rosie SSH config** | A short text block that names Rosie, plus a `rosie` command | Type `rosie` to log in. `ssh rosie` and VS Code's "Connect to Host: rosie" work because of it. | `~/.ssh/config`. If you already have an entry for `dh-mgmt2.hpc.msoe.edu`, the script reuses its user and key. The command: Windows `%LOCALAPPDATA%\Microsoft\WindowsApps\rosie.cmd`, Mac `~/.local/bin/rosie` |
| **Rosie key copy** | Your public key in Rosie's `authorized_keys` | No password after this. | On Rosie: `~/.ssh/authorized_keys` |
| **Jernel** | MAIC's command that starts a Jupyter kernel on a Rosie GPU node | Run notebooks in VS Code on Rosie's GPUs. See [Running VSCode Jupyter Notebooks on Rosie](/library?nav=Articles&article=6-jernel). | One PATH line in your Rosie `~/.bashrc` |
| **GitHub SSH key** | Your public key on your GitHub account | `git clone`, `push`, and `pull` with no password. | github.com > Settings > SSH and GPG keys |
| **uv** | A fast Python package and version manager | It installs Python itself and makes environments in seconds. | `~/.local/bin/uv` |
| **Python 3.12** | The Python the club uses | Workshops are written against 3.12. | Managed by uv. |
| **~/maic environment** | A project folder with a virtual environment | numpy, pandas, matplotlib, seaborn, scikit-learn, scipy, requests, tqdm, jupyter, and PyTorch (CPU). Big models run on Rosie, not your laptop. | `~/maic/pyproject.toml` and `~/maic/.venv` |
| **MAIC Jupyter kernel** | A kernel named "MAIC (Python 3.12)" | Pick it in any notebook in VS Code. | Windows: `%APPDATA%\jupyter\kernels\maic`. Mac: `~/Library/Jupyter/kernels/maic` |
| **VS Code** | The editor | Local work and remote work on Rosie in one window. | Windows: per-user install. Mac: `/Applications`. |
| **VS Code extensions** | Remote - SSH, Python, Jupyter | Remote - SSH opens Rosie in VS Code. Python and Jupyter run notebooks. | Inside VS Code |
| **VS Code settings** | `remote.SSH.connectTimeout: 120` and the default interpreter | Rosie can be slow to answer the first time. 120 seconds avoids the common timeout error. | VS Code `settings.json` (only keys you did not set yourself) |

## After the Script

1. Open a **new** terminal window. New commands (`code`, `uv`, `python`) are only found in new windows.
2. Test Rosie. Connect GlobalProtect if you are off campus. Then, on Windows or Mac, type:

```bash
rosie
```

   You land on Rosie with no password prompt. Type `exit` to come back.

3. Open VS Code. Click the blue `><` icon in the bottom-left corner, choose **Connect to Host**, choose **rosie**. Pick **Linux** if it asks for the platform.
4. Make a notebook in VS Code (File > New File > Jupyter Notebook). Click **Select Kernel** in the top right and pick **MAIC (Python 3.12)**.
5. Test GitHub (Windows and Mac):

```bash
ssh -T git@github.com
```

   It greets you by your GitHub username.

To see what is installed at any time, run the check mode. It changes nothing:

**Windows (PowerShell):**

```powershell
$env:MAIC_SETUP_CHECK = 1; irm https://msoe-ai-club.github.io/maic-content/setup/windows.ps1 | iex
```

**Mac (Terminal):**

```bash
MAIC_SETUP_CHECK=1 bash -c "$(curl -fsSL https://msoe-ai-club.github.io/maic-content/setup/mac.sh)"
```

Bring that output to a meeting if something does not work. The script also writes a log to `~/maic-setup.log`.

## Rosie Off Campus

Rosie answers only from MSOE's network. Off campus, in the ITC, or on "MSOE Guest" Wi-Fi, you must connect **GlobalProtect** first:

1. Open GlobalProtect (taskbar on Windows, menu bar on Mac).
2. Portal: `vpn.msoe.edu`. Click Connect. Sign in with your MSOE login.
3. Now `ssh rosie` and VS Code's Remote - SSH work.

The script installs GlobalProtect for you. If you need to do it by hand, download it from [vpn.msoe.edu](https://vpn.msoe.edu/global-protect/getsoftwarepage.esp) and read [Global Protect](/library?nav=Articles&article=global-protect).

## Install One Piece by Hand

Use these when the script cannot finish a step, or when you only want one tool. Each block is the same thing the script does.

### GlobalProtect VPN

- **Windows:** download [GlobalProtect64.msi](https://vpn.msoe.edu/global-protect/msi/GlobalProtect64.msi) (or [GlobalProtectARM64.msi](https://vpn.msoe.edu/global-protect/msi/GlobalProtectARM64.msi) on an ARM laptop), open it, and install. In the app, type the portal `vpn.msoe.edu`.
- **Mac:** download [GlobalProtect.pkg](https://vpn.msoe.edu/global-protect/msi/GlobalProtect.pkg), open it, and install. In the app, type the portal `vpn.msoe.edu`.

### Git

**Windows:**

```powershell
winget install --exact --id Git.Git
```

**Mac** (Apple's Command Line Tools include Git; a dialog opens, click Install):

```bash
xcode-select --install
```

Or download it from [git-scm.com/download/win](https://git-scm.com/download/win). Then, on Windows and Mac:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

### SSH key

Same command on Windows (PowerShell) and Mac (Terminal). Press Enter at every question for a key with no passphrase:

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

### Rosie SSH config

Open `~/.ssh/config` (Windows: `notepad $HOME\.ssh\config`; Mac: `nano ~/.ssh/config`) and add this block. Replace `yourname` with your MSOE username.

**Windows and Mac** (same block on both):

```
Host rosie ROSIE
    HostName dh-mgmt2.hpc.msoe.edu
    User yourname@ad.msoe.edu
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking accept-new

Host dh-node*
    HostName %h
    User yourname@ad.msoe.edu
    IdentityFile ~/.ssh/id_ed25519
    ProxyJump rosie
    StrictHostKeyChecking accept-new
```

More detail: [Connecting to Rosie in VSCode via SSH](/library?nav=Articles&article=6-rosie-ssh).

### Copy your key to Rosie (no more passwords)

Connect GlobalProtect first. You type your MSOE password one last time.

**Windows** (there is no `ssh-copy-id` on Windows):

```powershell
type $HOME\.ssh\id_ed25519.pub | ssh rosie "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

**Mac:**

```bash
ssh-copy-id rosie
```

Test on both: type `rosie`. You land on Rosie with no password. Type `exit` to come back.

### Jernel on Rosie

One command, run from your laptop (Windows and Mac). It adds the MAIC tools folder to your PATH on Rosie:

```bash
ssh rosie /data/ai_club/util/setup
```

Then read [Running VSCode Jupyter Notebooks on Rosie](/library?nav=Articles&article=6-jernel).

### GitHub SSH key

Copy your public key to the clipboard:

**Windows (PowerShell):**

```powershell
Get-Content $HOME\.ssh\id_ed25519.pub | Set-Clipboard
```

**Mac (Terminal):**

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

Open [github.com/settings/ssh/new](https://github.com/settings/ssh/new), paste the key, give it a title like "MAIC laptop", and click **Add SSH key**. Test (Windows and Mac):

```bash
ssh -T git@github.com
```

More detail: [GitHub SSH Keys](/library?nav=Articles&article=GitHub-SSH-Keys).

### uv and Python 3.12

**Windows:**

```powershell
irm https://astral.sh/uv/install.ps1 | iex
```

**Mac:**

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Open a new terminal. Then, on Windows and Mac:

```bash
uv python install 3.12 --default
```

If `python` opens the Microsoft Store on Windows, turn off the `python.exe` and `python3.exe` aliases in **Settings > Apps > Advanced app settings > App execution aliases**.

### The ~/maic environment and the MAIC kernel

Same commands on Windows and Mac (on Windows, `~` works in PowerShell too):

```bash
mkdir -p ~/maic
cd ~/maic
uv init --bare --name maic --python 3.12
uv add jupyter ipykernel numpy pandas matplotlib seaborn scikit-learn scipy requests tqdm torch
uv run python -m ipykernel install --user --name maic --display-name "MAIC (Python 3.12)"
```

To add a package later: `cd ~/maic` then `uv add <package>`. More about environments: [VSC Pt4: Using an Environment in VSCode](/library?nav=Articles&article=4-vscode-environments).

### VS Code

- **Windows:**

```powershell
winget install --exact --id Microsoft.VisualStudioCode --scope user
```

- **Mac:** download from [code.visualstudio.com/download](https://code.visualstudio.com/download), unzip, and drag **Visual Studio Code** into **Applications**.

Open a new terminal. Then install the extensions, on Windows and Mac:

```bash
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
```

If `code` is not found on a Mac, open VS Code, press Cmd+Shift+P, and run **Shell Command: Install 'code' command in PATH**.

Then in VS Code press Ctrl+, (Windows) or Cmd+, (Mac), search `Remote.SSH: Connect Timeout`, and set it to `120`.

## If Something Breaks

| What you see | What to do |
| --- | --- |
| `Rosie did not answer` or `Rosie is not reachable` | Connect GlobalProtect (portal `vpn.msoe.edu`) or join campus Wi-Fi. Paste the setup line again. Done steps are skipped. |
| `Permission denied` when copying the key to Rosie | Wrong MSOE password or username. Your username is the part before `@msoe.edu`. Check `~/.ssh/config`. If you have no Rosie account yet, read [ROSIE Pt1: Getting Access](/library?nav=Articles&article=1-getting-rosie-access). |
| `GitHub did not accept the key yet` | On [github.com/settings/ssh/new](https://github.com/settings/ssh/new), the key must start with `ssh-ed25519`. Paste the whole line. |
| `Could not install uv` or `Could not reach astral.sh` | Your network blocks it or you are offline. Try a phone hotspot, then paste the line again. |
| `Could not download` VS Code or GlobalProtect | Same as above. Or install that one tool by hand from the list above. |
| Mac: the Command Line Tools dialog never finishes | Open the dialog from the Dock, finish it, then paste the line again. |
| Windows: `winget was not found` | Install **App Installer** from the Microsoft Store, or let the script use the direct installers (it does this on its own). |
| Windows: `running scripts is disabled` | You pasted the line into the wrong place, or your laptop blocks scripts. The paste line uses `irm ... \| iex`, which needs no script policy. If it still fails, use a personal laptop or install each tool by hand. |
| Windows: `python` opens the Microsoft Store | Turn off the `python.exe` and `python3.exe` aliases in **Settings > Apps > Advanced app settings > App execution aliases**. |
| VS Code: Remote - SSH times out | The script sets the timeout to 120 seconds. If you set it yourself before, press Ctrl+, (Cmd+, on Mac), search `Remote.SSH: Connect Timeout`, set `120`. |
| VS Code: no "MAIC (Python 3.12)" kernel | Run the kernel command from the environment section above, then reload VS Code. |
| Something else | Run the check mode (above) and bring the output to a meeting, or message an eboard member. |

## Related Articles

- [ROSIE Pt1: Getting Access](/library?nav=Articles&article=1-getting-rosie-access) and [ROSIE Pt2: First Login](/library?nav=Articles&article=2-first-login)
- [Connecting to Rosie in VSCode via SSH](/library?nav=Articles&article=6-rosie-ssh)
- [Running VSCode Jupyter Notebooks on Rosie (Jernel)](/library?nav=Articles&article=6-jernel)
- [Global Protect](/library?nav=Articles&article=global-protect)
- [GitHub SSH Keys](/library?nav=Articles&article=GitHub-SSH-Keys) and [Git Commands](/library?nav=Articles&article=Git-Commands)
- [VSC Pt1: How to Use Visual Studio Code](/library?nav=Articles&article=1-how-use-vscode)
