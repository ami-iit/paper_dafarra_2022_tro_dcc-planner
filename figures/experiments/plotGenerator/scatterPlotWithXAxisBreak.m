function scatterPlotWithXAxisBreak(x, y, start, stop, width, marker, markerSize, xLim, yLim, DisplayName, labels, labelPosition, labelBuffer, labelRotation, labelFontSize)

% erase unused data
y(x>start & x<stop)=[];
labels(x>start & x<stop)=[];
x(x>start & x<stop)=[];


% map to new xaxis, leaving a space 'width' wide
x2=x;
x2(x2>=stop)=x2(x2>=stop)-(stop-start-width);

scatter(x2, y, markerSize, marker, 'filled','s', 'DisplayName', DisplayName);
legend('-DynamicLegend');

ylim(yLim)
xLimWithBreak = xLim;
xLimWithBreak(2) = xLimWithBreak(2) - (stop-start-width);
xlim(xLimWithBreak)

labelpoints(x2, y, labels, 'position', labelPosition,  'buffer', labelBuffer, ...
    'adjust_axes', 1,...
    'rotation', labelRotation, ...
    'interpreter', 'latex', 'FontSize', labelFontSize);

% remap tick marks, and 'erase' them in the gap
xtick=get(gca,'XTick');
dtick=xtick(2)-xtick(1);
gap=floor(width/dtick);
last=max(xtick(xtick<=start));          % last tick mark in LH dataset
next=min(xtick(xtick>=(last+dtick*(1+gap))));   % first tick mark within RH dataset
if ~isempty(next)
    
    ytick=get(gca,'YTick');
    t1=text(start+width/2,ytick(1),'//','fontsize',15);
    t2=text(start+width/2,ytick(max(length(ytick))),'//','fontsize',15);
    % For y-axis breaks, use set(t1,'rotation',270);

    offset=size(x2(x2>last&x2<next),2)*(x(2)-x(1));

    for i=1:sum(xtick>(last+gap))
        xtick(find(xtick==last)+i+gap)=stop+offset+dtick*(i-1);
    end

    for i=1:length(xtick)
        if xtick(i)>last && xtick(i)<next
            xticklabel{i}=sprintf('%g',[]);
        else
            xticklabel{i}=sprintf('%g',xtick(i));
        end
    end
    set(gca,'xticklabel',xticklabel);
end

end