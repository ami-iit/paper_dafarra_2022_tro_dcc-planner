function plot_aesthetic_nolegend(Title, Label_x, Label_y, Label_z, fontSize)
% PLOT_AESTHETIC add Title, label and legends in a plot
%   PLOT_AESTHETIC(Title, Label_x, Label_y, Label_z, Legend_1, ..., Legend_n)
%   add title, labels and legends in a plot. LaTex syntax is allowed.

% set labels
if ~isempty(Label_x)
    x_label = xlabel(Label_x);
    set(x_label, 'Interpreter', 'latex');
    set(x_label, 'FontSize', fontSize);
end

if ~isempty(Label_y)
    y_label = ylabel(Label_y);
    set(y_label,'Interpreter','latex');
    set(y_label,'FontSize', fontSize);
end

if ~isempty(Label_z)
    z_label = zlabel(Label_z);
    set(z_label,'Interpreter','latex');
    set(z_label,'FontSize', fontSize);
end

% change linewidth
h = findobj(gcf,'type','line');
set(h,'linewidth',1.2)

% set the title
if ~isempty(Title)
    tit = title(Title);
    set(tit,'FontSize', fontSize + 9);
    set(tit,'Interpreter','latex');
end

% change font size
set(gca,'FontSize', fontSize)

% set grid
grid on;
end