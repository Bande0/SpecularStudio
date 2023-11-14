clear all;
close all;
clc;

% --------------- General signal properties
fs = 32000;     % sampling rate
c = 343;        % speed of sound
len_s = 3;      % signal length in seconds

% --------------- Near-end Point sources
i_src = 1;
sources(i_src).location.x = 0.0;
sources(i_src).location.y = 0.0;
sources(i_src).location.z = 2.0;
sources(i_src).signal_params.type = 'sine';
sources(i_src).signal_params.amplitude = 1.0;
sources(i_src).signal_params.frequency = 450;

i_src = i_src + 1;
sources(i_src).location.x = 0.4;
sources(i_src).location.y = 0.3;
sources(i_src).location.z = 3.0;
sources(i_src).signal_params.type = 'sine';
sources(i_src).signal_params.amplitude = 1;
sources(i_src).signal_params.frequency = 960;

i_src = i_src + 1;
sources(i_src).location.x = 0.4;
sources(i_src).location.y = 0.3;
sources(i_src).location.z = -3.0;
sources(i_src).signal_params.type = 'sine';
sources(i_src).signal_params.amplitude = 1;
sources(i_src).signal_params.frequency = 1050;

% --------------- Speakers
i_spk = 1;
speakers(i_spk).location.x = -0.5;
speakers(i_spk).location.y = 0.0;
speakers(i_spk).location.z = 0.0;
fc = 2000;
fc_n = fc/(fs/2);
[b,a] = butter(6, fc_n, 'low');
speakers(i_spk).signal_params.type = 'whitenoise';
speakers(i_spk).signal_params.amplitude = 1.0;
% % speakers(i_spk).signal_params.filters(1).b = b;
% % speakers(i_spk).signal_params.filters(1).a = a;
% speakers(i_spk).signal_params.type = 'sine';
% speakers(i_spk).signal_params.amplitude = 1;
% speakers(i_spk).signal_params.frequency = 700;

i_spk = i_spk + 1;
speakers(i_spk).location.x = 0.5;
speakers(i_spk).location.y = 0.0;
speakers(i_spk).location.z = 0.0;
fc = 2000;
fc_n = fc/(fs/2);
[b,a] = butter(6, fc_n, 'high');
speakers(i_spk).signal_params.type = 'whitenoise';
speakers(i_spk).signal_params.amplitude = 1.0;
% % speakers(i_spk).signal_params.filters(1).b = b;
% % speakers(i_spk).signal_params.filters(1).a = a;
% speakers(i_spk).signal_params.type = 'sine';
% speakers(i_spk).signal_params.amplitude = 1;
% speakers(i_spk).signal_params.frequency = 600;

% --------------- Reflective surfaces
i_wall = 1;

% --------------- Mic topology params
N = 16;                     % num. mics
topology = 'multi';         % archimedean | dougherty | multi
r0 = 0.02;                  % minimum radius
rmax = 0.2;                 % maximum radius

% height and width of the rectangle that the topology should be "squished"
% into
squish = true;  % enable/disable squishing
rect_h = 0.15;
rect_w = 0.8;

% ------ topology- dependent parameters

% -- Archimedean
phi = 4*pi;
% phi = 3*pi;

% -- Dougherty log-spiral
% v_dougherty = 15/32 * pi;
v_dougherty = 0.3 * pi;

% -- Multi Dougherty log-spiral
N_a  = 4;   % number of spiral arms
%v_multi = 5/16 * pi;
v_multi = 3/10 * pi;

% N_a  = 7;
% v_multi = 3/8 * pi; 

%% ------- Create mic topology
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

rm = create_array_topology(array_params);

% rm = [[-0.3, 0, 0];
%       [-0.1, 0, 0];...
%       [0, 0, 0];...
%       [0.1, 0, 0];...      
%       [0.3, 0, 0];...      
%       ]';

%% plotting of geometry
plot_topology(rm, sources, speakers, array_params);

%% Generate emitted signals for near-end sources and speakers
sources = generate_emitted_signals(sources, len_s, fs);
speakers = generate_emitted_signals(speakers, len_s, fs);

%% map source signals onto mic array
y_src = map_signals_to_mic_array(rm, sources, c, fs);
y_spk = map_signals_to_mic_array(rm, speakers, c, fs);

%% Plot mic signals and IRs
i_spk = 1:length(speakers);
i_src = 1:length(sources);
i_mic = 1:length(rm);

for j = i_spk
    figure()
    plot(speakers(j).signal(1:500));
    hold on
    for i = i_mic
        plot(squeeze(y_spk.sigs(i, j, 1:500)));    
    end
end

for j = i_src
    figure()
    plot(sources(j).signal(1:500));
    hold on
    for i = i_mic
        plot(squeeze(y_src.sigs(i, j, 1:500)));    
    end
end
%%
for j = i_spk
    figure()
    hold on;
    for i = i_mic
        plot(squeeze(y_spk.irs(i, j, :)));
    end
end

for j = i_src
    figure()
    hold on;
    for i = i_mic
        plot(squeeze(y_src.irs(i, j, :)));
    end
end
