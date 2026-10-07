# Collect and Test Your Own Data

[Back to the Innovation Lab overview](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026)

The supplied datasets are enough to begin. Teams may visit the CSI testbed, collect additional observations with an approved setup, or ask CSI for a specific data collection. Access must be scheduled and nothing a team does may interfere with production, controls, or safety.

## What teams may do

- Visit CSI to see the line and robot arms operating.
- Record data with the team's own equipment after the setup is reviewed.
- Ask CSI to collect specific images, video, or operating examples.
- Use the supplied digital twins to generate synthetic data.
- Request supervised time to test a finished system against the physical setup.

## What teams may not do

- Move, re-aim, disconnect, or reconfigure an existing camera.
- Change a PLC, robot controller, FactoryTalk configuration, safety system, recipe, or production program.
- Connect hardware to the industrial network without approval.
- Place an object where it could collide with a robot or interfere with the line.
- Attach a printed gripper finger or other component before review.
- Collect images of people or sensitive information that is not needed for the project.

The practical rule is: observe first, and only touch equipment when the plant manager explicitly approves the action.

## Schedule a visit or request data

Post in `#data-and-testbed-requests` and tag Shamar Webster. Ask early. Additional collection is not guaranteed. If you do not get a response in Slack or prefer email, contact [webste63@uwm.edu](mailto:webste63@uwm.edu).

Include:

1. Team name and dataset.
2. The question the requested data should answer.
3. Exactly what should be recorded.
4. Useful examples and counterexamples.
5. Camera or sensor, framing, resolution, and frame rate if those matter.
6. Operating conditions or recipe sequence.
7. Approximate number and duration of samples.
8. Label or metadata needed with each sample.
9. Date by which the team needs it.
10. How the team will decide whether the collection was successful.

Avoid requests such as "more defect images." A useful request is closer to:

> Record 20 completed good fixtures and 10 fixtures containing one intentionally crooked cap. Keep the overhead camera fixed, include the completion signal or placement count, and identify the target position in a CSV.

Slack is the request and scheduling process. Keep the request in `#data-and-testbed-requests` so organizers and other teams can see its status.

## Plan your own collection

Write a short collection sheet before visiting:

- **Target:** what event, object, or defect is being captured?
- **Variation:** which positions, colors, lighting, objects, or recipes should change?
- **Constants:** what must stay fixed so examples can be compared?
- **Ground truth:** who assigns the correct label, and when?
- **Identifiers:** how will a frame map to its recipe, run, fixture position, or trial?
- **Splits:** which runs will be reserved for final testing?
- **Storage:** where will raw data, labels, and collection notes live?

Do a small pilot first. Open the files, inspect timestamps, and check labels while the setup is still available.

## Test on the line

Simulation and saved data are useful, but they do not reproduce every lighting change, timing issue, camera artifact, or robot behavior.

Before asking for physical testing:

- freeze the code and model version you plan to test;
- document the required inputs and expected output;
- prepare a start and stop procedure;
- decide which metrics will be recorded;
- test failure handling with saved data;
- make the test runnable without changing plant controls.

During the test, keep a trial log. Record every attempt, not only successful demos. Note the software version, model, input condition, prediction, expected result, latency, and any operator intervention.

Request live-line testing in `#data-and-testbed-requests` and tag Shamar. Include the test plan above, the time needed, and the people attending. Testing only happens after CSI confirms the time and assigns an on-site supervisor.

## Synthetic data

Synthetic data can cover rare defects or object arrangements that are slow or unsafe to reproduce on the line. It should extend real data, not replace all real testing.

Options include:

- **Isaac Sim Replicator:** vary camera pose, lighting, materials, objects, and defect state while exporting labels.
- **Emulate3D and Omniverse:** use the CSI workstation for the Rockwell production-line twin.
- **Generative augmentation:** produce image variations with tools such as FLUX or the NVIDIA Physical AI Data Factory augmentation pipeline.
- **NuRec:** reconstruct a scene from real camera or lidar data, then use the asset in simulation.

When using generated data, keep its source and generation settings. Compare performance on real-only, synthetic-only, and combined training data. A synthetic improvement counts only if it carries over to held-out real examples.

Resources:

- [Isaac Sim scene-based synthetic dataset generation](https://docs.isaacsim.omniverse.nvidia.com/latest/replicator_tutorials/tutorial_replicator_scene_based_sdg.html)
- [Physical AI Data Factory augmentation pipeline](https://github.com/NVIDIA/paidf-augmentation)
- [NuRec for robotics](https://docs.nvidia.com/nurec/robotics/index.html)
- [Monocular neural reconstruction](https://docs.nvidia.com/nurec/robotics/neural_reconstruction_mono.html)
- [Compute guide](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute)

## Data handling

Keep raw data unchanged. Put cleaned files, labels, and generated files in separate locations. Record who collected or generated each set and the terms under which it may be shared.

Do not commit large datasets, model checkpoints, account credentials, or API keys to the team GitHub repository. Add a small sample and a README that explains how authorized teammates obtain the full data.
