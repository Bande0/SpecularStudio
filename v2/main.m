% close all
clc
clear all
addpath([pwd '/..']);

% -------- Maximum reflection order to simulate -------- %
max_order = 3;

% --------------- Load Room Configuration --------------- %
room_json = 'room.json';
[S, walls] = load_room_config([pwd '/' room_json]);

% S = [PointSource([3, 5, 2]),...
%      PointSource([3, 3, 2]),...
%     ];

% --------------- Load Mic Array --------------- %
mic_json = 'mic_array.json';
R = load_mic_array_config(mic_json);

R = swap_mic_coordinates(R, 'y', 'z');
R = add_offsets_to_mic_array(R, 3, 1, 2);

% R = [Receiver([4, 2, 2]),...
%      Receiver([2, 2, 2])];

% --------------- Plot room setup --------------- %
plot_room(walls, S, R);

% ----------- Generate source signals ----------- %
fs = 32000;     % sampling rate
c = 343;        % speed of sound
len_s = 5;      % signal length in seconds

i_sig = 1;
sig_params = struct();
sig_params(i_sig).type = 'file';
sig_params(i_sig).name = 'piano';
sig_params(i_sig).file_path = fullfile(pwd, '../audio_files/piano_44100Hz.wav');
sig_params(i_sig).gain_dB = -6.0;
i_sig = i_sig + 1;

% sig_params(i_sig).type = 'file';
% sig_params(i_sig).name = 'IEEEMix2';
% sig_params(i_sig).file_path = fullfile(pwd, '../audio_files/IEEEMix2_16k.wav');
% sig_params(i_sig).gain_dB = -6.0;
% i_sig = i_sig + 1;


spec_studio_params = struct();
spec_studio_params.max_order = max_order;
spec_studio_params.fs = fs;
spec_studio_params.c = c;
spec_studio_params.len_s = len_s;
spec_studio_params.do_plot_IRs = 1;
spec_studio_params.do_plot_reflection_paths = 1;
spec_studio_params.do_export_audio = 1;

SpecStudio = SpecularStudio(S, R, walls, sig_params, spec_studio_params);
[x, y, ir] = SpecStudio.run_simulation();
