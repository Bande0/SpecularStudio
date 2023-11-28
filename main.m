close all
clc
clear all
addpath(fullfile(pwd, 'jsonlab'));
addpath(fullfile(pwd, 'utility'));
addpath(fullfile(pwd, 'plotting'));

% -------- Maximum reflection order to simulate -------- %
max_order = 1;

% --------------- Load Room Configuration --------------- %
room_json = 'room_default.json';
[S, walls] = load_room_config(fullfile(pwd, 'geometry', 'room', room_json));

% walls = [];
% walls = walls(1);
% walls = [walls(1) walls(2)];

% % Uncomment this for manually defining point source locations (this will
% % overwrite the pointsources defined in the room JSON
S = [PointSource([3, 5, 2]),...
%      PointSource([3, 3, 2]),...
    ];

% --------------- Load Mic Array --------------- %
mic_json = 'mic_array_default.json';
R = load_mic_array_config(fullfile(pwd, 'geometry', 'mic_array', mic_json));

R = SpecularStudio.swap_mic_coordinates(R, 'y', 'z');
R = SpecularStudio.add_offsets_to_mic_array(R, 3, 1, 2);

% % Uncomment this for manually defining receiver locations (this will
% % overwrite the receivers defined in the mic array JSON
R = [Receiver([4, 2, 2]),...
%      Receiver([2, 2, 2]),...
     ];

% ----------- Generate/Load signals emitted by point sources ----------- %
fs = 32000;     % sampling rate
c = 343;        % speed of sound
len_s = 5;      % signal length in seconds

i_sig = 1;
sig_params = struct();

sig_params(i_sig).type = 'file';
sig_params(i_sig).name = 'piano';
sig_params(i_sig).file_path = fullfile(pwd, 'audio_files/piano_44100Hz.wav');
sig_params(i_sig).gain_dB = -6.0;
i_sig = i_sig + 1;

% sig_params(i_sig).type = 'sine';
% sig_params(i_sig).name = 'sine_500';
% sig_params(i_sig).amplitude = 1.0;
% sig_params(i_sig).frequency = 500;
% sig_params(i_sig).gain_dB = 0.0;
% i_sig = i_sig + 1;
% 
% sig_params(i_sig).type = 'whitenoise';
% sig_params(i_sig).name = 'whitenoise';
% sig_params(i_sig).amplitude = 1.0;
% sig_params(i_sig).gain_dB = 0.0;
% i_sig = i_sig + 1;

% sig_params(i_sig).type = 'file';
% sig_params(i_sig).name = 'IEEEMix2';
% sig_params(i_sig).file_path = fullfile(pwd, 'audio_files/IEEEMix2_16k.wav');
% sig_params(i_sig).gain_dB = -6.0;
% i_sig = i_sig + 1;

% ----------- Run simulation with SpecularStudio ----------- %
spec_studio_params = struct();
spec_studio_params.max_order = max_order;
spec_studio_params.fs = fs;
spec_studio_params.c = c;
spec_studio_params.len_s = len_s;
spec_studio_params.do_plot_room = 0;
spec_studio_params.do_plot_IRs = 1;
spec_studio_params.do_plot_reflection_paths = 0;
spec_studio_params.do_export_audio = 1;

SpecStudio = SpecularStudio(S, R, walls, sig_params, spec_studio_params);
[x, y, ir] = SpecStudio.run_simulation();
