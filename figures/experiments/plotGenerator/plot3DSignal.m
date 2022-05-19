function  plot3DSignal(time,forces, domain, yLimit,yAxisLabel)
plot(time, forces);
xlim(domain)
ylim(yLimit)
plot_aesthetic('', 'Time (s)',  yAxisLabel, '', 'x', 'y', 'z')

end

