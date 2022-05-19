function  plotSignal(time,forces, domain, yLimit,yAxisLabel, title, fontSize)
plot(time, forces);
xlim(domain)
ylim(yLimit)
plot_aesthetic_nolegend(title, 'Time (s)',  yAxisLabel, '', fontSize)

end

