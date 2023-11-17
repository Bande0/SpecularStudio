function plot_mic_array_topology(R, array_params)

% ---- construct title string
try
    if strcmp(array_params.topology, 'archimedean')    
        title_string = ['Archimedean', char(10),...
                        'no. mics: ', num2str(array_params.N), char(10), ...
                        'r0: ', num2str(array_params.r0), char(10),...
                        'r_max: ', num2str(array_params.rmax), char(10),...
                        'phi: ', num2str(array_params.archimedean.phi)];
    elseif strcmp(array_params.topology, 'dougherty')   
        title_string = ['Dougherty', char(10),...
                        'no. mics: ', num2str(array_params.N), char(10), ...
                        'r0: ', num2str(array_params.r0), char(10),...
                        'r_max: ', num2str(array_params.rmax), char(10),...
                        'v: ', num2str(array_params.dougherty.v)];
    elseif strcmp(array_params.topology, 'multi')   
        title_string = ['Multi-Dougherty', char(10),...
                        'no. mics: ', num2str(array_params.N), char(10), ...
                        'no. arms: ', num2str(array_params.multi.N_a), char(10), ...
                        'r0: ', num2str(array_params.r0), char(10),...
                        'r_max: ', num2str(array_params.rmax), char(10),...
                        'v: ', num2str(array_params.multi.v)];
    else 
       error('Unrecognized topology: "%s"', array_params.topology); 
    end
catch
    title_string = 'TITLE_STRING_ERROR';
end

% ---- plot the mic topology

rm = [R(:).location];
rm = reshape(rm, 3, length(R));

x_idx = 1;
if strcmp(array_params.plane, 'xy') 
    y_idx = 2;
elseif strcmp(array_params.plane, 'xz') 
    y_idx = 3;
else
    error('ERROR! Unsupported plane: %s', plane)
end

% plot X/Y limits
rect_w = array_params.squish_params.width;
rect_h = array_params.squish_params.height;
min_x = min(min(rm(x_idx,:)), -rect_w/2);
min_y = min(min(rm(y_idx,:)), -rect_h/2);
max_x = max(max(rm(x_idx,:)), rect_w/2);
max_y = max(max(rm(y_idx,:)), rect_h/2);
xy_lim_min = min(min_x, min_y) * 1.2;
xy_lim_max = max(max_x, max_y) * 1.2;

figure('units','normalized','outerposition',[0.2 0.2 0.6 0.6])
plot(rm(x_idx,:),rm(y_idx,:),'bo');  % mic array
hold on;
plot(0,0,'rx','MarkerSize',12,'LineWidth',2);  % center point
if array_params.squish_params.do_squish
    rectangle('Position', [min_x, min_y, rect_w, rect_h], 'LineStyle', '--');  % containing rectangle    
end
xlim([xy_lim_min xy_lim_max]);
ylim([xy_lim_min xy_lim_max]);
title(title_string, 'Interpreter', 'None');
hold on
axis square;

end