# Dataset 1: Final Vial Inspection

[Back to the Innovation Lab overview](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026)

## The problem

The production line already inspects each vial from the side. It sends vials that pass to a good fixture and detected defects to a scrap fixture. That inspection does not see every cap defect. A cap can also move after inspection, and the robot can miss a pick, damage a vial, or place it incorrectly without noticing.

<img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/fanuc-cell.webp" alt="Final vial inspection station at the CSI testbed" style="width: 100%; border-radius: 10px; margin: 14px 0;" />

Build a system that uses an overhead camera at the final station to check visible vial defects and fixture occupancy after each placement. The priority is to stop defects from getting through. In judging, a missed defect matters more than a false alarm.

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

- a digital twin of the final inspection station for generating training images and labels;
- sample data from the real line: full overhead camera images, labeled and unlabeled position crops, and fixture coordinates and position identifiers;
- a browser-based labeling tool.

The labeling tool lets you select an image and fixture, click a numbered position, inspect its crop in scene context, edit the class, add an observation, and mark it reviewed. Use Previous and Next to move through positions. Export the review JSON when the pass is complete.

<img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/vial-labeling-tool.webp" alt="Browser labeling tool with the full scene and selected vial crop" style="width: 100%; border-radius: 10px; margin: 14px 0;" />

## Get the data and digital twin

<div style="border: 1px solid #64748b; border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <p><strong>Digital twin (datasets 1 and 2):</strong> <a href="https://drive.google.com/drive/folders/1x6ixBGGyv6HG51TQdHvgzj7lqmsN7gKD?usp=sharing" target="_blank" rel="noopener noreferrer">Open the digital twin folder</a></p>
  <p><strong>Sample data from the line:</strong> <a href="https://drive.google.com/drive/folders/1Vl5qMLvUZDeWYNaFvnN8JbIqesjOKkWN?usp=sharing" target="_blank" rel="noopener noreferrer">Open the Final Vial Inspection dataset</a></p>
  <p><strong>Everything in one place:</strong> <a href="https://drive.google.com/drive/folders/1GWuHV2WUNLztq_Fga6xBH7qFzhxDaac8?usp=sharing" target="_blank" rel="noopener noreferrer">Innovation Lab data folder</a></p>
  <p><strong>For MSOE students on Rosie:</strong> the digital twin is already downloaded at <code>TODO/ROSIE/PATH</code></p>
</div>

### Look at the real data, but train on the digital twin

The sample images come from the real line. Look through them to understand the station, the defects, and what your generated images need to match, but **avoid training your models on them**. The goal of this lab is to generate your training data with the digital twin.

That is how this problem has to be solved on a high-mix, low-volume (HMLV) line like CSI's, which makes many product variants in small batches and changes over often. A new product or recipe has no real images until the line has been commissioned and is running it. Collecting and labeling real examples afterwards is costly: it takes line time and operators, defects have to be produced on purpose, and the work repeats at every changeover. A digital twin can produce labeled images of a product, including rare defects, before it ever runs on the line.

Need more real data? See [Collect and Test Your Own Data](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Data-Collection). We may also release a held-out set of real images for testing if there is interest.

The [Isaac Sim on Brev tutorial](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Resources) shows how to run a digital twin headless and copy rendered images back to your computer.

## Tools that fit

- [TAO Toolkit](https://docs.nvidia.com/tao/tao-toolkit/7.0.1/text/getting_started.html) for training and adapting vision models.
- [Visual ChangeNet](https://docs.nvidia.com/tao/tao-toolkit/latest/text/cv_finetuning/pytorch/visual_changenet/index.html) for lightweight image classification.
- [DEFT AOI workflow](https://github.com/NVIDIA/skills/blob/main/skills/tao-run-deft-aoi/SKILL.md) for an evaluate, diagnose, augment, retrain, and gate loop.
- Cosmos Reason for in-context inspection using example images without first training a small dedicated model.
- Isaac Sim and Replicator for synthetic images and labels from the digital twin.

See [Compute](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute) before launching training or simulation.

## Starter approach: TAO Toolkit with Visual ChangeNet

A good first baseline is a small [Visual ChangeNet](https://docs.nvidia.com/tao/tao-toolkit/latest/text/cv_finetuning/pytorch/visual_changenet/visual_changenet_classify.html) classification model trained on images you generate with the digital twin. Visual ChangeNet compares each inspection image with a **golden image**, a known-good reference of what the vial should look like, and outputs `PASS` or `NO_PASS`.

The general approach:

- **Compute:** if you use Brev, an L40S on an AWS environment is a good place to start. See the [Compute guide](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute).
- **Generate your data:** render good vials and each defect class from the digital twin, matching the real station's overhead camera pose, crop, and lighting. Visual ChangeNet trains on pairs of an inspection image and a golden image in the [TAO annotation format](https://docs.nvidia.com/tao/tao-toolkit/latest/text/data_annotation_format.html).
- **Pick a golden image:** choose one confirmed-good vial crop and point your agent to it. It should match the inspection images' position, camera pose, crop, scale, and lighting, or the model may learn to flag imaging differences instead of defects. Position-specific or multiple golden images are worth exploring later.
- **Train with an agent:** clone the [NVIDIA TAO Skill Bank](https://github.com/NVIDIA-TAO/tao-skill-bank) and point your coding agent at its Visual ChangeNet skill. The Skill Bank gives the agent model-specific instructions, data checks, and container steps, so you do not need to memorize TAO commands. Follow its README for setup; the TAO container and backbone may require your own NGC and Hugging Face accounts.
- **Iterate:** once the baseline works, the [DEFT AOI workflow](https://docs.nvidia.com/tao/tao-toolkit/latest/text/reference_workflows/deft/aoi.html) can help target the cases it gets wrong.

When you read the results:

- **Positive means a defect was detected.** A false negative is an escaped defect, and a false positive is a good vial rejected. Missed defects matter more in judging.
- The model's score is a distance from the golden image, not a probability. Higher scores lean toward `NO_PASS`.
- Report the false alarm rate at the threshold that catches every known defect, not only overall accuracy.
- Open several correct and incorrect image pairs to check whether the model reacts to the defect or to pose, glare, and lighting.
- Change one thing at a time and keep the test set fixed.

Useful questions for a first baseline:

- Is it easier to classify a fixed crop for each position, or detect all visible vials in the full image?
- How will the system separate `no_vial` from a transparent uncapped vial?
- What threshold gives the right tradeoff when missed defects cost more than false alarms?
- How will you avoid reporting trailing empty positions as defects before the order is complete?
- Which defects are underrepresented, and can the digital twin create useful examples?

## Testing

Keep a test set that is not used for prompt examples, augmentation decisions, or training. Report results per class, not only overall accuracy. Show false negatives for the defect classes and test at least a few complete fixture scenes.

For testing against the physical line, follow [Collect and Test Your Own Data](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Data-Collection).
