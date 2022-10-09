function [] = hiper_plot(predictor, x,y)
    clf;
    plotpv(x', y')
    plotpc(predictor.iw{1,1}, predictor.b{1})
end

