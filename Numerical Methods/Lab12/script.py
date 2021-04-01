import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

ax = plt.gca()

for pair in [[0,1], [1,1], [5,5]]:
    filename = "A" + str(pair[0]) + str(pair[1])
    data = np.loadtxt(filename + ".txt")
    plt.scatter(data[:, 0], data[:, 1], color="purple", label=f"m={pair[0]}, k={pair[1]}")
    plt.legend()
    plt.xlabel(r"$\ell $")
    plt.ylabel("I")
    # ax.set_xticklabels(rotation = (45), , va='bottom', ha='left')
    plt.xticks(np.arange(30)+1, rotation=0, fontsize = 8)
    plt.grid()
    plt.savefig(filename + ".png")
    ax.cla()


# for pair in  [[0,1], [1,1], [5,5]]:
# filename = "Simp" + str(pair[0]) + str(pair[1])
ax.cla()
filename = "Simp01.txt"
filename2 = "Simp11.txt"
data = np.loadtxt(filename)
data2 = np.loadtxt(filename2)
plt.scatter(data[:, 0], data[:, 1], label=f"m=0, k=1")
plt.scatter(data2[:, 0], data2[:, 1], label=f"m=1, k=1")
plt.legend()
plt.ylim([-0.00005,0.00018])
# plt.ticklabel_format(axis="y", style="sci")
ax.yaxis.set_major_formatter(mtick.FormatStrFormatter('%.1e'))
plt.xlabel("n")
plt.xticks([11,
            21,
            51,
            101,
            201])
plt.ylabel("|C-I|")
plt.tight_layout()
plt.grid()
plt.savefig("Simp01_11" + ".png")
ax.cla()


data3 = np.loadtxt("Simp55.txt")
plt.scatter(data3[:, 0], data3[:, 1], label=f"m=5, k=5")
plt.legend()
plt.xlabel("n")
plt.xticks([11,
            21,
            51,
            101,
            201])
plt.ylabel("|C-I|")
plt.grid()
# plt.ylim([min(data3),max()])
plt.savefig("Simp55" + ".png")
ax.cla()



fig, ax2 = plt.subplots()

ax2.plot(data[:, 0], data[:, 1], marker="o", ls="", label=f"m=0, k=1")
ax2.plot(data2[:, 0], data2[:, 1], marker="o", ls="", label=f"m=1, k=1")
ax2.plot(data3[:, 0], data3[:, 1], marker="o", ls="", label=f"m=5, k=5")
ax2.legend()
plt.xlabel("n")
plt.xticks([11,
            21,
            51,
            101,
            201])
ax2.autoscale(enable=True, axis="y", tight=False)
plt.ylabel("|C-I|")
plt.yscale("log")
# ax.autoscale()
plt.grid(True, which="both")
plt.savefig("Simp55log" + ".png")

