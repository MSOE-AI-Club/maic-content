# Rockwell Automation + NVIDIA Innovation Lab

## Physical AI for the Factory Floor

Rockwell Automation, NVIDIA, the MSOE AI Club, and UWM's [Connected Systems Institute (CSI)](https://uwm.edu/csi/) are running a four-week physical AI hackathon. Teams will work with data and equipment from CSI's manufacturing testbed, then show a working solution at the finals.

You do not need prior manufacturing or AI experience. You do need a team that is willing to test ideas, measure results, and explain what it learned.

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <strong>Working page.</strong> Amber notes mark details that organizers still need to supply.
</div>

<div style="border: 2px solid #7c3aed; border-radius: 10px; padding: 18px 20px; margin: 22px 0;">
  <h3 style="margin-top: 0;">Join the Innovation Lab</h3>
  <p>Each student creates an account and joins or creates a team. Teams may have 1–12 members.</p>
  <p><a href="https://dashboard.all-ai-network.org/j/L36HEH" target="_blank" rel="noopener noreferrer"><strong>Sign up and manage your team</strong></a></p>
  <p><a href="https://dashboard.all-ai-network.org/s/V28NHK" target="_blank" rel="noopener noreferrer"><strong>Submit your team plan</strong></a> by 11:59 PM CT on Wednesday, October 14.</p>
  <p><a href="https://dashboard.all-ai-network.org/e/innovation-lab-fall-2026-059658" target="_blank" rel="noopener noreferrer">Open the event workspace</a></p>
  <p><strong>Use the same email address associated with your AI Club points.</strong> After you join a team, connect GitHub from your profile so the dashboard can send your team repository invitation.</p>
</div>

## What is the factory testbed?

CSI operates a high-mix, low-volume demonstration plant built with Rockwell Automation hardware. The line produces colored stacked cubes and vials filled with mixed-color fluid. Four FANUC robots move products through the process.

Rockwell builds industrial automation and control systems used by manufacturers. Its FactoryTalk software connects production information and workflows, while Emulate3D creates digital models of manufacturing systems. NVIDIA provides the accelerated computing and physical AI tools teams will use for vision, simulation, synthetic data, and robotics.

Only about 3% of manufacturers used AI for automated inspection in the 2020 Annual Business Survey. A NIST survey estimated that defective products cost US discrete manufacturers $32–58 billion each year. This lab asks teams to show where physical AI can make one real process better.

<img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/csi-testbed-timelapse.gif" alt="Time-lapse overview of the CSI manufacturing testbed" style="width: 100%; border-radius: 10px; margin: 14px 0;" />

## The three datasets

Choose one dataset to start. A strong, tested solution on one dataset is better than three unfinished ideas.

<div style="display: grid; gap: 16px; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); margin: 18px 0;">
  <div style="border: 1px solid #64748b; border-radius: 10px; padding: 16px;">
    <h3 style="margin-top: 0;">Dataset 1: Final Vial Inspection</h3>
    <p>Find missing caps, crooked caps, damaged vials, and unexpected empty positions after the robot fills a fixture.</p>
    <a href="https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Vial-Inspection">Open dataset 1</a>
  </div>
  <div style="border: 1px solid #64748b; border-radius: 10px; padding: 16px;">
    <h3 style="margin-top: 0;">Dataset 2: Fluid Mixing Station 3</h3>
    <p>Use synchronized camera views to detect fill and color problems caused by recipes and fluid carryover.</p>
    <a href="https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Fluid-Mixing">Open dataset 2</a>
  </div>
  <div style="border: 1px solid #64748b; border-radius: 10px; padding: 16px;">
    <h3 style="margin-top: 0;">Dataset 3: Grasping and Sorting</h3>
    <p>Use a digital twin and multiple cameras to make a FANUC arm grasp and sort objects more reliably.</p>
    <a href="https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Grasping-Sorting">Open dataset 3</a>
  </div>
</div>

Related guides:

- [Compute: Brev, DGX Spark, and build.nvidia.com](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute)
- [Collect and test your own data](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Data-Collection)
- [Tools and resources](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Resources)

## Schedule

| Date | Milestone | Details |
| --- | --- | --- |
| Thursday, October 8 | Kickoff | Rockwell Automation HQ, 1201 S 2nd St, Milwaukee, 4:00–6:00 PM. Transportation is provided from both campuses. |
| Wednesday, October 14 | Team plan due | Submit by 11:59 PM CT through the team submission form. |
| Sunday, November 1 | Final submission due | About a five-minute video, a one-page summary, your repository, and references. |
| Thursday, November 5 | Finals | UWM. <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Brett: add the building and time. ]</span> |

## First-week checklist

- [ ] Create an All AI Network account with the email address associated with your AI Club points.
- [ ] Create or join a team and settle on a team name.
- [ ] Connect your GitHub account and accept the team repository invitation.
- [ ] Choose one dataset.
- [ ] Download the data and confirm that everyone who needs it can open it.
- [ ] Review the [compute guide](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute) and request what your team expects to use.
- [ ] Join Slack and find your mentors. <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Brett: add the Slack invite and channel names. ]</span>
- [ ] Submit the team plan by Wednesday, October 14.

## Team plan

The plan is a short resource request, not a contract or graded paper. Anyone on the team can submit it, and any teammate can update the same team submission before the deadline. Organizers and sponsor mentors will use it to line up compute, data, and technical support.

The form asks for:

- your team name and members;
- the dataset or combination of datasets you plan to use;
- a short description of the problem you plan to solve;
- data you need beyond what is already provided, and why;
- the compute you expect to use: Brev, an MSOE or UWM DGX Spark, the CSI workstation, or build.nvidia.com;
- AI-agent credits or tools you need;
- the type of mentor support you want;
- questions for the organizers.

Plans may change once teams examine the data. Keep the first submission short and specific enough for sponsors to understand what help would be useful.

## Final submission

By Sunday, November 1, each team submits:

- a video of about five minutes;
- a one-page project summary;
- a link to the team repository;
- references and credits for data, models, code, and tools.

The Nov. 5 finals include live presentations and prizes.

## Prizes and judging

Prizes include cash, RTX 5080 and RTX 5070 GPUs, and sponsor swag. Planned award categories include:

- most impactful;
- most innovative;
- best use of in-context learning;
- best presentation;
- most scalable.

<span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Joe: confirm prize amounts and the final award categories with Rockwell and NVIDIA. ]</span>

Judges will look for a solution that addresses the actual process, works on real or realistic data, reports meaningful measurements, and is understandable to an operator. They will also consider the quality of the team's technical choices, testing, collaboration, and explanation of failed attempts.

A smaller system that works reliably is more useful than an ambitious demo that cannot run.

## Contacts

- Testbed visits and data requests: Shamar Webster, UWM-CSI, [webste63@uwm.edu](mailto:webste63@uwm.edu)
- UWM-CSI: Joe Hammond, [jahamann@uwm.edu](mailto:jahamann@uwm.edu)
- NVIDIA and team-plan questions: Derek Riley, [driley@nvidia.com](mailto:driley@nvidia.com)
- Website or Slack access: Brett Storoe, [storoeb@msoe.edu](mailto:storoeb@msoe.edu)
- Rockwell Automation: <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Joe: add the Rockwell contacts. ]</span>
- Additional NVIDIA contacts: <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Brett: add the confirmed NVIDIA mentors. ]</span>

For technical questions during the event, start in Slack so the answer is visible to other teams.
