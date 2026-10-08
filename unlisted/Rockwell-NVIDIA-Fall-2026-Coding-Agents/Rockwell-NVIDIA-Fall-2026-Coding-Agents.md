# Coding Agents

[Back to the Innovation Lab overview](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026)

Coding agents can help your team inspect data, write a baseline, run experiments, and document results. Review the code they write, keep credentials out of your repository, and save enough information for a teammate to reproduce each run.

## Start with Gemini in the Antigravity CLI (free)

**We have tested all of the problems with the Gemini 3.7 Flash models, and they were capable of solving each one, so we highly recommend starting here.**

Google's free terminal agent is the [Antigravity CLI](https://antigravity.google/download/) (`agy`). It replaced the Gemini CLI, which stopped serving free personal Google accounts on June 18, 2026, so use Antigravity rather than older Gemini CLI tutorials.

### 1. Install it

macOS, Linux, or a Brev instance:

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://antigravity.google/cli/install.ps1 | iex
```

See the [installation guide](https://antigravity.google/docs/cli/install/) for Windows Command Prompt and other options.

### 2. Sign in with a Google account

Run `agy` in your project folder. It opens your browser so you can sign in with a personal Google account.

On a remote machine over SSH, such as a Brev instance, `agy` prints a sign-in link instead. Open it on your own computer, sign in, and paste the code it shows back into the terminal.

### 3. Get more free usage as a student

The free Individual tier has basic weekly limits on agent work. Eligible US college students (18+) can get a year of **Google AI Pro free**, which raises those limits:

1. Go to [one.google.com/ai-student](https://one.google.com/ai-student) (or the [Gemini for Students page](https://gemini.google/us/students/)) while signed in to your personal Google account.
2. Verify your student status through SheerID with your school email.
3. Finish signing up. A payment method is required, and the plan renews at \$19.99/month after the free year unless you cancel, so set a reminder.

The offer must be redeemed by December 31, 2026. See Google's [student offer help page](https://support.google.com/googleone/answer/17422238) for the full terms.

For headless runs where a browser sign-in isn't possible, the Antigravity CLI can also use a Gemini API key from Google AI Studio; see [Using a Gemini API key](https://antigravity.google/docs/cli/install/).

## Requesting Claude or Codex plans

If your team needs more than the free tools, request Claude or Codex plans in your [team plan](https://dashboard.all-ai-network.org/s/V28NHK?d=1ff0683a-39d7-4302-a363-0835ca390c98), under **AI agent tools or credits requested**.

Based on our budget, we believe we may be able to give each team one or two \$100/month plans and a few \$20/month plans. **Please be explicit in what you're requesting:**

- which tool (Claude or Codex);
- which plan (\$100/month or \$20/month) and how many of each;
- which teammates will use them;
- what you will use them for, and why the free Gemini models aren't enough.

For example:

> One \$100/month Claude plan for our lead developer to build and iterate on the digital-twin data pipeline, and two \$20/month Codex plans for the teammates writing the training and evaluation code. We started with Gemini 3.7 Flash and want more capacity for long agent runs in weeks two and three.

## Using an agent on a GPU machine

You can install a coding agent directly on a Brev instance or another remote machine and work from the command line. The [Isaac Sim on Brev tutorial](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Resources) shows this workflow. Keep API keys out of the repository and do not paste them into team chat.
