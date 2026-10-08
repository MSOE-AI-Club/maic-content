# Dataset 1: Final Vial Inspection

[Back to the Innovation Lab overview](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026)

## The problem

The production line already inspects each vial from the side. It sends vials that pass to a good fixture and detected defects to a scrap fixture. That inspection does not see every cap defect. A cap can also move after inspection, and the robot can miss a pick, damage a vial, or place it incorrectly without noticing.

<img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/fanuc-cell.webp" alt="Final vial inspection station at the CSI testbed" style="width: 100%; border-radius: 10px; margin: 14px 0;" />

This dataset comes from an overhead camera at the final station. Build a system that checks visible vial defects and fixture occupancy after each placement. The priority is to stop defects from getting through. In judging, a missed defect matters more than a false alarm.

<img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/vial-overview.webp" alt="Overview of the final vial inspection station and fixtures" style="width: 100%; border-radius: 10px; margin: 14px 0;" />

## How the fixtures fill

The camera sees two fixtures:

- **G** is the good fixture.
- **S** is the scrap fixture.
- Each fixture has 30 fixed, numbered positions.
- The robot fills the rightmost column from top to bottom, then moves one column to the left.

A complete good order has 30 acceptable vials. An empty position inside the expected fill pattern can mean the robot missed a placement. Empty positions at the end of the pattern may simply be waiting for later vials, so a robust solution should use placement count or an order-complete signal when one is available.

## Labels

The class label describes one target position, not the whole camera image. Crops contain neighboring vials, so make sure the prediction follows the numbered target aperture.

| Label | Meaning |
| --- | --- |
| `pass` | The visible cap and vial body appear acceptable. It does not confirm properties hidden from the camera. |
| `missing_cap` | A vial is present, but its mouth is open. Do not confuse the transparent vial body with an empty fixture hole. |
| `crooked_cap` | The cap is visibly tilted or not seated. A leaning vial by itself is not enough. |
| `damaged_vial` | The target vial body is visibly damaged. Overlapping transparent bodies may require the full scene for context. |
| `no_vial` | The target aperture is empty. Whether that is an error depends on fill progress. |

<img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/vial-crops-in-context.webp" alt="Labeled vial crops shown in the context of the full camera image" style="width: 100%; border-radius: 10px; margin: 14px 0;" />

<img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/vial-class-examples.webp" alt="Examples of the five vial inspection labels" style="width: 100%; border-radius: 10px; margin: 14px 0;" />

## What is provided

- full overhead camera images;
- labeled and unlabeled position crops;
- fixture coordinates and position identifiers;
- a browser-based labeling tool;
- a digital twin for generating additional images.

The labeling tool lets you select an image and fixture, click a numbered position, inspect its crop in scene context, edit the class, add an observation, and mark it reviewed. Use Previous and Next to move through positions. Export the review JSON when the pass is complete.

<img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/vial-labeling-tool.webp" alt="Browser labeling tool with the full scene and selected vial crop" style="width: 100%; border-radius: 10px; margin: 14px 0;" />

## Get the data

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <p><strong>Dataset download:</strong> <a href="TODO-DOWNLOAD-LINK" target="_blank" rel="noopener noreferrer">Download the Final Vial Inspection dataset</a> [ TODO: list the folders included. ]</p>
  <p><strong>For MSOE students on Rosie:</strong> the dataset is already downloaded at <code>TODO/ROSIE/PATH</code> [ TODO: add any group-permission instructions. ]</p>
  <p><strong>Digital twin:</strong> [ TODO: add the download and launch instructions. ]</p>
</div>

After downloading, open several full images and their corresponding crops. Confirm that the filenames or metadata let you map every crop back to its source image, fixture, and numbered position.

## Tools that fit

- [TAO Toolkit](https://docs.nvidia.com/tao/tao-toolkit/7.0.1/text/getting_started.html) for training and adapting vision models.
- [Visual ChangeNet](https://docs.nvidia.com/tao/tao-toolkit/latest/text/cv_finetuning/pytorch/visual_changenet/index.html) for lightweight image classification.
- [DEFT AOI workflow](https://github.com/NVIDIA/skills/blob/main/skills/tao-run-deft-aoi/SKILL.md) for an evaluate, diagnose, augment, retrain, and gate loop.
- Cosmos Reason for in-context inspection using example images without first training a small dedicated model.
- Isaac Sim and Replicator for synthetic images and labels from the digital twin.

See [Compute](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute) before launching training or simulation.

## Starter approach: TAO Toolkit with Visual ChangeNet

This path trains a small [Visual ChangeNet](https://docs.nvidia.com/tao/tao-toolkit/latest/text/cv_finetuning/pytorch/visual_changenet/visual_changenet_classify.html) classification model with a coding agent and the [NVIDIA TAO Skill Bank](https://github.com/NVIDIA-TAO/tao-skill-bank). You do not need to memorize TAO commands: the Skill Bank gives your agent model-specific instructions, data checks, and container launch steps. Your job is to describe the experiment clearly, inspect the results, and decide what to try next.

Visual ChangeNet compares an inspection image with a **golden image**, a known-good reference of what the vial should look like, and outputs `PASS` or `NO_PASS`. The TAO workflow expects you to already have image pairs. You will not have enough real images at the start, so generate them with the digital twin first (step 4).

### 1. Start a GPU instance

If you are using Brev, start with an **L40S** and select **AWS** as the cloud environment. Pick an option that offers Start/Stop so you keep your storage between sessions. See the [Compute guide](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute) for credits and costs.

Once connected, confirm the GPU is visible. If this fails, stop and ask in `#compute-questions`.

```bash
nvidia-smi
```

### 2. Download the data

Download the dataset from the **Get the data** section above, or use the Rosie path if you are working on Rosie.

### 3. Clone the TAO Skill Bank

```bash
cd ~
git clone https://github.com/NVIDIA-TAO/tao-skill-bank.git
cd ~/tao-skill-bank
```

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <p><strong>Pinned release:</strong> [ TODO: add the tested release tag to clone with <code>--branch &lt;tag&gt;</code>. ]</p>
  <p><strong>Container and backbone access:</strong> [ TODO: confirm how teams get the TAO container and the C-RADIOv2-B backbone, for example their own NGC and Hugging Face accounts or a preloaded Brev image. ]</p>
</div>

Follow the installation section of the [Skill Bank README](https://github.com/NVIDIA-TAO/tao-skill-bank) for your coding agent (Claude Code, Codex, or Gemini CLI). The skill you need is:

```text
skills/models/tao-train-visual-changenet/
```

Start with standalone Visual ChangeNet. Add the [DEFT AOI workflow](https://docs.nvidia.com/tao/tao-toolkit/latest/text/reference_workflows/deft/aoi.html) only after your baseline is working and reproducible.

### 4. Generate training images with the digital twin

Use the vial station digital twin to render images before you train. Aim for:

- good vials and each defect class (`missing_cap`, `crooked_cap`, `damaged_vial`, `no_vial`);
- the same overhead camera pose, crop, and lighting as the real station;
- crops for each numbered fixture position, with a label for each crop.

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <strong>[ TODO: add the vial station digital twin instructions: where to get it, how to launch it, and how to render labeled crops. ]</strong>
</div>

The [Isaac Sim on Brev tutorial](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Resources) shows how to run a digital twin headless and copy rendered output back to your computer. Visual ChangeNet needs pair-wise CSV files (inspection image, golden image, label); ask your agent to build them in the [TAO annotation format](https://docs.nvidia.com/tao/tao-toolkit/latest/text/data_annotation_format.html).

### 5. Choose a golden image

Point your agent to one specific, confirmed-good vial crop to use as the golden image. A good golden matches the inspection images' position, camera pose, crop, scale, and lighting. If it does not, the model may learn to flag the imaging difference instead of the defect.

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <strong>[ TODO: add the path to the recommended starter golden image. ]</strong>
</div>

One golden image is enough to get the pipeline running. Position-specific or multiple golden images are a good idea to explore later.

### 6. Train with your agent

Start your agent from the Skill Bank checkout or your data folder, replace the two placeholders, and give it this prompt:

```text
Use the installed NVIDIA TAO Skill Bank and the tao-train-visual-changenet
skill to train a Visual ChangeNet classification model on <WORKSPACE>.
Use <GOLDEN_IMAGE_PATH> as the golden image for every pair.

Use local Docker on this GPU. Do not run DEFT, AnomalyGen, export, or
deployment yet.

Before training, validate the training, validation, and test CSV files against
the images, and prove there is no overlap between training and validation.
Show me a short preflight summary before starting any long-running action.

Then train, pick a checkpoint, run inference on the test set, and report each
sample's ground truth, score, and predicted label; the decision threshold; the
confusion matrix; defect recall and false alarm rate, including the false alarm
rate at 100% defect recall; and the paths to logs, inference output, and
checkpoints.
```

### 7. Read the results

- **Positive means a defect was detected.** A false negative is an escaped defect, and a false positive is a good vial rejected. Missed defects matter more in judging.
- The score is a distance from the golden image, not a probability. Higher scores mean more different and lean toward `NO_PASS`.
- Report the false alarm rate at the threshold that catches every known defect, not only overall accuracy.
- Open several correct and incorrect image pairs. Check whether the model reacts to the defect or to pose, glare, and lighting.
- Change one thing at a time, such as the golden image, crop, threshold, or added synthetic examples, and keep the test set fixed.

Useful questions for a first baseline:

- Is it easier to classify a fixed crop for each position, or detect all visible vials in the full image?
- How will the system separate `no_vial` from a transparent uncapped vial?
- What threshold gives the right tradeoff when missed defects cost more than false alarms?
- How will you avoid reporting trailing empty positions as defects before the order is complete?
- Which defects are underrepresented, and can the digital twin create useful examples?

## Testing

Keep a test set that is not used for prompt examples, augmentation decisions, or training. Report results per class, not only overall accuracy. Show false negatives for the defect classes and test at least a few complete fixture scenes.

For testing against the physical line, follow [Collect and Test Your Own Data](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Data-Collection).
