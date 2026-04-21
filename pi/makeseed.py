N = 127

for i in range(N):
    filename = f"seed{i:03d}.dat"
    print(filename)
    with open(filename, "w") as f:
        f.write(str(i)+"\n")

with open("task.sh", "w") as f:
    print("task.sh")
    for i in range(N):
        filename = f"seed{i:03d}.dat"
        result = f"result{i:03d}.dat"
        f.write(f"python pi.py < {filename} > {result}\n")
