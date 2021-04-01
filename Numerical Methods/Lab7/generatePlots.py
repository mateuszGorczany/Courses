import numpy as np
from matplotlib import pyplot as plt

files = ["output_5.txt",
         "output_10.txt",
         "output_15.txt",
         "output_20.txt"]

nodes = ["nodes_5.txt",
         "nodes_10.txt",
         "nodes_15.txt",
         "nodes_20.txt"]

pic_names = ["n5.png",
             "n10.png",
             "n15.png",
             "n20.png"]

for file, node, pic_name in zip(files, nodes, pic_names):
    data = np.loadtxt(file)
    data_nodes = np.loadtxt(node)

    ax = plt.gca()
    ax.cla()

    ax.plot(data[:, 0], data[:, 1:])

    ax.scatter(data_nodes[:, 0], data_nodes[:, 1])

    if file is "output_10.txt" or file is "output_20.txt":
        plt.ylim(top=2.0, bottom=-0.1)

    plt.savefig(pic_name)

files = ["output_5opt.txt",
         "output_10opt.txt",
         "output_15opt.txt",
         "output_20opt.txt"]

nodes = ["nodes_5opt.txt",
         "nodes_10opt.txt",
         "nodes_15opt.txt",
         "nodes_20opt.txt"]

pic_names = ["n5opt.png",
             "n10opt.png",
             "n15opt.png",
             "n20opt.png"]

for file, node, pic_name in zip(files, nodes, pic_names):
    data = np.loadtxt(file)
    data_nodes = np.loadtxt(node)

    ax = plt.gca()
    ax.cla()

    ax.plot(data[:, 0], data[:, 1:])

    ax.scatter(data_nodes[:, 0], data_nodes[:, 1])

    if file is "output_20opt.txt":
        plt.ylim(top=1.2, bottom=-0.1)

    plt.savefig(pic_name)