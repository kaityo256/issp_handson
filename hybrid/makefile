all: a.out

a.out: test.cpp
	mpicxx -fopenmp test.cpp

clean:
	rm -f a.out slurm-*.out
