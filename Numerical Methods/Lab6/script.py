import numpy as np
import matplotlib.pyplot as plt

file = "output1.txt"
data = np.loadtxt(file)
re = data[:, 0]
im = data[:, 1]

re = re.reshape(4, -1)
im = im.reshape(4, -1)

for i in np.arange(0, 4):
    plt.plot(re[i], im[i], '.-', label = r'$z_{%s}$' % (i+1))
plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc='center',
           ncol=4, mode="expand", borderaxespad=0.)
plt.xlabel("Re(z)")
plt.ylabel("Im(z)")
plt.grid()
plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc='center',
           ncol=4, mode="expand", borderaxespad=0.)
plt.savefig("output1.png")

ax = plt.gca()
ax.cla()

file2 = "output2.txt"
data2 = np.loadtxt(file2)
re2 = data2[:, 0]
im2 = data2[:, 1]

re2 = re2.reshape(4, -1)
im2 = im2.reshape(4, -1)

for i in np.arange(0, 4):
    plt.plot(re2[i], im2[i], '.-', label = r'$z_{%s}$' % (i+1))

plt.xlabel("Re(z)")
plt.ylabel("Im(z)")
plt.grid()
plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc='center',
           ncol=4, mode="expand", borderaxespad=0.)
plt.savefig("output2.png")