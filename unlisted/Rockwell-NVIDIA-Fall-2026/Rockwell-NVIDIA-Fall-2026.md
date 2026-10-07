<style>.article > h3:nth-of-type(2) { display: none; }</style>

## Physical AI for the Factory Floor

[Rockwell Automation](https://www.rockwellautomation.com/en-us.html), [NVIDIA](https://www.nvidia.com/en-us/), the [MSOE AI Club](https://msoe-maic.com/), and UWM's [Connected Systems Institute (CSI)](https://uwm.edu/csi/) are running a four-week physical AI hackathon. Teams will work with data and equipment from CSI's manufacturing testbed, then show a working solution at the finals.

You do not need prior manufacturing or AI experience. You do need a team that is willing to test ideas, measure results, and explain what it learned.

<details open style="border: 2px solid #7c3aed; border-radius: 10px; padding: 14px 18px; margin: 22px 0;">
  <summary style="cursor: pointer; font-size: 1.5rem; font-weight: 700;">Join the Innovation Lab</summary>
  <div style="margin-top: 14px;">
    <p>Each student creates an account and joins or creates a team.</p>
    <p><a href="https://dashboard.all-ai-network.org/j/L36HEH" target="_blank" rel="noopener noreferrer"><strong>Sign up and manage your team</strong></a></p>
    <p><a href="https://dashboard.all-ai-network.org/s/V28NHK" target="_blank" rel="noopener noreferrer"><strong>Submit your team plan</strong></a> by 11:59 PM CT on Wednesday, October 14.</p>
    <p><a href="https://dashboard.all-ai-network.org/e/innovation-lab-fall-2026-059658" target="_blank" rel="noopener noreferrer">Open the event workspace</a></p>
    <p><strong>Use the same email address associated with your university if possible.</strong> After you join a team, connect GitHub from your profile so the dashboard can send your team repository invitation.</p>
    <h3>How teams work on the ALL AI Network</h3>
    <p>Teams, repositories, and submissions for this lab are managed through the <a href="https://dashboard.all-ai-network.org/e/innovation-lab-fall-2026-059658" target="_blank" rel="noopener noreferrer">ALL AI Network</a> event workspace.</p>
    <ul>
      <li><strong>MSOE students:</strong> your teams have already been created. Create an account and join your team from the sign-up link above.</li>
      <li><strong>UWM students:</strong> create an account, then create your team in the workspace and invite your teammates.</li>
      <li><strong>Connect GitHub:</strong> once you connect GitHub from your profile, you are automatically invited to your team's repository. No one has to add you by hand.</li>
      <li><strong>One place for every project:</strong> all team repositories live in one place, so Rockwell Automation and NVIDIA can view your work as it progresses, and your final submission links straight to it.</li>
    </ul>
  </div>
</details>

<details open style="border: 1px solid #64748b; border-radius: 10px; padding: 14px 18px; margin: 22px 0;">
  <summary style="cursor: pointer; font-size: 1.5rem; font-weight: 700;">What is the factory testbed?</summary>
  <div style="margin-top: 14px;">
    <p>CSI operates a high-mix, low-volume demonstration plant built with Rockwell Automation hardware. The production line creates vials filled with mixed-color fluid from custom recipes. Several robots move the vials through filling, inspection, and final placement.</p>
    <p>CSI also has a separate FANUC robot setup that moves and sorts blocks and other objects. That robot is <strong>not connected to the vial production line</strong>. It is the physical system and digital-twin setup used for Dataset 3 discussed below.</p>
    <img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/csi-testbed-timelapse.gif" alt="Time-lapse overview of the CSI manufacturing testbed" style="width: 100%; border-radius: 10px; margin: 14px 0;" />
  </div>
</details>

<details style="border: 1px solid #64748b; border-radius: 10px; padding: 14px 18px; margin: 22px 0;">
  <summary style="cursor: pointer; font-size: 1.5rem; font-weight: 700;">About our sponsors</summary>
  <div style="margin-top: 14px;">
    <h3>Rockwell Automation</h3>
    <p><a href="https://www.rockwellautomation.com/en-us.html"><strong>Rockwell Automation</strong></a> builds the industrial automation and control systems that run production lines across manufacturing, from the controllers on the plant floor to the FactoryTalk software that connects production data and workflows. Its Emulate3D tools let engineers model and test a manufacturing system as a digital twin before they change physical equipment.</p>
    <p>Rockwell's customers are under pressure to produce more product variants, in smaller batches, with fewer experienced people on the floor. A line that changes recipes or products often cannot wait weeks for a new inspection program or robot routine. For Rockwell, AI is valuable when it makes those changeovers faster and more reliable, and when operators can understand and trust what it is doing. Results that hold up on real equipment, with clear limits, matter more than results that only work in a clean demo.</p>
    <h3>NVIDIA</h3>
    <p><a href="https://www.nvidia.com/en-us/"><strong>NVIDIA</strong></a> provides the accelerated computing and physical AI platforms used to train, simulate, and run AI in the real world: computer vision, Isaac Sim and Omniverse for simulation and synthetic data, robotics, and AI agents.</p>
    <p>NVIDIA sees physical AI, meaning AI that perceives, reasons about, and acts on the physical world, as the next major wave of computing. Factories are where that shift becomes concrete. Teams can train a model, test it on a simulated version of the line, and then run it on the real cell. Manufacturing is also where the open questions are hardest: limited labeled data, constant product changes, and the need for systems that work safely beside people and machines.</p>
    <h3>Why they are working together</h3>
    <p>Rockwell brings deep knowledge of industrial operations and the systems manufacturers already run. NVIDIA brings the compute and simulation tools to move AI from experimentation into production. Together, they are bringing NVIDIA's simulation and AI technology into Rockwell's digital twin and design tools, so manufacturers can design, test, and improve automated systems before touching the physical line.</p>
    <h3>Why this matters</h3>
    <p>Most manufacturers have not yet adopted AI on the factory floor. Only about 3% of manufacturers used AI for automated inspection in the 2020 Annual Business Survey. A NIST survey estimated that defective products cost US discrete manufacturers $32–58 billion each year. The gap between what AI can do and what is actually running in plants is large, and much of it comes down to reliability, setup time, and trust.</p>
    <p>This lab asks teams to close a small piece of that gap: pick one real process on CSI's testbed, make it measurably better, and show the result working. The <a href="https://msoe-maic.com/"><strong>MSOE AI Club</strong></a> and UWM-CSI are bringing these tools and this testbed to student teams through this Innovation Lab.</p>
  </div>
</details>

<details open style="border: 1px solid #64748b; border-radius: 10px; padding: 14px 18px; margin: 22px 0;">
  <summary style="cursor: pointer; font-size: 1.5rem; font-weight: 700;">The three datasets</summary>

We recommend that teams focus on building one strong solution around a single idea or dataset rather than spreading effort across several half-finished ideas. This is a recommendation, not a requirement, but it is the approach that has worked best for teams in past Innovation Labs.

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
    <p>Use a digital twin and multiple cameras to make a standalone FANUC arm grasp and sort objects more reliably. This robot is separate from the vial production line.</p>
    <a href="https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Grasping-Sorting">Open dataset 3</a>
  </div>
</div>

### Related guides

These three guides cover what every team needs beyond the datasets. Read them before you submit your team plan.

- **[Compute: Brev, DGX Spark, and build.nvidia.com](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute):** how to get GPU power for your project. It covers Brev cloud GPUs and ready-made launchables (including Isaac Sim), the DGX Spark systems at MSOE and UWM, free model APIs on build.nvidia.com, and the workstation at CSI. Brev credits are spent whenever an instance is running, so read this before you start one.
- **[Collect and test your own data](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Data-Collection):** what you can and cannot do at the CSI testbed. It explains how to request a visit or extra data, how to collect your own data safely, how to use digital twins for synthetic data, and how to schedule a supervised test of your finished system on the real equipment.
- **[Tools and resources](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Resources):** a reference list of AI coding tools, in-context learning with vision-language models, NVIDIA Cosmos, and other tools worth knowing. Start with a simple baseline, then use this page when you hit a specific question.

</details>

<details open style="border: 1px solid #64748b; border-radius: 10px; padding: 14px 18px; margin: 22px 0;">
  <summary style="cursor: pointer; font-size: 1.5rem; font-weight: 700;">Schedule</summary>

| Date | Milestone | Details |
| --- | --- | --- |
| Thursday, October 8 | Kickoff | Rockwell Automation HQ, 1201 S 2nd St, Milwaukee, 4:00–6:00 PM. Transportation is provided from both campuses. |
| Wednesday, October 14 | Team plan due | Submit by 11:59 PM CT through the [team plan submission form](https://dashboard.all-ai-network.org/s/V28NHK). |
| Sunday, November 1 | Final submission due | About a five-minute video, a one-page summary, your repository, and references. |
| Thursday, November 5 | Finals | MSOE Diercks Hall, 5:00–8:00 PM. More details to come. |

</details>

<details style="border: 1px solid #64748b; border-radius: 10px; padding: 14px 18px; margin: 22px 0;">
  <summary style="cursor: pointer; font-size: 1.5rem; font-weight: 700;">First week and team plan</summary>

### First-week checklist

- [ ] Create an All AI Network account with the email address associated with your AI Club points.
- [ ] Create or join a team and settle on a team name.
- [ ] Connect your GitHub account and accept the team repository invitation.
- [ ] Choose dataset(s).
- [ ] Download the data and confirm that everyone who needs it can open it.
- [ ] Review the [compute guide](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute) and request what your team expects to use.
- [ ] [Join the hackathon Slack workspace](https://join.slack.com/t/rockwellnvidi-wq82211/shared_invite/zt-4bp05nsn9-UW3afFtM9wjzWtZiQoJBHg), open `#hackathon-announcements`, and find the channel for your dataset.
- [ ] Submit the [team plan](https://dashboard.all-ai-network.org/s/V28NHK) by Wednesday, October 14.

### Team plan

**[Submit your team plan here](https://dashboard.all-ai-network.org/s/V28NHK)** by 11:59 PM CT on Wednesday, October 14.

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

</details>

<details style="border: 1px solid #64748b; border-radius: 10px; padding: 14px 18px; margin: 22px 0;">
  <summary style="cursor: pointer; font-size: 1.5rem; font-weight: 700;">Final submission</summary>

**[Submit your final project here](https://dashboard.all-ai-network.org/s/V28NHK)** by 11:59 PM CT on Sunday, November 1.

Each team submits:

- a video of about five minutes;
- a one-page project summary;
- a link to the team repository;
- references and credits for data, models, code, and tools.

The Nov. 5 finals include live presentations and prizes.

</details>

<details style="border: 1px solid #64748b; border-radius: 10px; padding: 14px 18px; margin: 22px 0;">
  <summary style="cursor: pointer; font-size: 1.5rem; font-weight: 700;">Prizes</summary>

<div style="border-radius: 14px; padding: 2px; margin: 18px 0; background: linear-gradient(135deg, #76b900, #7c3aed, #cd163f);">
  <div style="border-radius: 12px; padding: 24px 20px; background: #0d0d10; text-align: center;">
    <div style="font-size: 0.95rem; letter-spacing: 0.15em; text-transform: uppercase; color: #a3a3a3;">Total prize pool</div>
    <div style="font-size: 3.5rem; font-weight: 800; line-height: 1.1; margin: 6px 0; background: linear-gradient(90deg, #76b900, #a855f7); -webkit-background-clip: text; background-clip: text; color: transparent;">$5,000 in cash</div>
  </div>
</div>

<div style="display: grid; gap: 16px; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); margin: 18px 0;">
  <div style="border: 1px solid #76b900; border-radius: 12px; padding: 20px; text-align: center; background: rgba(118, 185, 0, 0.08);">
    <div style="font-size: 1.6rem; font-weight: 800; color: #76b900;">RTX 5080</div>
    <div style="color: #d4d4d4;">NVIDIA GeForce graphics card</div>
  </div>
  <div style="border: 1px solid #76b900; border-radius: 12px; padding: 20px; text-align: center; background: rgba(118, 185, 0, 0.08);">
    <div style="font-size: 1.6rem; font-weight: 800; color: #76b900;">RTX 5070</div>
    <div style="color: #d4d4d4;">NVIDIA GeForce graphics card</div>
  </div>
  <div style="border: 1px solid #a855f7; border-radius: 12px; padding: 20px; text-align: center; background: rgba(168, 85, 247, 0.08);">
    <div style="font-size: 1.6rem; font-weight: 800; color: #c084fc;">Sponsor swag</div>
    <div style="color: #d4d4d4;">from Rockwell Automation and NVIDIA</div>
  </div>
</div>

**Details to come** on how the cash is split between first, second, and third place, and on the additional award categories and prizes.

</details>

<details style="border: 1px solid #64748b; border-radius: 10px; padding: 14px 18px; margin: 22px 0;">
  <summary style="cursor: pointer; font-size: 1.5rem; font-weight: 700;">Judging rubric</summary>

Your solution will be judged on how effectively it addresses a real process on the testbed, the evidence that it works, and how well it fits the way a high-mix, low-volume line actually runs. Technical execution matters, but judges will weigh current effectiveness and how quickly the solution adapts to new products more heavily than sheer complexity.

### 1. Problem Understanding & Approach (30%)

- Does the team clearly define the process problem it is solving, and why it matters on the line?
- Is the solution directly relevant to that problem?
- Does the approach show innovative thinking?

### 2. Effectiveness & Accuracy (20%)

- How well does the solution perform on real or realistic data from the testbed?
- Is there evidence to support its reliability, such as test results, trial logs, benchmarks, or a live demo?
- Does the team report where the solution fails and how it behaves in those cases?

### 3. Industry Fit & Practicality (40%)

- Is this something Rockwell Automation, NVIDIA, and their manufacturing customers could realistically use?
- Does it fit how a plant already operates, and could an operator understand and act on what it reports?
- **Novel vs. known approaches:** Both have advantages and drawbacks. Teams should show why their chosen approach is effective compared with the alternative.

### 4. Adaptability & Configuration Speed (10%)

- On a high-mix, low-volume line, products and recipes change often. How quickly can the solution be configured for a new product, recipe, defect type, or object?
- Can it adapt from a handful of examples, for instance through **in-context learning** with a vision-language model or few-shot prompting, instead of a full retraining cycle?
- How much engineering effort would a changeover take, and could plant staff do it without the original team?

Adaptability is only 10% of the score. A solution that is fast to reconfigure but does not work well will not score highly.

**Total possible score: 100%**

</details>

<details style="border: 1px solid #64748b; border-radius: 10px; padding: 14px 18px; margin: 22px 0;">
  <summary style="cursor: pointer; font-size: 1.5rem; font-weight: 700;">Getting help</summary>

This year, teams will not be assigned one exact mentor or given a long directory of sponsor contacts. [Join the hackathon Slack workspace](https://join.slack.com/t/rockwellnvidi-wq82211/shared_invite/zt-4bp05nsn9-UW3afFtM9wjzWtZiQoJBHg), then ping the people below in the channel that matches the question. This keeps answers visible to other teams. Email is available if you do not get a response in Slack or would rather follow up directly.

### Recommended Slack channels to create

- `#hackathon-announcements` — organizer updates, deadlines, and schedule changes.
- `#hackathon-general` — general event questions and help finding the right channel.
- `#dataset-1-vial-inspection` — questions and findings about final vial inspection.
- `#dataset-2-fluid-mixing` — questions and findings about Station 3 and fluid recipes.
- `#dataset-3-grasping-sorting` — questions about the standalone FANUC robot and digital twin.
- `#data-and-testbed-requests` — additional data, CSI visits, on-site collection, and live testing.
- `#compute-questions` — Brev credits, instances, DGX Spark access, and compute troubleshooting.

### Who to ping

- **More data, CSI visits, or physical testing:** Ping **Shamar Webster** in `#data-and-testbed-requests`. This includes requesting more production-line data, visiting CSI to collect your own data, and arranging a supervised test of your tool. Email fallback: [webste63@uwm.edu](mailto:webste63@uwm.edu).
- **Questions about the line or datasets:** Ping **Brett Storoe, Dr. Derek Riley, or Tanner Cellio** in the relevant dataset channel. These are the first contacts for non-critical questions about the equipment, dataset context, or problem your team is trying to understand. Email fallbacks: [storoeb@msoe.edu](mailto:storoeb@msoe.edu) and [driley@nvidia.com](mailto:driley@nvidia.com).
- **Brev or compute:** Ping **Dan Schneider** in `#compute-questions`, or email [danschneider@nvidia.com](mailto:danschneider@nvidia.com).
- **Website, signup, team, or Slack access:** Ping **Brett Storoe** in `#hackathon-general`, or email [storoeb@msoe.edu](mailto:storoeb@msoe.edu).

For a critical-path issue that is blocking the team, say that clearly in the first line of the Slack message and include what you tried, the error, and when you need the issue resolved.

</details>
