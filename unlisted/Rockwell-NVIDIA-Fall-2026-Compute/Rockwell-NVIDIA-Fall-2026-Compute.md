# Compute for the Innovation Lab

[Back to the Innovation Lab overview](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026)

Teams can use Brev cloud GPUs, DGX Spark systems at MSOE and UWM, free model APIs on build.nvidia.com, and an in-person workstation at CSI. Request only what the project needs. A smaller GPU that stays busy is usually more useful than an expensive instance waiting for work.

## Brev

[NVIDIA Brev](https://brev.nvidia.com/) provides remote GPU machines. A running instance spends credits even when no code is running.

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <p><strong>Team access:</strong> [ Dan: add the invitation, login, and team-credit steps. ]</p>
  <p><strong>Credit allocation:</strong> [ Dan: confirm the credit amount per team and whether a team shares one Brev account or organization. ]</p>
</div>

### Start a launchable

1. Sign in to Brev with the account tied to your team credits.
2. Open the launchable that matches the task:
   - [Isaac Sim and Isaac Lab on an L40S](https://brev.nvidia.com/launchable/deploy/now?launchableID=env-35JP2ywERLgqtD0b0MIeK1HnF46)
   - [NeMoClaw agent orchestration](https://brev.nvidia.com/launchable/deploy/now?launchableID=env-3Azt0aYgVNFEuz7opyx3gscmowS)
   - [Cosmos video generation on C2.5T](https://brev.nvidia.com/launchable/deploy/now?launchableID=env-3DH5QPdLRWBABdW9Lxn4vQBK5mW)
3. Start the environment. Provisioning may take ten minutes.
4. If the launch screen does not update, open **Compute**. The running environment should appear there.
5. Open the environment card for connection, copy, and Secure Links instructions.

### Connect from a terminal

CLI access is recommended for the Isaac Sim launchable because it runs headless. Use the exact instance name shown by Brev.

```bash
brev shell <instance-name>
```

Copy a local file to the machine:

```bash
brev copy /path/to/local-file <instance-name>:/home/ubuntu
```

Copy a result back:

```bash
brev copy <instance-name>:/home/ubuntu/path/to/result /path/to/Downloads
```

You may install a coding agent on the instance. Keep API keys out of the repository and do not paste them into team chat.

### Stop versus delete

- **Stop** when work is paused. Compute billing stops after shutdown, and the disk remains so you can resume later.
- Stopped storage still costs a small amount.
- **Delete** only when the team no longer needs the instance. Deletion permanently removes its disk and files.
- Copy important code and results to the team repository or local storage before either action.

Make stopping the instance part of every work session. Do not leave it running overnight unless a job is actively using it and the team has budgeted for that run.

## Approximate Brev costs

These figures come from the planning documents and may change in the Brev console. Check the displayed rate before starting.

| Workload | Suggested hardware | Planning rate |
| --- | --- | --- |
| Cosmos Reason Edge inference | T4 | about $0.50/hour |
| AOI model training, Cosmos Reason Nano inference, or NuRec | L40S | about $2/hour |
| Isaac Sim synthetic data or Isaac Lab policy work | L40S | about $3/hour |
| Cosmos Reason Edge fine-tuning | 1× H100 | about $5/hour |
| Cosmos Reason Nano LoRA training | 4× A100 80 GB | about $8/hour |
| Cosmos video generation launchable | C2.5T | about $17/hour |

Do not choose a $17/hour environment for work that runs on a free API or a $2/hour L40S.

## Free model APIs

[build.nvidia.com](https://build.nvidia.com/) hosts model endpoints that can be tested without managing a GPU.

- [Create an NVIDIA API key](https://build.nvidia.com/settings/api-keys)
- [Cosmos 3 Nano generator](https://build.nvidia.com/nvidia/cosmos3-nano)
- [Cosmos 3 Nano reasoner](https://build.nvidia.com/nvidia/cosmos3-nano-reasoner)

API access is a good first test for in-context inspection or video reasoning. Check model limits before sending long videos or large batches.

## DGX Spark systems

Five DGX Spark systems are planned for MSOE and five for UWM. These are shared systems for local training, inference, Isaac workloads, and experiments that are a poor fit for Brev.

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <strong>[ Dan, Derek, Brett, and Shamar: add locations, login and network steps, scheduling rules, and the request contact after the systems are ready. This information may be released after kickoff. ]</strong>
</div>

Spark resources:

- [Isaac Lab and Isaac Sim on DGX Spark](https://build.nvidia.com/spark/isaac)
- [NeMoClaw on DGX Spark](https://build.nvidia.com/spark/nemoclaw)

## CSI workstation

CSI has a Windows 11 workstation with an RTX 6000 Ada-class GPU, Omniverse, Emulate3D, and a Nucleus server. It supports the Rockwell digital twin, synthetic-data generation, and NuRec work. This workstation is available only in person at CSI.

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <strong>[ Shamar: add the workstation reservation process and identify which datasets are loaded on it. ]</strong>
</div>

## What to request in the team plan

State the workload, expected hardware, estimated hours, and when the team needs it. For example:

> Train an AOI baseline on the vial crops using an L40S for about 10 hours in week two. We will run preprocessing locally and stop the Brev instance between training runs.

If the request is uncertain, say what quick test will determine it. Sponsors can help adjust the choice before credits are spent.
