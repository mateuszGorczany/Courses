function [] = hiper_plot(net, x,y)
clf;
plotpv(x', y');
plotpc(net.iw{1,1}(1, :), net.b{1}(1))
plotpc(net.iw{1,1}(2, :), net.b{1}(2))
end

