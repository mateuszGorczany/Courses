import numpy as np
import matplotlib.pyplot as plt

filenames = ["danef1_1.txt",
             "danef1_2.txt",
             "danef2_1.txt"]

x_1s = ["-0.5",
        "-0.9",
        "1.5"]

ax = plt.gca()

f1 = np.loadtxt("f1.txt")
plt.plot(f1[:, 0], f1[:, 1], label=r"$f_{1}(x)$")
plt.legend()
plt.xlabel("x")
plt.ylabel("y")
plt.grid()
plt.savefig("f1.png")

ax.cla()

for file, x_1 in zip(filenames, x_1s):
    data = np.loadtxt(file)
    # data.replace("nan", "0");
    for i in range(1,4):
        plt.plot(data[:, 0], data[:, i], label=f"$x_{i}(x)$", marker='.')
    plt.plot(data[:, 0], data[:, 4], label=r"$x_{m}$")
    plt.legend()
    plt.xlabel("iteracja")
    plt.grid()
    if "f1" in file:
        plt.title(r"$x_1 = %s, f_{1}(x)$" %(x_1))
        plt.savefig(f"f1{x_1}.png")
    if "f2" in file:
        plt.title(r"$x_1 = %s, f_{2}(x)$" %(x_1))
        plt.savefig(f"f2{x_1}.png")

    ax.cla()
    plt.plot(data[:, 0], data[:, 5], label=f"$F[x_{1}, x_{2}]$", marker='.')
    plt.plot(data[:, 0], data[:, 6], label=r"$F[x_{1}, x_{2}, x_{3}]$", marker='.')
    plt.legend()
    plt.grid()
    plt.xlabel("iteracja")
    if "f1" in file:
        plt.title(r"$x_{1} = %s, f_{1}(x)$" %(x_1))
        plt.savefig(f"F1{x_1}.png")
    if "f2" in file:
        plt.title(r"$x_{1} = %s, f_{2}(x)$" %(x_1))
        plt.savefig(f"F2{x_1}.png")
    ax.cla()

for file in filenames:
    data = np.loadtxt