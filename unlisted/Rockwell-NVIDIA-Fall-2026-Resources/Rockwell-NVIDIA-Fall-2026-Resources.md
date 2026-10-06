# Tools and Resources

[Back to the Innovation Lab overview](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026)

This is a reference list, not a required reading list. Begin with the dataset page, build a simple baseline, and open the resource that answers the next concrete question.

## AI coding tools

Student access to $100 in ChatGPT credits is planned. Other sponsor-funded agent access is still being confirmed.

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <p><strong>ChatGPT credits:</strong> [ Joe: confirm eligibility and add the claim instructions. ]</p>
  <p><strong>Other coding agents:</strong> [ Joe: confirm Codex or other sponsor credits. Derek: list the account setup students should complete. ]</p>
</div>

Agents can help inspect data, write a baseline, run experiments, and document a result. Review generated code, keep credentials outside the repository, and save enough information for another teammate to reproduce the run.

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

Use the [Compute guide](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute) for the Isaac Sim Brev launchable.

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
