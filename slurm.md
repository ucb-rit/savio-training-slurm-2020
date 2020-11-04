% Savio introductory training: Basic usage of the Berkeley Savio high-performance computing cluster
% November 9, 2020
% Nicolas Chan, Wei Feinstein, and Chris Paciorek


# Introduction

We'll do this mostly as a demonstration. We encourage you to login to your account and try out the various examples yourself as we go through them.

Much of this material is based on the extensive Savio documention we have prepared and continue to prepare, available at [http://research-it.berkeley.edu/services/high-performance-computing](http://research-it.berkeley.edu/services/high-performance-computing).

The materials for this tutorial are available using git at the short URL ([https://tinyurl.com/brc-nov20](https://tinyurl.com/brc-nov20)), the  GitHub URL ([https://github.com/ucb-rit/savio-training-slurm-2020](https://github.com/ucb-rit/savio-training-slurm-2020)), or simply as a [zip file](https://github.com/ucb-rit/savio-training-slurm-2020/archive/main.zip).

# How to get additional help

 - For technical issues and questions about using Savio:
    - brc-hpc-help@berkeley.edu
 - For questions about computing resources in general, including cloud computing:
    - brc@berkeley.edu
    - office hours: Wed. 1:30-3:00 and Thur. 9:30-11:00 [on Zoom](https://research-it.berkeley.edu/programs/berkeley-research-computing/research-computing-consulting)
 - For questions about data management (including HIPAA-protected data):
    - researchdata@berkeley.edu
    - office hours: Wed. 1:30-3:00 and Thur. 9:30-11:00 [on Zoom](https://research-it.berkeley.edu/programs/berkeley-research-computing/research-computing-consulting)

# Upcoming events and hiring

- Research IT is hiring graduate students as [domain consultants](https://research-it.berkeley.edu/brc/domain-consultant). Please talk to one of us if interested.
- [Sensitive Data](https://research-it.berkeley.edu/services/sensitive-and-protected-data): We are building a service and platform for researchers working with sensitive data. Secure VMs are available now and secure HPC cluster + storage are coming soon at a baseline capacity at no cost. Please get in touch if you are working with sensitive data.
- [Cloud Computing Meetup](https://www.meetup.com/ucberkeley_cloudmeetup/)
    - Monthly on last Tuesday
    - Next meeting on Tuesday November 24
- [Securing Research Data Working Group](https://dlab.berkeley.edu/working-groups/securing-research-data-working-group)
    - Monthly, next meeting Monday November 23


# Outline

This training session will cover the following topics:

 - Submitting Jobs (Chris)
   - Parallel jobs
   - Other kinds of jobs
   - Possible submission errors
   - Checking on running jobs
 - How Slurm Works (Wei)
   - Introduction to queueing on clusters
   - Slurm details
   - How Slurm is set up on Savio
 - Common Queue Questions (Nicolas)
   - Why isn't my job running (yet)?
   - Estimating job start time
   - Making jobs run sooner
     

# The Savio cluster

Savio is a Linux cluster - by cluster we mean a set of computers networked together such that you can:

 1) access the system by logging into a "login node"
 2) access your files on the system from any of the computers
 3) run your computations across one or more of the "compute nodes"
    - your work might use parallelization to do computation on more than one CPU
    - you can also run "serial" jobs that use a single CPU

# Conceptual diagram of Savio

<center><img src="savio_diagram.jpeg"></center>

# Slurm's job

All computations are done by submitting jobs to the scheduling software that manages jobs on the cluster, called Slurm.

Why is this necessary? Otherwise your jobs would be slowed down by other people's jobs running on the same node. This also allows everyone to fairly share Savio.

Savio uses Slurm to:

 1) Allocate access to resources (compute nodes) to users' jobs
 2) Start and monitor jobs on allocated resources
 3) Manage the queue of pending jobs


# Submitting jobs: accounts and partitions

When submitting a job, the main things you need to indicate are the project account you are using and the partition. Note that their is a default value for the project account, but if you have access to multiple accounts such as an FCA and a condo, it's good practice to specify it.

You can see what accounts you have access to and which partitions within those accounts as follows:

```
sacctmgr -p show associations user=SAVIO_USERNAME
```

Here's an example of the output for a user who has access to an FCA, a condo, and a special partner account:
```
Cluster|Account|User|Partition|Share|GrpJobs|GrpTRES|GrpSubmit|GrpWall|GrpTRESMins|MaxJobs|MaxTRES|MaxTRESPerNode|MaxSubmit|MaxWall|MaxTRESMins|QOS|Def QOS|GrpTRESRunMins|
brc|co_stat|paciorek|savio2_1080ti|1||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio2_knl|1||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio2_bigmem|1||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio2_gpu|1||||||||||||savio_lowprio,stat_gpu2_normal|stat_gpu2_normal||
brc|co_stat|paciorek|savio2_htc|1||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio|1||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio_bigmem|1||||||||||||savio_lowprio|savio_lowprio||
brc|co_stat|paciorek|savio2|1||||||||||||savio_lowprio,stat_savio2_normal|stat_savio2_normal||
brc|fc_paciorek|paciorek|savio2_1080ti|1||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio2_knl|1||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio2_gpu|1||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio2_htc|1||||||||||||savio_debug,savio_long,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio2_bigmem|1||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio2|1||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio|1||||||||||||savio_debug,savio_normal|savio_normal||
brc|fc_paciorek|paciorek|savio_bigmem|1||||||||||||savio_debug,savio_normal|savio_normal||
```

If you are part of a condo, you'll notice that you have *low-priority* access to certain partitions. For example I am part of the statistics condo *co_stat*, which owns some savio2 nodes and savio2_gpu nodes and therefore I have normal access to those, but I can also burst beyond the condo and use other partitions at low-priority (see below).

In contrast, through my FCA, I have access to the savio, savio2, big memory, HTC, and GPU partitions all at normal priority.

# Submitting a batch job

Let's see how to submit a simple job. If your job will only use the resources on a single node, you can do the following. 

Here's an example job script that I'll run. You'll need to modify the --account value and possibly the --partition value.

```bash
#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Account:
#SBATCH --account=co_stat
#
# Partition:
#SBATCH --partition=savio2
#
# Wall clock limit (30 seconds here):
#SBATCH --time=00:00:30
#
## Command(s) to run:
module load python/3.6
python calc.py >& calc.out
```

# Monitoring jobs

Now let's submit and monitor the job:

```
sbatch job.sh

squeue -j <JOB_ID>

wwall -j <JOB_ID>
```

After a job has completed (or been terminated/cancelled), you can review the maximum memory used (and other information) via the sacct command.

```
sacct -j <JOB_ID> --format=JobID,JobName,MaxRSS,Elapsed
```

MaxRSS will show the maximum amount of memory that the job used in kilobytes.

You can also login to the node where you are running and use commands like *top* and *ps*:

```
srun --jobid=<JOB_ID> --pty /bin/bash
```

# Parallel job submission

If you are submitting a job that uses multiple nodes, you'll need to carefully specify the resources you need. The key flags for use in your job script are:

 - `--nodes` (or `-N`): indicates the number of nodes to use
 - `--ntasks-per-node`: indicates the number of tasks (i.e., processes) one wants to run on each node
 - `--cpus-per-task` (or `-c`): indicates the number of cpus to be used for each task

In addition, in some cases it can make sense to use the `--ntasks` (or `-n`) option to indicate the total number of tasks and let the scheduler determine how many nodes and tasks per node are needed. In general `--cpus-per-task` will be 1 except when running threaded code.  

Here's an example job script for a job that uses MPI for parallelizing over multiple nodes:

```bash
#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Account:
#SBATCH --account=account_name
#
# Partition:
#SBATCH --partition=partition_name
#
# Number of MPI tasks needed for use case (example):
#SBATCH --ntasks=40
#
# Processors per task:
#SBATCH --cpus-per-task=1
#
# Wall clock limit:
#SBATCH --time=00:00:30
#
## Command(s) to run (example):
module load intel openmpi
mpirun ./a.out
```

When you write your code, you may need to specify information about the number of cores to use. SLURM will provide a variety of variables that you can use in your code so that it adapts to the resources you have requested rather than being hard-coded. 

Here are some of the variables that may be useful: SLURM_NTASKS, SLURM_CPUS_PER_TASK, SLURM_NODELIST, SLURM_NNODES.

Some common paradigms are:

- 1 node, many CPUs
    - openMP/threaded jobs - 1 task, *c* CPUs for the task
    - Python/R/GNU parallel - many tasks, 1 per CPU at any given time
- many nodes, many CPUs
    - MPI jobs that use 1 CPU per task for each of *n* tasks, spread across multiple nodes
    - Python/R/GNU parallel - many tasks, 1 per CPU at any given time
- hybrid jobs that use *c* CPUs for each of *n* tasks
    - e.g., MPI+threaded code
   
There are lots more examples of job submission scripts for different kinds of parallelization (multi-node (MPI), multi-core (openMP), hybrid, etc.) [here](http://research-it.berkeley.edu/services/high-performance-computing/running-your-jobs#Job-submission-with-specific-resource-requirements).

# Details on some parallel variations

# Long-running jobs



# GPU jobs

Most of the GPU partitions (e.g., savio2_gpu, savio2_1080ti, savio3_gpu, etc.) have multiple GPUs on each node.

  - You can request as many GPUs as your code will use.
  - You must request 2 CPUs for each GPU

#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Account:
#SBATCH --account=account_name
#
# Partition:
#SBATCH --partition=savio2_gpu
#
# Number of nodes:
#SBATCH --nodes=1
#
# Number of tasks (one for each GPU desired for use case) (example):
#SBATCH --ntasks=1
#
# Processors per task (please always specify the total number of processors twice the number of GPUs):
#SBATCH --cpus-per-task=2
#
#Number of GPUs, this can be in the format of "gpu:[1-4]", or "gpu:K80:[1-4] with the type included
#SBATCH --gres=gpu:1
#
# Wall clock limit:
#SBATCH --time=00:00:30
#
## Command(s) to run (example):
./a.out

# Low-priority queue

Condo users have access to the broader compute resource that is limited only by the size of partitions, under the *savio_lowprio* QoS (queue). However this QoS does not get a priority as high as the general QoSs, such as *savio_normal* and *savio_debug*, or all the condo QoSs, and it is subject to preemption when all the other QoSs become busy. 

More details can be found [in the *Low Priority Jobs* section of the user guide](http://research-it.berkeley.edu/services/high-performance-computing/user-guide/savio-user-guide#Low_Priority).

Suppose I wanted to burst beyond the Statistics condo to run on 20 nodes. I'll illustrate here with an interactive job though usually this would be for a batch job.

First I'll see if there are that many nodes even available.

```
sinfo -p savio2
srun -A co_stat -p savio2 --qos=savio_lowprio --nodes=20 -t 10:00 --pty bash
## now look at environment variables to see my job can access 20 nodes:
env | grep SLURM
```

# HTC jobs (and long-running jobs)

There is a partition called the HTC partition that allows you to request cores individually rather than an entire node at a time. The nodes in this partition are faster than the other nodes.

```
srun -A co_stat -p savio2_htc --cpus-per-task=2 -t 10:00 --pty bash
## we can look at environment variables to verify our two cores
env | grep SLURM
module load python
python calc.py >& calc.out &
top
```

One can run jobs up to 10 days (using four or fewer cores) in this partition if you include `--qos=savio_long`.

# Alternatives to the HTC partition for collections of serial jobs
 
You may have many serial jobs to run. It may be more cost-effective to collect those jobs together and run them across multiple cores on one or more nodes.

Here are some options:

  - using [GNU parallel](http://research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/gnu-parallel) to run many computational tasks (e.g., thousands of simulations, scanning tens of thousands of parameter values, etc.) as part of single Savio job submission
  - using [single-node parallelism](https://github.com/berkeley-scf/tutorial-parallel-basics) and [multiple-node parallelism](https://github.com/berkeley-scf/tutorial-parallel-distributed) in Python, R, and MATLAB
    - parallel R tools such as *future*, *foreach*, *parLapply*, and *mclapply*
    - parallel Python tools such as  *ipyparallel*, *Dask*, and *ray*
    - parallel functionality in MATLAB through *parfor*


# Some possible submission errors

Here are some errors that might result in your job never even being queued.

Make sure account/partition/QoS combo is legitimate:

```
[paciorek@ln002 ~]$ srun -A co_stat -t 5:00 -q savio_normal -p savio3 --pty bash
srun: error: Unable to allocate resources: Invalid qos specification
```

Request 2 CPUs for each GPU:

```
[paciorek@ln002 ~]$ srun -A ac_scsguest -t 5:00 -p savio2_gpu --gres=gpu:1 --pty bash
srun: error: Unable to allocate resources: Invalid generic resource (gres) specification
```

Need to request FCA renewal or pay for extra service units:

```
[paciorek@ln002 ~]$  srun -A fc_paciorek -p savio2  -t 5:00 --pty bash
srun: error: This user/account pair does not have enough service units to afford this job's estimated cost
```

However, in most cases, even if you provide invalid values, your job will be queued rather than immediately returning an error.  

# Common Queue Questions (Nicolas)
- Why isn't my job running (yet)?
- When is my job expected to start?
- How can I get my job to start sooner?

# Why isn't my job running (yet)?

Could be for various reasons, including:

- Waiting for other higher priority jobs to finish
- Running this job would exceed a condo/QoS limit
- Incompatible parameters with the QoS (even though it made it to the queue)

# Introducing `sq`
We developed a new tool to diagnose issues:
```bash
module load sq
sq
```
You can also use it as an `squeue` replacement:
```bash
sq -aq
```

# `sq` Example Scenarios
- The job would intersect with downtime so the job will run _after_ the downtime
- Condo users have a fixed number of nodes with their condo QoS
  - Try using `savio_lowprio` QoS
- Job is requesting longer wall-clock time than is allowed (`QOSMaxWallDurationPerJobLimit`)

# `sq` Demo
Demo QOSGrp
```bash
sq -u "$(squeue -o %all -P | grep -i qosgrp | cut -d'|' -f21 | shuf | head -n1)"
```

# `squeue`

- If you need more specific information, you can use Slurm's own `squeue`.
  - `REASON` are explained in `man squeue`
  
# Common `REASON`
- `PRIORITY` - There are other higher priority jobs being allocated nodes
- `RESOURCES` - This job is next in priority and is waiting for available nodes

# When is my job expected to start? (PENDING)
Check how many other pending jobs there are in the queue:
```bash
squeue -p savio2 --state=PD -l -O JOBID,PARTITION,NAME,USERNAME,STATE,TIMELIMIT,REASON,PRIORITY
```
Higher priority means it will try to run sooner.

# When is my job expected to start? (RESOURCES)
If status is `RESOURCES`, you may check:
```bash
squeue --start -u $USER
```
to get an _estimated_ start time.

# How can I get my job to start sooner?
- Shorten the time limit. Slurm may be able to fit a shorter job in a small gap between other jobs.
- Request fewer nodes (or cores on partitions scheduled by cores). Perhaps there are a few nodes available right now but you would have to wait for other jobs to release other nodes if you wanted more.
- Choose condo QoS if possible for higher priority.
- Choose a partition with more idle nodes
  - `sinfo -o %P,%A` (Partition, Allocated/Idle)
  - View on our [Savio status dashboard](https://grafana.brc.berkeley.edu/d/pkIFHJAik/job-planning?orgId=2)
- High recent usage decreases FCA priority.

