import numpy as np
from matplotlib import pyplot as plt

file = "lambdas.txt"
data = np.loadtxt(file)
alfa = data[:, 0]
vals = data[:, 2:]

lambda1 = data[:, 1]
plt.scatter(alfa, lambda1, label = r'$\lambda_{%s}$' % (0))
plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc='center',
           ncol=1, mode="expand", borderaxespad=0.)
plt.grid()
plt.xlabel('nr iteracji')
plt.ylabel('$\lambda$')
plt.xticks(alfa)
plt.savefig("lambda1.png")

ax = plt.gca() 
ax.cla()

for i in np.arange(0, 3):
    ax.scatter(alfa, vals[:, i], label = r'$\lambda_{%s}$' % (i+1))
    ax.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc='lower left',
           ncol=6, mode="expand", borderaxespad=0.)
plt.xlabel('nr iteracji')
plt.xticks(alfa)
plt.grid()
plt.ylabel('$\lambda$')
# ax.xticks(alfa, minor=True)
# ax.legend(loc = 'upper right')
plt.savefig("eig.png")


ax.cla()

for i in np.arange(3, 6):
    ax.scatter(alfa, vals[:, i], label = r'$\lambda_{%s}$' % (i+1))
    ax.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc='lower left',
           ncol=6, mode="expand", borderaxespad=0.)
plt.xlabel('nr iteracji')
plt.xticks(alfa)
plt.grid()
plt.ylabel('$\lambda$')
# ax.xticks(alfa, minor=True)
# ax.legend(loc = 'upper right')
plt.savefig("eig2.png")
