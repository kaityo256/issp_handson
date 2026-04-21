import random

N = 5000000

seed = input()
random.seed(int(seed))

s = 0
for _ in range(N):
    x = random.random()
    y = random.random()
    if x**2 + y**2 < 1.0:
        s = s + 1

pi = float(s)/N*4.0
print(pi)
