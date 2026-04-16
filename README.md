# ISSP Supercomputer Hands-on

## Overview

Organizations that operate supercomputers usually have multiple systems for different purposes. The Institute for Solid State Physics, The University of Tokyo (ISSP) operates two supercomputers, called "System B" and "System C" as of 2021. This document gives an overview of how to use System B of the ISSP supercomputer.

Note: This material was created independently for my laboratory. It is not official ISSP documentation.

## Supercomputer Basics

Before starting, watch [How to Use the Supercomputer and Important Notes](https://www.youtube.com/watch?v=YcsKEyK9G00).

## Login

Accounts have the form `kXXXXYY`. `XXXX` is the project number, and `YY` is the member number in the project. The project leader is `00`, followed by `01`, `02`, and so on in registration order. The server name for ISSP System B is `ohtaka`, and the server name for System C is `enaga`. The domain is `issp.u-tokyo.ac.jp`. For example, a user whose project is `k0000` and whose account number is `99` can log in as follows.

```sh
ssh k000099@ohtaka.issp.u-tokyo.ac.jp -AY
```

Here, the `-A` option enables agent forwarding, and the `-Y` option enables trusted X11 forwarding. You do not need to specify them if they are unnecessary.

The ISSP supercomputer can be accessed only through public-key authentication. You must register your public key in advance. If you have not created a private/public key pair, create one first. See [SSH Public Key Registration Procedure](https://scm-web.issp.u-tokyo.ac.jp/scm/UserSupport/ssh-pubkey-regist-flow.html) for details.

## Reading the Manuals

The manuals are available here.

[ISSP Supercomputer Manuals](https://mdcl.issp.u-tokyo.ac.jp/scc/system/systembinfo/manual)

The basic manual you should read first is the user's guide. This hands-on uses System B, so read "User's Guide (System B: Japanese)." The page is protected by password authentication, and you can access it with the following ID and password.

* User ID: your ISSP Supercomputer System user name
* Password: the user-name part of your registered email address (the part before `@`)

This document uses only the interactive queue, but ordinary jobs should be submitted to a queue appropriate for their size. The user's guide describes queue (partition) information in addition to how to compile programs, so be sure to read it.

There are also materials such as user training sessions (password required) and notes on how to use the supercomputer, so read them as needed.

Detailed language specifications, library manuals, and similar references are available in documents such as the "System B Manual." These contain quite detailed information, so you do not need to read them at first. Refer to them when necessary.

## Compiling and Submitting Jobs

### Cloning the Hands-on Repository

First, clone this hands-on repository. Run the following command in a suitable directory, such as `~/github`.

```sh
git clone https://github.com/kaityo256/issp_handson.git
```

After cloning, move into the directory.

```sh
cd issp_handson
```

### Compilation

First, compile an MPI program. Move to the `mpitest` directory. It contains an MPI sample code named `test.cpp`.

```sh
cd mpitest
```

```cpp
#include <cstdio>
#include <mpi.h>

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  printf("%03d/%03d\n", rank, size);
  MPI_Finalize();
}
```

This program simply obtains the total number of processes and its own process number (rank), then prints them.

You need to compile the program before running it. The ISSP supercomputer provides GCC, Intel compilers, and AMD compilers. When using GCC, compile C programs with `gcc` and C++ programs with `g++`. MPI is almost always required for parallel computation. To use MPI, you must tell the compiler where the include files and libraries are. Because doing that manually is troublesome, systems often provide wrapper programs that configure the necessary options automatically. On the ISSP supercomputer, use `mpicxx` to compile MPI programs.

```sh
mpicxx test.cpp
```

An executable file named `a.out` should be created. You can check which compiler `mpicxx` actually calls internally by specifying `--version`.

```sh
$ mpicxx --version
g++ (GCC) 8.3.1 20191121 (Red Hat 8.3.1-5)
Copyright (C) 2018 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

In this case, you can see that `g++` is being called. If you want to compile an MPI program with the Intel compiler, use `mpiicc` for C programs and `mpiicpc` for C++ programs.

To run the executable file you just created, you must have computational resources assigned by the job scheduler. There are various job schedulers. ISSP Supercomputer System B uses Slurm, while System C uses PBSPro, so the commands are different.

### Interactive Jobs

There are two ways to run jobs: interactive jobs and batch jobs. First, run the job as an interactive job. An interactive job is a job where dedicated computational resources are assigned by the job scheduler, and you run programs interactively on those resources. ISSP System B provides an interactive queue named `i8cpu`. To use this queue, run the following command.

```sh
salloc -N 1 -n 128 -p i8cpu
```

`salloc` is the command for requesting computational resources. `-N 1` requests the number of nodes, here one node. `-n 128` requests the number of processes, here 128 processes. `-p i8cpu` specifies the computational resource (partition), here `i8cpu`.

When you run it, you will see output like this.

```txt
salloc: Pending job allocation 272941
salloc: job 272941 queued and waiting for resources
salloc: job 272941 has been allocated resources
salloc: Granted job allocation 272941
```

This means the following.

* Job ID 272941 was assigned.
* The job is waiting for resources (queued and waiting for resources).
* Computational resources have been allocated.
* The job has started (Granted job allocation).

Depending on how busy the system is, only the last line may be displayed. Use `srun` to run the job in this state.

```sh
srun ./a.out
```

`srun` is a command for running parallel jobs on systems managed by Slurm. It checks the computational resources assigned to the job and automatically determines which process should be assigned to which resource. This program only prints its own ID (rank) among the total number of processes. Running it produces output like this.

```txt
012/128
067/128
074/128
(snip)
072/128
118/128
099/128
```

For example, `099/128` means "process number 99 out of 128 processes." The order of the output differs each time you run the program.

After execution finishes, leave the interactive job by running `exit`.

### Batch Jobs

Interactive jobs run computations interactively, but they are intended for debugging and checking behavior. Large ordinary computations should be submitted to a queue and wait their turn. This waiting line is called a queue. To run a program as a batch job, you must tell the job scheduler what computational resources you need and how to run the program. This information is written in a job script. A job script is a shell script with special comment lines. For example, this repository provides a job script named `test.sh`. Let's inspect it.

```sh
cat test.sh
```

The following content is displayed.

```sh
#!/bin/sh

#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 128

srun ./a.out
```

In a shell script, text after `#` is treated as a comment, but every line in this script has meaning.

The first line, which begins with `#!`, is called a shebang. It specifies the shell that processes this script.

The following lines that begin with `#SBATCH` are instructions to the job scheduler (Slurm). Their meanings are as follows.

* `-p i8cpu`: specifies the computational resource (partition), here `i8cpu`.
* `-N 1`: requests the number of nodes, here one node.
* `-n 128`: requests the number of processes, here 128 processes.

These are the same options that were passed directly to `salloc` earlier. You can pass this information directly as command-line arguments, but it is better to write it in a shell script so that the requested computational resources remain recorded in a file.

In PBS, the directory from which the job was submitted is stored in the environment variable `PBS_O_WORKDIR`, and it is common to run the following before executing code.

```sh
cd $PBS_O_WORKDIR
```

In Slurm, the current directory is automatically set to the directory from which the job was submitted, so this command is unnecessary.

Use the `sbatch` command to submit this shell script as a job.

```sh
sbatch test.sh
```

After submitting the job, a job ID is assigned. You can check the job status with the `squeue` command.

```sh
squeue
```

For example, you may see output like this.

```txt
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
            272905     i8cpu  test.sh  k011700  R       0:03      1 c15u01n1
```

The meanings of the fields are as follows.

* Job ID (JOBID) 272905 was assigned.
* The requested computational resource (PARTITION) is `i8cpu`.
* The shell script file name (NAME) is `test.sh`.
* The status (ST) is running (R).
* The elapsed time since execution started (TIME) is 3 seconds (`0:03`).
* The requested number of nodes (NODES) is 1.
* The execution node list (NODELIST), or the reason if the job is waiting (REASON).

When execution finishes, a file named `slurm-jobID.out` is created. Standard output is saved there. In this example, because the job ID is 272905, a file named `slurm-272905.out` is created. Check its contents with `less`, `cat`, or a similar command.

### Email Notifications

When the supercomputer is busy, you may have to wait several days or longer before a job runs. Slurm provides a feature that sends email notifications when a job starts or finishes. Specify email notifications with `--mail-type` and `--mail-user`.

```sh
#!/bin/sh

#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 128
#SBATCH --mail-type=BEGIN
#SBATCH --mail-user=your@mail.address

srun ./a.out
```

Open `test_mail.sh` in vim, replace `your@mail.address` above with your own address, and then run the following.

```sh
sbatch test_mail.sh
```

When the job starts, you should receive an email notification from `root@sched1.ohtaka.issp.u-tokyo.ac.jp`.

## Thread Parallelism and Hybrid Parallelism

### Thread Parallelism

Parallelization can be broadly classified into process parallelism, thread parallelism, and data parallelism. Process parallelism is commonly implemented with the MPI library, thread parallelism with OpenMP directives, and data parallelism with intrinsic functions. Earlier, we tried process parallelism with MPI. Next, let's try thread parallelism. To use OpenMP, you need to tell the compiler to enable it. Use `-fopenmp` with `g++`, and `-qopenmp` with the Intel compiler `icpc`. Here, use the Intel compiler.

First, leave the earlier `mpitest` directory and enter the `threadtest` directory.

```sh
cd ..
cd threadtest
```

It contains a thread-parallel sample code named `test.cpp`.

```cpp
#include <cstdio>
#include <omp.h>

int main() {
  int num_threads = omp_get_max_threads();
#pragma omp parallel for
  for (int i = 0; i < num_threads; i++) {
    int tid = omp_get_thread_num();
    printf("%03d/%03d\n", tid, num_threads);
  }
}
```

This code first obtains the number of threads, then loops that many times while assigning loop iterations to separate threads.

Compile it.

```sh
icpc -qopenmp test.cpp
```

Run it as is.

```sh
$ ./a.out
000/001
```

One thread is created, and output is printed from thread ID 0. To change the number of threads, specify the `OMP_NUM_THREADS` environment variable.

```sh
$ OMP_NUM_THREADS=4 ./a.out
003/004
000/004
001/004
002/004
```

You can see that four threads were started. Starting too many threads on the login node is disruptive, so stop around this point.

To submit this as a batch job to the job scheduler, you must specify not only the number of processes but also the number of threads per process. The job script looks like this.

```sh
cat test.sh
```

```sh
#!/bin/sh

#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 128

srun ./a.out
```

Submit the job in the same way as before.

```sh
sbatch test.sh
```

When it runs, a file such as `slurm-275559.out` is created. Its contents will look like this, for example.

```txt
012/128
017/128
038/128
(snip)
122/128
126/128
117/128
```

As in the MPI example, this output shows the total number of threads and each thread's own thread number.

### Hybrid Parallelism

Leaving SIMD aside, parallel computation in computational science means computation that uses multiple CPU cores simultaneously. Starting the same number of processes as CPU cores is called flat MPI. Starting fewer processes than CPU cores and launching multiple threads in each process is called hybrid parallelism.

The sample code for hybrid parallelism is in the `hybrid` directory.

```sh
cd ..
cd hybrid
```

The program looks like this.

```cpp
#include <cstdio>
#include <mpi.h>
#include <omp.h>

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  int num_threads = omp_get_max_threads();
#pragma omp parallel for
  for (int i = 0; i < num_threads; i++) {
    int tid = omp_get_thread_num();
    printf("Thread:%03d/%03d Process:%03d/%03d\n", tid, num_threads, rank, size);
  }
  MPI_Finalize();
}
```

The details are omitted here, but both MPI and OpenMP are used.

ISSP System B has two sockets of 64-core CPUs per node, so it can run up to 128-way parallel jobs on one node. Let's run this as 8 processes times 16 threads. Because this is an MPI program, use `mpicxx`; because the underlying compiler is GCC, pass `-fopenmp` as an option.

```sh
mpicxx -fopenmp test.cpp
sbatch test.sh
```

Display the generated `slurm-XXXXX.out` file with the `sort` command.

```sh
$ sort slurm-272988.out
Thread:000/016 Process:000/008
Thread:000/016 Process:001/008
Thread:000/016 Process:002/008
Thread:000/016 Process:003/008
(snip)
Thread:015/016 Process:004/008
Thread:015/016 Process:005/008
Thread:015/016 Process:006/008
Thread:015/016 Process:007/008
```

You can see that eight processes were launched, and each process launched 16 threads.

## Using LAMMPS

Many prebuilt applications are installed on System B. See [Installed Applications](https://www.issp.u-tokyo.ac.jp/supercom/visitor/applications) for the list of installed applications.

To use an application, run the `application-namevars.sh` script in its directory. For LAMMPS, run the following.

```sh
source /home/issp/materiapps/intel/lammps/lammpsvars.sh
```

This adds `lammps` to your path.

Let's run this on the ISSP supercomputer. The sample code that uses LAMMPS is in the `lammps` directory.

```sh
cd ..
cd lammps
```

First, generate an atom coordinate file.

```sh
python3 generate_config.py
```

This should create `collision.atoms`. In this state, start the interactive queue.

```sh
salloc -N 1 -n 128 -p i8cpu
```

After the job starts, set the path and run LAMMPS.

```sh
source /home/issp/materiapps/intel/lammps/lammpsvars.sh
srun lammps < collision.input
```

You should first see output like this.

```sh
LAMMPS (29 Oct 2020)
  using 1 OpenMP thread(s) per MPI task
Reading data file ...
  orthogonal box = (-40.000000 -20.000000 -20.000000) to (40.000000 20.000000 20.000000)
  8 by 4 by 4 MPI processor grid
```

This means that flat MPI is being used with one thread per process, and that the space is divided into 8 x 4 x 4 subdomains, each handled by a process, for a total of 128 processes.

Because this job has only a small number of atoms, a large performance improvement from parallelization cannot be expected. For large systems, however, parallelization is very effective.

Since we are here, let's also try hybrid execution. The following job script is provided.

```sh
#!/bin/sh

#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 8
#SBATCH -c 16

source /home/issp/materiapps/intel/lammps/lammpsvars.sh
srun lammps < collision.input
```

This is a parallel execution job with 8 processes times 16 threads. Note that the path must be set inside the job script.

Running it should produce output like this.

```txt
LAMMPS (29 Oct 2020)
  using 16 OpenMP thread(s) per MPI task
Reading data file ...
  orthogonal box = (-40.000000 -20.000000 -20.000000) to (40.000000 20.000000 20.000000)
  2 by 2 by 2 MPI processor grid
```

This indicates 16 threads per process and a 2 x 2 x 2 spatial decomposition. You can confirm that process/thread hybrid parallelism was indeed used.

## Transferring Files

Use `scp` to transfer files to and from the supercomputer. With `scp`, you can treat a remote file as if it were local by adding the remote server host name and a colon to the file name. For example, if the remote server is `ohtaka.issp.u-tokyo.ac.jp` and the user name is `k000099`, use the following command to copy a file from the local machine to the remote server.

```sh
scp filename k000099@ohtaka.issp.u-tokyo.ac.jp:remotepath
```

Use the following command to copy a file from the remote server to the current local directory.

```sh
scp k000099@ohtaka.issp.u-tokyo.ac.jp:remotepath/filename .
```
