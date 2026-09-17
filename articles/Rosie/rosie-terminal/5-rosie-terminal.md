<br>
<a href='/learning-tree?node=9' style='
    background-color: #31313a;
    color: gainsboro;
    padding: 6px 16px;
    border: none
    border-radius: 4px;
    text-transform: uppercase;
    font-family: "Roboto", sans-serif;
    font-size: 1em;
    font-weight: bold;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;'
>
  View in Learning Tree
</a>

<br>
<br>
<br>

<div style='
  position: relative;
  padding: 10px; 
  border-radius: 5px;
  background-color: rgba(0, 0, 0, 0.85); 
  border: 4px solid transparent;
  background-image: linear-gradient(90deg, rgba(0, 0, 0, 0.85), rgba(0, 0, 0, 0.85)), linear-gradient(90deg, gold, orange, gold);
  background-origin: border-box;
  background-clip: padding-box, border-box;
'>

<svg width='200' height='50' style='display: block; margin-bottom: 5px;'>
  <text x='0' y='35' font-size='35' font-family='Arial' font-weight='bold' fill='gold'>
    Why Read?
    <animate attributeName='fill' values='gold; orange; gold' dur='3s' repeatCount='indefinite' />
  </text>
</svg>

<p style='color: white; margin-top: 2px;'>By reading this article, you will be able to run jobs, create files, and more using the Command Line. Knowing this will allow you to take advantage of and finetune the resources you use to run jobs on ROSIE.  
</p>

</div>

<br/>

<br/>

## Understanding How To Move Via Command Line
There are a few conceptual commands you must know to even start interacting with this Linux-based terminal. Those commands are:

`cd` - Change Directory. 
`ls` - List files in current directory. 
`pwd` - Print Working Directory. 
`mkdir` - Make Directory.
`touch` - Create File. 
`rm` - Remove File. 

bash - Run a bash script

python - Run a python script
sbatch - Run a slurm script
For example `cd ../home/my_stuff` will take you "up" one folder, then go into the home and my_stuff folder from that "up" (Parent) folder.

## Useful SLURM Commands
SLURM is the job scheduler that ROSIE uses to manage jobs. It is a very powerful tool that allows you to run jobs on ROSIE without having to keep your laptop running for the job to continue going. Here are some useful commands:

- squeue
This command will show details on all currently running jobs. This is useful for finding details on jobs you've started. To filter jobs to only your, you can add the following arguements to the command replacing username with your username. squeue -l -u username

- scancel
This will cancel a job, enter the command followed by the jobid as can be found with squeue

- sbatch script.sh
This will submit a batch script to be run. This is useful for creating job templates and submitting multiple jobs at once

Download both example files:

- [Download `batch.sh`](https://msoe-ai-club.github.io/maic-content/articles/Rosie/rosie-terminal/downloads/batch.sh)
- [Download `Verbose_Selu_Batchable_Reconstruction_Model.py`](https://msoe-ai-club.github.io/maic-content/articles/Rosie/rosie-terminal/downloads/Verbose_Selu_Batchable_Reconstruction_Model.py)

The Python example uses only the Python standard library, so you do not need to install any packages.

Keep both files together in the same folder and do not rename them. Upload the folder to ROSIE, open a ROSIE-connected terminal, and use `cd` to enter that folder. Then submit the example:

```bash
sbatch batch.sh
```

Slurm will print a job ID. Use `squeue -l -u <your_username>` to check its status. The program's output will be written to `slurm-<job-id>.out`; view it live with:

```bash
tail -f slurm-<job-id>.out
```

The Python program will also create a small JSON results file in the same folder when it finishes.

For additional technical details about ROSIE access, you can also reference the [official HPC documentation](https://docs.hpc.msoe.edu/#/access).