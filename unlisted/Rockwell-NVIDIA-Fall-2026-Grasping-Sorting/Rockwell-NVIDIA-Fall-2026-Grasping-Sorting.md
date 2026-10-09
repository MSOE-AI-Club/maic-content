# Dataset 3: Grasping and Sorting

[Back to the Innovation Lab overview](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026)

## The problem

Industrial robot arms are often programmed for fixed motions without vision. That works when every object arrives in the same position, but it leaves the robot unable to adjust to clutter, changing objects, or an imperfect grasp.

Use multiple camera views and a digital twin to make a FANUC arm grasp and sort objects reliably. Once a basic pick-and-place works, teams can add harder objects, smarter sorting rules, or fingers designed for a particular object.
## What is provided

- a FANUC ER-4iA industrial robot arm;
- a SCHUNK pneumatic two-finger gripper;
- two overhead cameras and one wrist camera;
- a digital twin of the arm and work area;
- a CAD model of the current fingers;
- access to design and print replacement fingers.

<div style="display: grid; gap: 14px; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); margin: 16px 0;">
  <img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/fanuc-grasping-overhead.jpg" alt="Overhead camera view of the FANUC arm and objects in the grasping workspace" style="width: 100%; border-radius: 8px;" />
  <img src="https://msoe-ai-club.github.io/maic-content/images/article_content/rockwell-nvidia-fall-2026/fanuc-grasping-side.jpg" alt="Side camera view of the FANUC arm and objects in the grasping workspace" style="width: 100%; border-radius: 8px;" />
</div>

The first target is a repeatable grasp and sort. Define how success will be measured before increasing difficulty: successful picks per attempt, placement accuracy, cycle time, recovery after a failed grasp, or performance on objects not used during development.

## Get the data and digital twin

<div style="border: 1px solid #f59e0b; background: rgba(245, 158, 11, 0.12); border-radius: 8px; padding: 12px 16px; margin: 16px 0;">
  <p><strong>Robotic digital twin:</strong> the download will be released within the next 24 hours.</p>
  <p><strong>Dataset, camera samples, calibration files, and finger CAD:</strong> access details will be posted here as they are finalized.</p>
  <p><strong>For MSOE students on Rosie:</strong> the Rosie location and access instructions will be posted with the project files.</p>
</div>

## Run the twin on Brev

The supplied tutorial uses the [Isaac Sim synthetic-data launchable](https://brev.nvidia.com/launchable/deploy/now?launchableID=env-35JP2ywERLgqtD0b0MIeK1HnF46). It runs headless, so you work from the command line and save images or videos to inspect locally.

1. Start the launchable and wait for the instance to appear under **Compute**.
2. Open the instance details for its CLI and file-copy instructions.
3. Copy the twin to the instance:

```bash
brev copy /path/to/fanuc_er4ia_sim.zip <instance-name>:/home/ubuntu
```

4. Connect to the instance and unpack it:

```bash
unzip fanuc_er4ia_sim.zip
```

5. Ask your coding agent to inspect the project, load it in Isaac Sim, and render a short pick-and-place test. Verify the scene and motion instead of assuming generated code is correct.
6. Copy the output video back:

```bash
brev copy <instance-name>:/home/ubuntu/fanuc_er4ia_sim/demo.mp4 /path/to/Downloads
```

7. Stop the instance as soon as the run is finished.

The full account, cost, stop, and delete instructions are on the [Compute page](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Compute).

## Technical references

- [Official FANUC ROS 2 driver quickstart](https://fanuc-corporation.github.io/fanuc_driver_doc/main/docs/quick_start/quick_start.html)
- [FANUC manipulators in Isaac Sim](https://docs.isaacsim.omniverse.nvidia.com/latest/assets/usd_assets_robots_manipulator.html)
- [Isaac Sim ROS 2 manipulation tutorial](https://docs.isaacsim.omniverse.nvidia.com/latest/ros2_tutorials/robot_control/tutorial_ros2_manipulation.html)
- [Isaac Lab and Isaac Sim on DGX Spark](https://build.nvidia.com/spark/isaac)
- [FANUC Tech Transfer video library](https://techtransfer.fanucamerica.com/)

## Starter approaches

A useful sequence for scoping the work:

1. Make the existing object and fingers work in simulation.
2. Measure success across repeated trials and varied starting positions.
3. Move one source of variation at a time into the test: orientation, object type, clutter, or lighting.
4. Compare the simulation result with a small number of physical trials.
5. Only then change the policy, perception system, or finger geometry.

Keep a log of simulation settings, randomization, model versions, and physical trial outcomes. A video alone does not show reliability.

## Safety and physical testing

Do not send commands to the physical arm or change its controller configuration without the plant manager and assigned mentor. Do not add a printed finger until it has been reviewed for clearance and safe operation.

Follow [Collect and Test Your Own Data](https://msoe-maic.com/library?article=Rockwell-NVIDIA-Fall-2026-Data-Collection) before scheduling time on the physical system.
