clear all
close all
clc
addpath(fullfile(pwd, 'utility'));
addpath(fullfile(pwd, 'jsonlab'));
addpath(fullfile(pwd, 'plotting'));

% ----- JSON filename for saving array  ----- %
filename = 'mic_array.json';

% --------------- Mic array topology --------------- %
N = 16;                % num. mics in array
topology = 'multi';    % 'archimedean' | 'dougherty' | 'multi'
r0 = 0.2;              % minimum radius
rmax = 1.0;            % maximum radius
plane = 'xy';          % 'xy' | 'xz' - array orientation (X-Y or the X-Z plane)

% height and width of the rectangle that the topology should be "squished"
% into
squish = true;  % enable/disable squishing
rect_h = 0.75;
rect_w = 4;

% ------ topology- dependent parameters

% -- Archimedean
phi = 4*pi;
% phi = 3*pi;

% -- Dougherty log-spiral
v_dougherty = 15/32 * pi;

% -- Multi Dougherty log-spiral
N_a  = 4;   % number of spiral arms
%v_multi = 5/16 * pi;
v_multi = 3/10 * pi;

% N_a  = 7;
% v_multi = 3/8 * pi; 

% ------- Create mic topology
array_params.topology = topology;
array_params.N = N;
array_params.r0 = r0;
array_params.rmax = rmax;
array_params.archimedean.phi = phi;
array_params.dougherty.v = v_dougherty;
array_params.multi.N_a = N_a;
array_params.multi.v = v_multi;
array_params.squish_params.do_squish = squish;
array_params.squish_params.height = rect_h;
array_params.squish_params.width = rect_w;
array_params.plane = plane;
array_params.do_plot_mic_array_indexes = 1;

R = SpecularStudio.create_array_topology(array_params);

% for i = 1:length(R)
%     R(i).location(3) = R(i).location(3) + 0.25*(rand(1) - 0.5);
% end

% % ---- plotting
plot_mic_array_topology(R, array_params);

% % ---- saving to JSON
save_mic_array_config(R, array_params, fullfile(pwd, 'geometry', 'mic_array', filename));
