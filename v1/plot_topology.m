function plot_topology(rm, sources, speakers, array_params)

% ---- construct title string
if strcmp(array_params.topology, 'archimedean')    
    title_string = ['Archimedean', newline,...
                    'no. mics: ', num2str(array_params.N), newline, ...
                    'r0: ', num2str(array_params.r0), newline,...
                    'r_max: ', num2str(array_params.rmax), newline,...
                    'phi: ', num2str(array_params.archimedean.phi)];
elseif strcmp(array_params.topology, 'dougherty')   
    title_string = ['Dougherty', newline,...
                    'no. mics: ', num2str(array_params.N), newline, ...
                    'r0: ', num2str(array_params.r0), newline,...
                    'r_max: ', num2str(array_params.rmax), newline,...
                    'v: ', num2str(array_params.dougherty.v)];
elseif strcmp(array_params.topology, 'multi')   
    title_string = ['Multi-Dougherty', newline,...
                    'no. mics: ', num2str(array_params.N), newline, ...
                    'no. arms: ', num2str(array_params.multi.N_a), newline, ...
                    'r0: ', num2str(array_params.r0), newline,...
                    'r_max: ', num2str(array_params.rmax), newline,...
                    'v: ', num2str(array_params.multi.v)];
else 
   error('Unrecognized topology: "%s"', array_params.topology); 
end

% ---- plot the mic topology

% plot X/Y limits
rect_w = array_params.squish_params.width;
rect_h = array_params.squish_params.height;
min_x = min(min(rm(1,:)), -rect_w/2);
min_y = min(min(rm(2,:)), -rect_h/2);
max_x = max(max(rm(1,:)), rect_w/2);
max_y = max(max(rm(2,:)), rect_h/2);
xy_lim_min = min(min_x, min_y) * 1.2;
xy_lim_max = max(max_x, max_y) * 1.2;

figure('units','normalized','outerposition',[0.2 0.2 0.6 0.6])
subplot(1,2,1)
plot(rm(1,:),rm(2,:),'bo');  % mic array
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

% plot X/Y/Z limits
tmp = [speakers.location];
spk_loc = [[tmp.x];[tmp.y];[tmp.z]];
tmp = [sources.location];
src_loc = [[tmp.x];[tmp.y];[tmp.z]];
xy_lim = max(max([spk_loc abs(rm)])) * 1.2; % max of most distant mic from center + speakers;
z_max = max([src_loc(3,:) rm(3,:)]);
z_min = min([src_loc(3,:) rm(3,:)]);
z_len = z_max - z_min;
z_lim_max = z_max + 0.1*z_len;
z_lim_min = z_min - 0.1*z_len;

% ---- plot the mic topology + near-end point sources + speakers in a 3D plot
ax = subplot(1,2,2);
% swap the Y and Z axes for plotting so that mic array gets displayd in the XZ-plane
% and distance to sources is on the Y-axis
plot3(ax, rm(1,:),rm(3,:),rm(2,:),'.','MarkerSize',12); % mic array
hold on;
plot3(ax, src_loc(1,:),src_loc(3,:),src_loc(2,:),'x','MarkerSize',10,'LineWidth',3); % near-end sources
plot3(ax, spk_loc(1,:),spk_loc(3,:),spk_loc(2,:),'gx','MarkerSize',10,'LineWidth',3); % speakers
view(40,20)
xlim([-xy_lim, xy_lim]);
zlim([-xy_lim, xy_lim]);
ylim([z_lim_min z_lim_max]);
grid on;
axis square;

end