# Tools and Resources

[Back to the Innovation Lab overview](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026)

This is a reference list, not a required reading list. Begin with the dataset page, build a simple baseline, and open the resource that answers the next concrete question.

## Physical AI tasks and tools

Use this table to match the task your team is working on to the tools and hardware that fit it. Costs are approximate Brev rates; check the rate shown in the Brev console before starting. "DGX Spark / GB10" means a UWM DGX Spark or an MSOE Dell GB10 on Rosie (see the [Compute guide](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute)).

| Task | Inputs and outputs | Tools | Hardware |
| --- | --- | --- | --- |
| Agent orchestration harness | | [NemoClaw](https://www.nvidia.com/en-us/ai/nemoclaw/) | [Brev launchable](https://brev.nvidia.com/launchable/deploy/now?launchableID=env-3Azt0aYgVNFEuz7opyx3gscmowS) (free)<br>[DGX Spark / GB10](https://build.nvidia.com/spark/nemoclaw) |
| In-context learning | Outputs: reasoning answers (AOI, defect, root-cause analysis, etc.) | Cosmos Reason 3 Edge (single image), Nano (multiple images) | [build.nvidia.com Reasoner](https://build.nvidia.com/nvidia/cosmos3-nano-reasoner), free ([API keys](https://build.nvidia.com/settings/api-keys))<br>DGX Spark / GB10<br>Brev (Edge on T4, about \$0.50/hr; Nano on L40S, about \$2/hr) |
| Automated inspection models (image-based) | | TAO, DEFT AOI, VisualChangeNet, Cosmos 3 | Training: Brev (RTX PRO 6000 preferred; L40S fallback about \$2/hr; not yet tested), DGX Spark / GB10<br>Inference: DGX Spark / GB10 |
| Synthetic data generation from a digital twin with Emulate3D | Outputs: images, videos, actions, labels, etc. | Isaac Sim / Omniverse / Emulate3D Connector | GPU workstation at CSI |
| Synthetic data generation from a digital twin | Outputs: images, videos, actions, labels, etc. | Isaac Sim / Omniverse | [Brev launchable](https://brev.nvidia.com/launchable/deploy/now?launchableID=env-35JP2ywERLgqtD0b0MIeK1HnF46) (select RTX PRO 6000 when available; L40S fallback about \$3/hr; see the tutorial below)<br>DGX Spark / GB10 |
| Synthetic data generation: GenAI image-to-image (I2I) inference | Inputs: images<br>Outputs: images | ChatGPT, Gemini, etc. | Cloud subscription for frontier models<br>DGX Spark / GB10 with [FLUX.2](https://www.canirun.ai/model/flux2-dev) |
| Synthetic data generation: GenAI T2I, I2V, T2V, I2T (not I2I) inference | Inputs: text, images<br>Outputs: videos, actions, labels, etc. | Cosmos Reason 3 Edge (single image), Nano (multiple images). Cosmos 3 does not do I2I. | DGX Spark / GB10<br>[build.nvidia.com Generator](https://build.nvidia.com/nvidia/cosmos3-nano), free ([API keys](https://build.nvidia.com/settings/api-keys))<br>[build.nvidia.com Reasoner](https://build.nvidia.com/nvidia/cosmos3-nano-reasoner), free ([API keys](https://build.nvidia.com/settings/api-keys)) |
| Synthetic data generation: GenAI T2I, I2V, T2V, I2T (not I2I) fine-tuning | Inputs: text, images<br>Outputs: videos, actions, labels, etc. | Cosmos Reason 3 Edge (single image), Nano (multiple images) | Training: DGX Spark / GB10 (Edge: SFT; Nano: LoRA only)<br>Brev (Edge on 1× H100, about \$5/hr; Nano on 4× A100 80 GB, about \$8/hr) |
| Synthetic data generation: GenAI V2I, V2V, V2T, V2A | Outputs: images, videos, actions, labels, etc. | Cosmos Reason 3 Edge (480p, 150 frames max), Nano (720p, 400 frames max) | Inference: DGX Spark / GB10; [build.nvidia.com Generator](https://build.nvidia.com/nvidia/cosmos3-nano), free ([API keys](https://build.nvidia.com/settings/api-keys)); [build.nvidia.com Reasoner](https://build.nvidia.com/nvidia/cosmos3-nano-reasoner), free ([API keys](https://build.nvidia.com/settings/api-keys)); [Brev launchable](https://brev.nvidia.com/launchable/deploy/now?launchableID=env-3DH5QPdLRWBABdW9Lxn4vQBK5mW) (C2.5T, about \$17/hr)<br>Training: DGX Spark / GB10 (Edge: SFT; Nano: LoRA only); Brev (Edge on 1× H100, about \$5/hr; Nano on 4× A100 80 GB, about \$8/hr) |
| Robot policy training | | Isaac Sim, Isaac Lab | [Brev launchable](https://brev.nvidia.com/launchable/deploy/now?launchableID=env-35JP2ywERLgqtD0b0MIeK1HnF46) (select RTX PRO 6000 when available; L40S fallback about \$3/hr; see the tutorial below)<br>[DGX Spark / GB10](https://build.nvidia.com/spark/isaac) |
| Reconstruct 3D scenes from images and lidar | | NuRec, Omniverse | Brev (L40S, about \$2/hr) |
| Time-series forecasting | | NVIDIA [Kumo-TS](https://github.com/NVIDIA/Kumo-TS) | Brev<br>DGX Spark / GB10 |

Abbreviations: T2I is text-to-image, I2V image-to-video, T2V text-to-video, I2T image-to-text, V2I video-to-image, V2V video-to-video, V2T video-to-text, V2A video-to-action, SFT supervised fine-tuning, and LoRA low-rank adaptation.

On Brev, prefer an RTX PRO 6000 for training and Isaac Sim when one is available. It costs roughly twice as much per hour as an L40S, but training may finish much faster. Record the GPU, runtime, and credits used so organizers can compare total cost and performance. See the [Compute guide](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute) for details.

## Tutorial: synthetic data generation with Isaac Sim on Brev

This tutorial covers Isaac Sim on Brev without Cosmos 3. The launchable runs headless, which means there is no GUI. You interact with Isaac Sim from the command line, and any visual output is saved as images or videos that you copy to your computer to view. Coding agents work well in this environment, so plan to use one on the instance.

1. Start the [Isaac Sim launchable](https://brev.nvidia.com/launchable/deploy/now?launchableID=env-35JP2ywERLgqtD0b0MIeK1HnF46).
   - This may take up to 10 minutes.
   - The launch screen may not update, so click **Compute** to check whether it is running.
2. Under **Compute**, you should see your running environment.

   <img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/brev-compute-running.webp" alt="Brev Compute page showing a running Isaac Sim launchable on an L40S" style="width: 100%; border-radius: 10px; margin: 14px 0;" />

3. Click the environment box to open more information on how to copy files and access the instance.
   - CLI access to the instance is recommended.
   - Log in, then open a local terminal or a code editor.
   - Copy files from a separate terminal; that is usually easiest.
4. Install your preferred coding agent from the command line. For example, Claude Code:

   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

5. Do the work you planned.
6. To share the instance, follow the instructions under **Secure Links**.
7. **Stop your instance when you are done so you do not use credits unnecessarily.**
   - Select **Stop**. Stopping takes a few minutes.
   - Stopping freezes the instance and should keep your data, but save everything important elsewhere to avoid accidental loss.
   - Stopping does not stop storage costs. Storage is usually cheap (cents per hour), but delete any instance you are completely done with.
   - Deleting an instance removes all of its data, so only delete it when you are sure you do not need the data.
   - To resume a stopped instance, select **Start**. It should be ready within a few minutes, from the point where you stopped it.

   <img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/brev-instance-stopped.webp" alt="A stopped Brev instance with Start and Delete buttons" style="width: 100%; border-radius: 10px; margin: 14px 0;" />

### Extra: robot arm digital twin

1. Copy the FANUC digital twin zip to the Isaac Sim instance. Use your own file path and the instance name shown in Brev:

   ```bash
   brev copy /path/to/fanuc_er4ia_sim.zip <instance-name>:/home/ubuntu
   ```

2. Unzip the file on the instance:

   ```bash
   unzip fanuc_er4ia_sim.zip
   ```

3. Ask the agent to build the digital twin and render a video of it picking up screws. For example:

   > Set up the digital twin in Isaac Sim that is located in fanuc_er4ia_sim and generate a video of it picking up the screws from the table. Tell me where the video is located.

   This took Claude about five minutes to set up the twin and render the video.
4. Copy the video to your computer, watch it, and prompt the agent to update the twin:

   ```bash
   brev copy <instance-name>:/home/ubuntu/fanuc_er4ia_sim/demo.mp4 /path/to/Downloads
   ```

## AI coding tools

Agents can help inspect data, write a baseline, run experiments, and document a result. Review generated code, keep credentials outside the repository, and save enough information for another teammate to reproduce the run.

See the **[Coding agents guide](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Coding-Agents)** to start free with Gemini in the Antigravity CLI, set up student access, and request Claude or Codex plans in your team plan.

## In-context learning

In-context learning gives a general vision-language model examples and instructions in the prompt instead of first training a dedicated model. For automated optical inspection, the context often contains examples of acceptable and defective parts.

It is useful for a fast baseline and rare classes. Large foundation models can be slower and more expensive than a small trained model, so they may not fit a high-throughput edge deployment.

- [NVIDIA guide to vision-language prompt engineering](https://developer.nvidia.com/blog/vision-language-model-prompt-engineering-guide-for-image-and-video-understanding/)
- [Few-shot visual inspection paper](https://arxiv.org/abs/2502.09057)
- [Paper code](https://github.com/ia-gu/Vision-Language-In-Context-Learning-Driven-Few-Shot-Visual-Inspection-Model)
- [Cosmos model matrix](https://docs.nvidia.com/cosmos/latest/cosmos3/model_matrix.html)
- [Cosmos 3 quickstart](https://docs.nvidia.com/cosmos/latest/cosmos3/quickstart_guide.html)

## Industrial inspection

- [Vision AI for industrial inspection overview](https://www.nvidia.com/en-us/on-demand/session/gtcdc25-dc51122/)
- [TAO 7.0.1 getting started](https://docs.nvidia.com/tao/tao-toolkit/7.0.1/text/getting_started.html)
- [Visual ChangeNet documentation](https://docs.nvidia.com/tao/tao-toolkit/latest/text/cv_finetuning/pytorch/visual_changenet/index.html)
- [TAO DEFT AOI agent workflow](https://github.com/NVIDIA/skills/blob/main/skills/tao-run-deft-aoi/SKILL.md)
- [TAO vision-language model fine-tuning](https://docs.nvidia.com/tao/tao-toolkit/latest/text/vlm_finetuning/index.html)

The DEFT AOI workflow is a useful structure even when a team uses different tools: evaluate, inspect failure cases, add or generate targeted examples, retrain, and gate the new version against a fixed test.

## Digital twins and synthetic data

- [What is a digital twin?](https://www.nvidia.com/en-us/glossary/digital-twin/)
- [Rockwell and NVIDIA factory digital twins](https://www.nvidia.com/en-us/on-demand/session/gtc24-s62623/)
- [Assembling digital twins with Omniverse and OpenUSD](https://docs.nvidia.com/learning/physical-ai/assembling-digital-twins/latest/index.html)
- [Isaac Sim scene-based synthetic dataset generation](https://docs.isaacsim.omniverse.nvidia.com/latest/replicator_tutorials/tutorial_replicator_scene_based_sdg.html)
- [Replicator and synthetic-data introduction](https://www.nvidia.com/en-us/on-demand/session/omniverse2020-om1786/)
- [Three workflows for improving vision AI with synthetic data](https://blogs.nvidia.com/blog/vision-ai-agent-skills-omniverse-metropolis/)
- [Physical AI Data Factory augmentation pipeline](https://github.com/NVIDIA/paidf-augmentation)

See the Isaac Sim on Brev tutorial above, and the [Compute guide](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute) for Brev accounts and costs.

## Video and standard operating procedures

- [SOP monitoring tutorial](https://www.nvidia.com/en-us/on-demand/session/gtc25-dlit72753/)
- [SOP Monitoring Blueprints](https://github.com/NVIDIA/sop-monitoring-blueprints)
- [SOP training workflow](https://github.com/NVIDIA/sop-monitoring-blueprints/blob/main/microservices/sop-training-bp/README.md)
- [SOP inference workflow](https://github.com/NVIDIA/sop-monitoring-blueprints/blob/main/microservices/sop-inference-bp/README.md)

These resources are most relevant when the project must understand a sequence rather than classify one frame.

## NuRec and real-to-sim

- [NuRec for robotics](https://docs.nvidia.com/nurec/robotics/index.html)
- [Monocular neural reconstruction](https://docs.nvidia.com/nurec/robotics/neural_reconstruction_mono.html)
- [Neural volume rendering in Isaac Sim](https://docs.isaacsim.omniverse.nvidia.com/latest/assets/usd_assets_nurec.html)
- [Large-scale 3D Gaussian splatting session](https://www.nvidia.com/en-us/on-demand/session/gtc26-dlit81757/)

## Agents and factory data

- [NeMoClaw](https://www.nvidia.com/en-us/ai/nemoclaw/)
- [NeMoClaw quickstart](https://docs.nvidia.com/nemoclaw/latest/user-guide/openclaw/get-started/quickstart)
- [Create a workflow with NeMo Agent Toolkit](https://docs.nvidia.com/nemo/agent-toolkit/latest/get-started/tutorials/create-a-new-workflow.html)
- [Factory Operations FOX Blueprint](https://blogs.nvidia.com/blog/factory-operations-fox-blueprint-ai-brain/)
- [FactoryTalk Optix OPC UA tutorial](https://help.optix.cloud.rockwellautomation.com/1.4.1.7/en/tutorials/opc-ua/opc-ua-tutorial.html)
- [NVIDIA Kumo time-series models](https://github.com/NVIDIA/Kumo-TS)

The FOX material provides architecture context but not a complete implementation for this testbed. FactoryTalk or OPC UA access must be approved; teams should not connect to plant systems on their own.

## FANUC and robotics

- [Official FANUC ROS 2 driver quickstart](https://fanuc-corporation.github.io/fanuc_driver_doc/main/docs/quick_start/quick_start.html)
- [FANUC manipulator assets in Isaac Sim](https://docs.isaacsim.omniverse.nvidia.com/latest/assets/usd_assets_robots_manipulator.html)
- [Isaac Sim ROS 2 manipulation tutorial](https://docs.isaacsim.omniverse.nvidia.com/latest/ros2_tutorials/robot_control/tutorial_ros2_manipulation.html)
- [FANUC Tech Transfer](https://techtransfer.fanucamerica.com/)

## Before adding another tool

Write down:

1. What failure in the current baseline the tool should address.
2. What input and output it requires.
3. What compute and access it needs.
4. How the team will compare it with the baseline.

If those answers are unclear, keep the current pipeline simple and ask a mentor.
