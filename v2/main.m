% close all
clc
clear all
addpath([pwd '/..']);

% -------- Maximum reflection order to simulate -------- %
max_order = 4;

% --------------- Load Room Configuration --------------- %
room_json = 'room.json';
[S, walls] = load_room_config([pwd '/' room_json]);

S = [PointSource([3, 5, 2]),...
     PointSource([3, 3, 2]),...
    ];

% --------------- Load Mic Array --------------- %
% mic_json = 'mic_array.json';
% R = load_mic_array_config(mic_json);
% 
% R = swap_mic_coordinates(R, 'y', 'z');
% R = add_offsets_to_mic_array(R, 3, 1, 2);

R = [Receiver([4, 2, 2]),...
     Receiver([2, 2, 2])];

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

sig_params(i_sig).type = 'file';
sig_params(i_sig).name = 'IEEEMix2';
sig_params(i_sig).file_path = fullfile(pwd, '../audio_files/IEEEMix2_16k.wav');
sig_params(i_sig).gain_dB = -6.0;
i_sig = i_sig + 1;

x = generate_source_signals(sig_params, len_s, fs);

if size(x, 1) ~= length(S)
    error('ERROR: Number or source signals must match number of sources!');
end

img_lists = {};
y = {};
ir = {};
for i_src = 1:length(S)
    % generate all possible image sources for a point source
    tic;

    no_all_img_src = count_all_image_sources(length(walls), max_order);
    disp(['Generating ' num2str(no_all_img_src) ' image sources for point source no.' num2str(i_src) '...']);
    img_list_all = generate_image_sources(S(i_src), walls, max_order);
   
    for i_rcv = 1:length(R)
        % run an "audibility check" on all image sources and discard the ones that
        % are not reachable through a valid path from the receiver
        disp(['Running audibility check for mic ' num2str(i_rcv) '/' num2str(length(R)) '...']);
        img_lists{i_src, i_rcv} = audibility_check(img_list_all, walls, R(i_rcv));
        % Assign emitted signals to each source (true source + image source) by
        % following the reflection path and applying the absorption from each wall
        % encountered along the way to the emitted signal
        disp(['Assigning signals to image sources for mic ' num2str(i_rcv) '/' num2str(length(R)) '...']);
        img_lists{i_src, i_rcv} = assign_signals_to_image_sources(img_lists{i_src, i_rcv}, x(i_src, :));
        % map image source signals as seen by the microphone and estimate
        % impulse response
        disp(['Mapping signals onto mic ' num2str(i_rcv) '/' num2str(length(R)) '...']);
        [y{i_src, i_rcv}, ir{i_src, i_rcv}] = map_signals_to_receiver(R(i_rcv), img_lists{i_rcv}, c, fs);   
        
        plot_reflection_paths(walls, img_lists, i_src, i_rcv, max_order);
    end
    toc;
    
    %% plot IRs
    figure()
    cols = floor(sqrt(length(R)));
    rows = length(R) / cols;
    cnt = 1;
    for i = 1:rows
        for j = 1:cols
            subplot(rows, cols, cnt)
            plot(ir{i_src, cnt});
            cnt = cnt + 1;
        end
    end

    %% export audio
    Y_out = [];
    for i = 1:length(R)
        Y_out = [Y_out; y{i_src, i}];
    end
    audiowrite(fullfile(pwd, ['../output_files/' sig_params(i_src).name '_wet_order_' num2str(max_order) '_mics_' num2str(length(R)) '.wav']), Y_out', fs);   
    audiowrite(fullfile(pwd, ['../output_files/' sig_params(i_src).name '_dry.wav']), x(i_src, :), fs);

%     %% playback
%     Y = [y{i_src, 1}; y{i_src, 2}];
%     soundsc(x(i_src, :), fs);
%     pause(len_s + 1);
%     soundsc(Y, fs);
%     pause(len_s + 1);
end
