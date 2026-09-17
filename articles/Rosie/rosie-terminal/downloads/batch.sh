#!/bin/bash

################################################################################
#
# Submit file for a batch job on Rosie.
#
# To submit your job, run 'sbatch batch.sh'
# To view your jobs in the Slurm queue, run 'squeue -l -u <your_username>'
# To view details of a running job, run 'scontrol show jobid -d <jobid>'
# To cancel a job, run 'scancel <jobid>'
#
# See the manpages for salloc, srun, sbatch, squeue, scontrol, and scancel
# for more information or read the Slurm docs online: https://slurm.schedmd.com
#
################################################################################

# You must specify the partition. Rosie's default is the 'teaching'
# partition for interactive nodes. Another option is the 'batch' partition.
#SBATCH --partition=teaching

# The number of nodes to request
#SBATCH --nodes=1

# The number of GPUs to request
#SBATCH --gpus=1

# The number of CPUs to request per GPU
#SBATCH --cpus-per-gpu=4

# Kill the job if it takes longer than the specified time.
# Format: <days>-<hours>:<minutes>
#SBATCH --time=1-0:0

# Run the dependency-free Python example. Keep the Python file in the same
# directory as this file and submit the job from that directory.
command="python3 Verbose_Selu_Batchable_Reconstruction_Model.py --loss_function mse --optimizer adam --epochs 10 --num_images 3600 --split 0.8 --exp_name Selu_3600_Images_10_Epochs"

srun $command
