# Dataset 2: Fluid Mixing Station 3

[Back to the Innovation Lab overview](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026)

## The problem

Four tanks of colored water feed the vial filling stations. A recipe tells the system how many milliliters to draw from each tank, but it does not store the actual color in a tank. Station 3 mixes the fluids upstream of a single nozzle. Fluid left from the previous fill can carry into the next recipe, especially when the color changes.

Build a system that detects color or fill problems and, when possible, helps an operator understand the likely cause. The useful result is not just "different." It should connect what the cameras saw to the recipe order, tank state, or color carryover that may have produced the difference.

<img src="/images/article_content/rockwell-nvidia-fall-2026/fluid-tanks.webp" alt="Four colored-fluid tanks at the CSI testbed" style="width: 100%; border-radius: 10px; margin: 14px 0;" />

## Equipment and recipes

The tanks are identified by position:

- T-100 is the leftmost tank.
- T-200 is next.
- T-300 is next.
- T-400 is the rightmost tank.

Tank colors can change, so the recipe system identifies tanks by number rather than by color. Up to three recipes can be stored and queued in the Batch Scheduler.

Important operating constraints:

- A vial should contain no more than 80 mL to avoid spilling.
- A component may be set from 0 to 80 mL, but Station 3 should not use less than 10 mL of a selected component in practice.
- Do not put more than 50 mL from T-200 in a recipe. It can fault the system and require a plant-manager reset.
- Do not use T-300 in a recipe. It has a configuration issue that can also require a reset.
- Do not change recipes without the plant manager's guidance.

<div style="display: grid; gap: 14px; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); margin: 16px 0;">
  <img src="/images/article_content/rockwell-nvidia-fall-2026/fluid-batch-scheduler.webp" alt="Batch Scheduler interface used to queue fluid recipes" style="width: 100%; border-radius: 8px;" />
  <img src="/images/article_content/rockwell-nvidia-fall-2026/fluid-recipe-screen.webp" alt="Recipe setup interface for the fluid station" style="width: 100%; border-radius: 8px;" />
</div>

## Why the current inspection is not enough

A Teledyne vision system checks vial color and weight before the final station. Because the control system does not know the colors currently in the tanks, the vision system compares the observed color with a reference database. It passes a known color and fails an unknown one.

That check does not reliably answer whether the vial matches the intended recipe. It also does not warn the operator that the next recipe is likely to be affected by fluid left in the shared mixing path.

## What is provided

- timestamped images and video from the Station 3 filling camera;
- timestamped views of the four tanks;
- timestamped views from final inspection;
- recipe and queue context where available.

The camera timestamps let you line up tank state, the fill operation, and the finished vial. Barcodes and labels may or may not be present, and their orientation is inconsistent. The production system does not currently rely on those barcodes.

<div style="display: grid; gap: 14px; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); margin: 16px 0;">
  <img src="/images/article_content/rockwell-nvidia-fall-2026/fluid-fill-orange.webp" alt="Station 3 filling an orange vial" style="width: 100%; border-radius: 8px;" />
  <img src="/images/article_content/rockwell-nvidia-fall-2026/fluid-fill-blue.webp" alt="Station 3 filling a blue vial" style="width: 100%; border-radius: 8px;" />
</div>

## Get the data

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <p><strong>Dataset download:</strong> [ Derek: add the shared download link, file layout, and timestamp format. ]</p>
  <p><strong>For MSOE students on Rosie:</strong> [ Brett: add the absolute Rosie path and any group-permission instructions. ]</p>
  <p><strong>Digital twin:</strong> [ Derek: confirm whether a usable Station 3 digital twin will be provided. ]</p>
</div>

Start by checking that you can match a fill-station frame to the closest tank and final-inspection frames. Record any missing frames, clock offsets, or timestamp drift before building a model.

## Starter approaches

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <strong>[ Brett: add the recommended starter approaches after reviewing them with the technical mentors. ]</strong>
</div>

Questions that may help narrow the first experiment:

- Can a simple color measurement establish a useful baseline before using a vision-language model?
- Can you infer the tank colors from camera views, then compare the expected blend with the filled vial?
- How much does the prior recipe explain the next vial's color?
- Can the system flag risky recipe transitions before the vial is filled?
- How will lighting changes and transparent vial material affect color measurements?

Relevant tools include Cosmos Reason for multi-image or video context, in-context learning with example fills, and a time-series model if recipe or sensor data becomes available. See [Tools and Resources](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Resources).

## Testing

Split tests by production run or time window so nearly identical neighboring frames do not appear in both training and test sets. Report false alarms and missed defects separately. If the solution claims a likely cause, evaluate that explanation separately from defect detection.

For additional collection or live-line testing, follow [Collect and Test Your Own Data](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Data-Collection).
