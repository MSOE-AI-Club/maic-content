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

## Starter approaches

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <strong>[ TODO: add the recommended starter approaches after reviewing them with the technical mentors. ]</strong>
</div>

Useful questions for a first baseline:

- Is it easier to classify a fixed crop for each position, or detect all visible vials in the full image?
- How will the system separate `no_vial` from a transparent uncapped vial?
- What threshold gives the right tradeoff when missed defects cost more than false alarms?
- How will you avoid reporting trailing empty positions as defects before the order is complete?
- Which defects are underrepresented, and can the digital twin create useful examples?

## Testing

Keep a test set that is not used for prompt examples, augmentation decisions, or training. Report results per class, not only overall accuracy. Show false negatives for the defect classes and test at least a few complete fixture scenes.

For testing against the physical line, follow [Collect and Test Your Own Data](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Data-Collection).
