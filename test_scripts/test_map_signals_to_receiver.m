close all
clc
clear all
addpath([pwd '/..']);
addpath([pwd '/../utility']);
addpath([pwd '/../jsonlab']);

% --------------- Signal properties --------------- %
fs = 32000;     % sampling rate
c = 343;        % speed of sound
len_s = 5;      % signal length in seconds
max_order = 1;  % highest reflection order to simulate

% sig_params.type = 'sine';
% sig_params.amplitude = 1.0;
% sig_params.frequency = 900;

% sig_params.type = 'whitenoise';
% sig_params.amplitude = 0.5;
% % fc = 5000;
% % fc_n = fc/(fs/2);
% % [b,a] = butter(6, fc_n, 'low');
% % sig_params.filters(1).b = b;
% % sig_params.filters(1).a = a;

sig_params.type = 'file';
% sig_params.file_path = '../audio_files/IEEEMix2_16k.wav';
sig_params.file_path = fullfile(pwd, '../audio_files/piano_44100Hz.wav');
sig_params.gain_dB = -12.0;


% --------------- Reflective surfaces --------------- %
absorption = 0.95;

i_wall = 1;
walls(i_wall) = RectangularSurface(i_wall,...
                                   [0,0,0],...
                                   [6,0,0],...
                                   [6,0,4],...
                                   [0,0,4],...
                                   absorption);
i_wall = i_wall + 1;

walls(i_wall) = RectangularSurface(i_wall,...
                                   [0,0,0],...
                                   [-1,8,0],...
                                   [-1,8,4],...
                                   [0,0,4],...
                                   absorption);
i_wall = i_wall + 1; 

walls(i_wall) = RectangularSurface(i_wall,...
                                   [6,0,0],...
                                   [7,8,0],...
                                   [7,8,4],...
                                   [6,0,4],...
                                   absorption);
i_wall = i_wall + 1; 

walls(i_wall) = RectangularSurface(i_wall,...
                                   [7,8,4],...
                                   [7,8,0],...
                                   [-1,8,0],...
                                   [-1,8,4],...
                                   absorption);
i_wall = i_wall + 1; 

%floor
walls(i_wall) = RectangularSurface(i_wall,...
                                   [7,8,0],...
                                   [-1,8,0],...
                                   [-1,0,0],...
                                   [7,0,0],...
                                   absorption);
i_wall = i_wall + 1; 

%ceiling
walls(i_wall) = RectangularSurface(i_wall,...
                                   [7,8,4],...
                                   [-1,8,4],...
                                   [-1,0,4],...
                                   [7,0,4],...
                                   absorption);
i_wall = i_wall + 1;

% --------------- Source + Receiver positions --------------- %
% Define a true pointsource      
S = [PointSource([3, 5, 2])];
% Define receivers
R = [Receiver([4, 2, 2]),...
     Receiver([2, 2, 2])];


% Instantiate a SpecularStudio object
spec_studio_params = struct();
spec_studio_params.max_order = max_order;
spec_studio_params.fs = fs;
spec_studio_params.c = c;
spec_studio_params.len_s = len_s;

SpecStudio = SpecularStudio(S, R, walls, sig_params, spec_studio_params);


tic;
% generate emitted signals
x = SpecStudio.generate_source_signals();

% generate all image sources for a point source
no_all_img_src = SpecStudio.count_all_image_sources();
disp(['Generating ' num2str(no_all_img_src) ' image sources...']);
img_list_all = SpecStudio.generate_image_sources(SpecStudio.S, SpecStudio.max_order);

img_lists = {};
y = {};
ir = {};

for i = 1:length(R)
    % run an "audibility check" on all image sources and discard the ones that
    % are not reachable through a valid path from the receiver
    disp(['Running audibility check for mic ' num2str(i) '/' num2str(length(R)) '...']);
    img_lists{i} = SpecStudio.audibility_check(img_list_all, i);
    % Assign emitted signals to each source (true source + image source) by
    % following the reflection path and applying the absorption from each wall
    % encountered along the way to the emitted signal
    disp(['Assigning signals to image sources for mic ' num2str(i) '/' num2str(length(R)) '...']);    
    img_lists{i} = SpecStudio.assign_signals_to_image_sources(img_lists{i}, x);
    % map image source signals as seen by the microphone and estimate
    % impulse response
    disp(['Mapping signals onto mic ' num2str(i) '/' num2str(length(R)) '...']);    
    [y{i}, ir{i}] = SpecStudio.map_signals_to_receiver(i, img_lists{i});
end
toc;

figure()
subplot(length(R), 1, 1)
plot(ir{1});
subplot(length(R), 1, 2)
plot(ir{2});

% %%
% Y = [y{1}; y{2}];
% soundsc(x, fs);
% pause(len_s + 1);
% soundsc(Y, fs);

%%
Y_out = [];
for i = 1:length(R)
    Y_out = [Y_out; y{i}];
end
audiowrite(fullfile(pwd, ['../output_files/wet_order_' num2str(max_order) '.wav']), Y_out', fs);
% audiowrite(fullfile(pwd, ['../output_files/dry.wav']), x, fs);