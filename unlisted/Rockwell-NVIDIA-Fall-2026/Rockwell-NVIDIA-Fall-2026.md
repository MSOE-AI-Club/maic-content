# 🏭 Rockwell Automation + NVIDIA Innovation Lab: Physical AI for the Factory Floor

**In collaboration with [Rockwell Automation](https://www.rockwellautomation.com/en-us.html), [NVIDIA](https://www.nvidia.com/en-us/), the [MSOE AI-Club](https://msoe-maic.com), and [UWM's Connected Systems Institute (CSI)](https://uwm.edu/csi/)**

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <strong style="color: #f59e0b;">Working draft.</strong> Items in <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[amber brackets]</span> are placeholders to be completed before this goes to students.
</div>

<div style="border: 2px dashed #a855f7; border-radius: 10px; padding: 16px 20px; margin: 20px 0;">
  <h3 style="margin-top: 0;">📝 Team Sign-Up</h3>
  <p style="margin: 4px 0 12px;">One person per team signs up the whole team. Solo entries are welcome, and AI-Club can place you on a team.</p>
  <p style="margin: 4px 0;"><strong>Team sign-up:</strong> <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ TODO: sign-up link ]</span></p>
  <p style="margin: 4px 0;"><strong>Submission form (team plan due end of day Wed, Oct 14):</strong> <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ TODO: submission link ]</span></p>
  <p style="margin: 4px 0;"><strong>Event page:</strong> <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ TODO: event page link ]</span></p>
  <p style="margin: 4px 0;"><strong>Slack workspace:</strong> <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Slack invite link to add ]</span></p>
</div>

## Welcome

We're glad you're here. For the next four weeks, your team will work on real problems from a test factory production line, using the same AI tools companies use today.

The hackathon is run by four partners: **NVIDIA, Rockwell Automation, MSOE, and UWM's Connected Systems Institute**. The challenges aren't made up for a class. They come from an actual production line in CSI's factory testbed, and engineers from Rockwell and NVIDIA will guide your team and see what you build.

This hackathon is about solving problems. That matters more than your major or how much you already know. **You don't need to be an expert in AI, engineering, or computer science to do well.** The tools handle much of the technical work, and your mentors are there when you get stuck. The best teams keep working a problem until they solve it.

Start with **the challenges**, then work through the **first-week checklist**.

## Schedule and Key Dates

| Date | Milestone | Where / Notes |
| --- | --- | --- |
| **Thursday, October 8** | 🎉 **Kickoff** | Rockwell Automation HQ (1201 S 2nd St, Milwaukee, WI 53204), 4:00–6:00 PM. Transportation provided from each campus. |
| **Wednesday, October 14** | 📄 **Team plan due** (end of day) | Submit on the MSOE site (see **Team Sign-Up**). |
| **Thursday, November 5** | 🏆 **Finals** | UWM <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ TODO: specific building and time ]</span> |

## The Challenges and Your Data

You'll work on problems from an actual factory line. Pick **one of three challenges** built around the vial production process and robots in CSI's factory testbed. The goal in every challenge is the same: **make a process measurably better, then show it working in real life.**

> **This is real factory data.** You get images and camera feeds from the factory line, plus the tools and digital twins to build with.

### Challenge 1: Final Vial Inspection 🔍

A robot sorts finished vials into a good tray and a scrap tray, but some defective ones slip into the good tray: missing or crooked caps, bent tubes, or missing tubes. An overhead camera watches the good tray.

- **Your goal:** catch the defective vials before they leave the good tray, and flag what needs rework or scrapping.
- **Good fit if you like:** working with images and spotting defects.
- **What you get:** sample images of good and defective vials, labeled and unlabeled; a labeling tool to build your own training set; and a digital twin you can use to generate more training images.

### Challenge 2: Fluid Mixing 🧪

A single nozzle fills vials with colored fluid by recipe. Because one nozzle handles every color, leftover fluid from the last fill can affect the next one, and fill amounts can come out wrong.

- **Your goal:** detect color and fill problems, and point to the likely cause where you can.
- **Good fit if you like:** comparing camera views to figure out what caused a problem.
- **What you get:** camera views of the vials being filled and of the color tanks, with matched timestamps so you can line up what happened where. No equipment data needed.

### Challenge 3: Grasping and Sorting 🦾

A FANUC robot arm picks up and sorts objects on a table.

- **Your goal:** train the arm to grasp and sort reliably, then push it as far as you can with harder objects, smarter sorting, or better grips.
- **Good fit if you like:** hands-on work with robots and simulation, including parts you design and 3D-print.
- **What you get:** a digital twin of the setup to train and test in, two overhead cameras and a wrist camera, and grippers you can customize with fingers you design and print.

### Choosing Your Challenge

If you're not sure which to pick, choose the one that's most interesting to your team. None of them require experience you don't already have, and your mentors can help you shape your approach.

**Start with one challenge and solve it well.** You're welcome to take on another after that, but a strong solution to one beats a partial attempt at several.

### Getting More Data

The data you're given is enough to build a solution. If you want more:

| ✅ You can | ❌ You can't |
| --- | --- |
| Visit the CSI testbed to see the factory line and robots running (schedule ahead) | Move or re-aim the cameras |
| Collect your own data with a setup that doesn't interfere with the line (schedule ahead) | Change anything on the PLCs or safety systems |
| Ask CSI to collect specific data for you (not guaranteed, so ask early and be specific) | Add anything physical that could interfere with or damage the line |

**In short: look, don't touch.** To schedule a visit or a data request, contact **Shamar Webster** at CSI ([webste63@uwm.edu](mailto:webste63@uwm.edu)).

### Where to Find Your Data and Tools

Each challenge's starter data and tools are posted at <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ location and link to add ]</span>, with instructions for downloading and using them.

## Your First Week

Your first week is for getting set up and planning. It ends with your **team plan, due end of day Wednesday, October 14**. Work through this list with your team in the first few days:

- [ ] **Confirm your team.** Make sure everyone knows who's on it and how you'll reach each other.
- [ ] **Finalize your team name.** You'll use it on Slack, your plan, and at finals.
- [ ] **Pick the challenge you'll start with.** See **The Challenges and Your Data**.
- [ ] **Get set up.** Accounts, your team's Brev account, your challenge data, and Slack. See **Getting Set Up**.
- [ ] **Find your mentors in Slack.** Know who to ask for what before you hit your first problem.
- [ ] **Write and submit your team plan.** 1–2 pages, due end of day Wednesday, October 14. See **Your Team Plan**.

Once your plan is in, start building.

## Getting Set Up

Work through this in order. Setup takes most teams an hour or two, so **do it together early in week one**, not the night before anything is due. If you get stuck, ask in Slack.

### 1. Your Accounts

You sign in with your university email. Most tools use your UWM or MSOE account, so you shouldn't need separate logins.

<span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Derek and Dan: list which tools use university sign-in and any that need a separate account, with steps. Note anything to set up before kickoff, such as an NVIDIA developer account. ]</span>

### 2. Computing Power ⚡

These projects need GPU power to train and test your models. You have two options:

- **Brev (cloud GPUs), one account per team.** Brev is NVIDIA's service for renting GPU machines over the internet, so you can work from an ordinary laptop. Your team gets one Brev account with a set amount of credits for the four weeks. **The meter runs whenever a machine is on, so shut it down when you're done for the day.**
  - <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Dan: step-by-step for logging into Brev and reaching team credits; screenshots help ]</span>
- **On-site machines at CSI and MSOE (DGX Sparks and a GB10).** For work that needs more than the cloud provides. They're limited and shared, so arrange time with CSI and MSOE rather than showing up.
  - <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Dan, Derek, Brett, Shamar: which work belongs on-site vs. cloud, how many machines, how to request time, and who to contact ]</span>

### 3. Your Challenge Data and Tools

Download your challenge's data, confirm you can open it, and try the tools before you start building. If anything doesn't work, raise it in Slack early.

<span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Derek: per challenge, where each item lives and how to access it ]</span>

- **Vial inspection:** labeled and unlabeled images, the labeling tool, and how to launch the digital twin.
- **Fluid mixing:** the vial and tank camera feeds, and how the matched timestamps are provided.
- **Grasping and sorting:** the digital twin and the camera views.
- **Isaac Sim:** Launchable link and a one-line quickstart, if teams will use it.

### 4. AI Coding Tools 🤖

We're working to give teams access to AI coding assistants to help you build faster.

<span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Joe: confirm sponsor funding. Derek: how students get access. If not confirmed in time, list free tools instead. ]</span>

### 5. Getting Help 💬

Slack is where you ask questions and reach mentors throughout the hackathon. It's your first stop when you're stuck.

<span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Brett: how to join the Slack channel, plus "who to ping for what" (compute/Brev, challenge data/tools, testbed/data requests) ]</span>

> ✅ **You're set up when** your team has its accounts, your Brev account works, you've downloaded and opened your challenge data, and you've joined Slack.

## Your Team Plan

Your first week ends with a short team plan. **This is a tool for your team, not a graded assignment.** Writing it forces the useful conversations early, and it lets us line up the compute, data, and mentor support you'll need before you get stuck.

Your plan should cover:

- **Team and roles:** who's on the team and who's leading what. Assign work based on strengths, not by splitting it evenly.
- **Your challenge:** which one you're starting with, and a sentence on why it fits your team.
- **Your approach:** a short paragraph on how you'll tackle it. It's expected to change as you learn.
- **Data and tools:** what you'll use from what's provided, and anything extra you expect to need (like a testbed visit or specific data).
- **What you need from us:** compute, mentor help, or access, and when.
- **Milestones:** a rough week-by-week plan, including what "done" looks like for your first challenge.
- **Risks or unknowns:** what you're unsure or worried about. Naming these early tells your mentors where to help.

**Format:** 1–2 pages. Short and clear beats long.
**Due:** end of day Wednesday, October 14.
**Submit:** <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ TODO: submission link ]</span>. Your plan is private to your team and the organizers. Organizers will review every plan and follow up with your team.

## Your Team

Each team has a mentor and **1–12 members** (12 is the maximum; solo teams are allowed). AI-Club uses these guidelines when helping form teams:

- **Team composition:** a balance of beginners and advanced members.
- **Team synergy:** teams formed around shared interests, so members can inspire and support each other.
- **Mentor guidelines:** mentors set up regular meetings with an agenda to keep project direction consistent, and share resources from our [Learning Tree](https://msoe-maic.com/learning-tree).
- [Advice from previous mentors](https://docs.google.com/document/d/1W9UHUgx3ffMUuentD1hKcLEQg_RXqYVfBQJYC9-aFfE/edit?tab=t.0)

## Event Prizes 🏆

<span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ Prize amounts and categories to confirm with Rockwell & NVIDIA ]</span>

- **1st Place:** <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ $ ]</span> + 15 AI Club Points 🥇
- **2nd Place:** <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ $ ]</span> + 10 AI Club Points 🥈
- **3rd Place:** <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ $ ]</span> + 5 AI Club Points 🥉
- **All participants:** +10 AI Club Points & LinkedIn Certificate

## What the Judges Are Looking For

Use this to understand what judges value so you know what to aim for as you build. **It's directional, not a scorecard.** The judging panel will confirm specific criteria closer to finals. <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ weighting, if any, to confirm with judges ]</span>

- **Does it solve the real problem?** Catch the defective vials, spot the color or fill errors, or complete the grasp and sort. Judges want to see it working, not just a description.
- **Does it hold up in real conditions?** This is physical AI, so what matters is whether it works in real life, not just in a clean test. Run it on real or realistic data and on the actual equipment when you can. Be honest about where it struggles.
- **Is your approach sound?** A sensible method, good use of the data and tools provided, and clear reasons for your choices.
- **Is the result clear?** A factory operator or a judge should understand what your solution does and what it found, quickly.
- **How well did your team work?** Real progress over four weeks: what you tried, what you learned when something didn't work, and how you shared the effort.
- **Creativity and ambition.** Credit for teams that try something harder or more original, even if it isn't perfect.

> 💡 **A finished, working solution beats an ambitious one that doesn't run.** If you have to choose in your last week, make what you have work reliably before you add anything more.

At Rockwell & NVIDIA, we don't believe any discovery is a failure, even if that discovery is that a problem is unsolvable. Significant effort and learning are valued.

## Key Contacts

For most questions, **start in Slack**. Use this list when you need a specific person:

- **Testbed visits and data requests:** Shamar Webster (UWM-CSI), [webste63@uwm.edu](mailto:webste63@uwm.edu)
- **Compute and Brev:** post in <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ #compute-requests — channel name to confirm ]</span> on Slack
- **Challenge and technical questions:** post in Slack, where Rockwell and NVIDIA mentors answer
- **Website or Slack access problems:** Brett Storoe (AI Club President), [storoeb@msoe.edu](mailto:storoeb@msoe.edu). 
- **UWM-CSI:** Joe Hammond, [jahamann@uwm.edu](mailto:jahamann@uwm.edu)
- **Rockwell Automation:** <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ contacts to add ]</span>
- **NVIDIA:** <span style="background: #f59e0b; color: #000; padding: 0 4px; border-radius: 3px;">[ contacts to add ]</span>

---

*This Innovation Lab is made possible through our partnership with **Rockwell Automation**, **NVIDIA**, and **UWM's Connected Systems Institute**.*
