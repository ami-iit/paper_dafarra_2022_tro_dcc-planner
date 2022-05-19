function  plotSignalComparison(time,signal1, signal2, domain, y1Limit,y1AxisLabel, y2Limit,y2AxisLabel, fontSize)
yyaxis left
plot(time,signal1);

y_label = ylabel(y1AxisLabel);
set(y_label,'Interpreter','latex');
set(y_label,'FontSize', fontSize);
ylim(y1Limit)

yyaxis right
plot(time, signal2);

plot_aesthetic_nolegend('', 'Time (s)', y2AxisLabel, ' ', fontSize);
xlim(domain)
% if y2Limit(2)*ratio<y2Limit(1)
%     ylim([y2Limit(2)*ratio y2Limit(2)])
% else
%     ylim([y2Limit(1) y2Limit(1)/ratio])
% end
ylim([y2Limit(2) * y1Limit(1)/y1Limit(2) y2Limit(2)])

end