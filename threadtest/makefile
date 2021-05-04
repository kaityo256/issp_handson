all: a.out

a.out: test.cpp
	icpc -qopenmp test.cpp

clean:
	rm -f a.out slurm-*.out
