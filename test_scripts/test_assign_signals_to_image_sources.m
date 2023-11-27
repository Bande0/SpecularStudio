close all
clc
clear all
addpath([pwd '/..']);


% --------------- Signal properties --------------- %
fs = 32000;     % sampling rate
c = 343;        % speed of sound
len_s = 3;      % signal length in seconds
max_order = 4;  % highest reflection order to simulate
 
% sig_params.type = 'sine';
% sig_params.amplitude = 1.0;
% sig_params.frequency = 900;

% sig_params.type = 'whitenoise';
% sig_params.amplitude = 0.5;
% fc = 5000;
% fc_n = fc/(fs/2);
% [b,a] = butter(6, fc_n, 'low');
% sig_params.filters(1).b = b;
% sig_params.filters(1).a = a;

sig_params.type = 'file';
sig_params.file_path = fullfile(pwd, '../audio_files/IEEEMix2_16k.wav');
sig_params.gain_dB = -12.0;

% --------------- Reflective surfaces --------------- %
i_wall = 1;
walls(i_wall) = RectangularSurface(i_wall,...
                                   [0,0,0],...
                                   [6,0,0],...
                                   [6,0,4],...
                                   [0,0,4],...
                                   0.9);
i_wall = i_wall + 1;

walls(i_wall) = RectangularSurface(i_wall,...
                                   [0,0,0],...
                                   [-1,8,0],...
                                   [-1,8,4],...
                                   [0,0,4],...
                                   0.9);
i_wall = i_wall + 1; 

walls(i_wall) = RectangularSurface(i_wall,...
                                   [6,0,0],...
                                   [7,8,0],...
                                   [7,8,4],...
                                   [6,0,4],...
                                   0.9);
i_wall = i_wall + 1; 


% Define a true pointsource      
S = PointSource([3, 4, 2]);
% Define a receiver
R = Receiver([5, 2, 2]);

% Instantiate a SpecularStudio object
spec_studio_params = struct();
spec_studio_params.max_order = max_order;
spec_studio_params.fs = fs;
spec_studio_params.c = c;
spec_studio_params.len_s = len_s;

SpecStudio = SpecularStudio(S, R, walls, sig_params, spec_studio_params);

x = SpecStudio.generate_source_signals();

% generate all image sources for a point source
img_list = SpecStudio.generate_image_sources(SpecStudio.S, SpecStudio.max_order);

% run an "audibility check" on all image sources and discard the ones that
% are not reachable through a valid path from the receiver
img_list_valid = SpecStudio.audibility_check(img_list, 1);

% Assign emitted signals to each source (true source + image source) by
% following the reflection path and applying the absorption from each wall
% encountered along the way to the emitted signal
img_list_valid = SpecStudio.assign_signals_to_image_sources(img_list_valid, x);

figure()
for i = 1:length(img_list_valid)
    plot(img_list_valid(i).emitted_signal(10000:15000));
    hold on;
end
