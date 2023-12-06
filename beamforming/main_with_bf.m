clear all
close all
clc
addpath(fullfile(pwd, '..'));
addpath(fullfile(pwd, '..', 'utility'));
addpath(fullfile(pwd, '..', 'jsonlab'));
addpath(fullfile(pwd, '..', 'plotting'));

% -------- Maximum reflection order to simulate -------- %
max_order = 2;
% -------- Beamformer "map" resolution -------- %
res = 25;

% --------------- Load Room Configuration --------------- %
room_json = 'room_default.json';
[S, walls] = load_room_config(fullfile(pwd, '..', 'geometry', 'room', room_json));

% % Uncomment this for manually defining point source locations (this will
% % overwrite the pointsources defined in the room JSON
% S = [PointSource([2, 5, 2]),...
%      PointSource([5, 5, 2]),...
%     ];
S = [PointSource([3, 5, 2]),...
     PointSource([5, 5, 2]),...
    ];
% --------------- Load Mic Array --------------- %
mic_json = 'mic_array_default.json';
R = load_mic_array_config(fullfile(pwd, '..', 'geometry', 'mic_array', mic_json));

R = SpecularStudio.swap_mic_coordinates(R, 'y', 'z');
R = SpecularStudio.add_offsets_to_mic_array(R, 3, 1, 2);

% % Uncomment this for manually defining receiver locations (this will
% % overwrite the receivers defined in the mic array JSON
% R = [Receiver([4, 2, 2]),...
%      Receiver([2, 2, 2]),...
%      ];

% ----------- define scan plane for beamformer ----------- %
scan_plane = RectangularSurface(1,...
                                [0,5,0],...
                                [6,5,0],...
                                [6,5,4],...
                                [0,5,4],...
                                0.4);
                            
% ----------- Generate/Load signals emitted by point sources ----------- %
fs = 16000;     % sampling rate
c = 343;        % speed of sound
len_s = 3;      % signal length in seconds

i_sig = 1;
sig_params = struct();

% sig_params(i_sig).type = 'file';
% sig_params(i_sig).name = 'piano';
% sig_params(i_sig).file_path = fullfile(pwd, '..', 'audio_files/piano_44100Hz.wav');
% sig_params(i_sig).gain_dB = -6.0;
% i_sig = i_sig + 1;

sig_params(i_sig).type = 'whitenoise';
sig_params(i_sig).amplitude = 0.5;
fc = 2000;
fc_n = fc/(fs/2);
[b,a] = butter(6, fc_n, 'low');
sig_params(i_sig).filters(1).b = b;
sig_params(i_sig).filters(1).a = a;
i_sig = i_sig + 1;

sig_params(i_sig).type = 'whitenoise';
sig_params(i_sig).amplitude = 0.5;
fc = 2000;
fc_n = fc/(fs/2);
[b,a] = butter(6, fc_n, 'low');
sig_params(i_sig).filters(1).b = b;
sig_params(i_sig).filters(1).a = a;
i_sig = i_sig + 1;

% ----------- Run simulation with SpecularStudio ----------- %
spec_studio_params = struct();
spec_studio_params.max_order = max_order;
spec_studio_params.fs = fs;
spec_studio_params.c = c;
spec_studio_params.len_s = len_s;
spec_studio_params.do_plot_room = 0;
spec_studio_params.do_plot_IRs = 0;
spec_studio_params.do_plot_reflection_paths = 0;
spec_studio_params.do_export_audio = 0;
spec_studio_params.do_export_irs = 0;

SpecStudio = SpecularStudio(S, R, walls, sig_params, spec_studio_params);
[x, y_tmp, ir] = SpecStudio.run_simulation();

% reshape output from simulation to 2D-array
no_mics = length(R);
no_samples = length(y_tmp{1, 1});
no_src = length(S);
y_sim = zeros(no_samples, no_mics);

for i = 1:no_src
    tmp = cell2mat({y_tmp{i, :}});
    tmp = reshape(tmp, no_samples, no_mics);
    y_sim = y_sim + tmp;
end


% ----------- define points on the scan plane ----------- %
sp = scan_plane.points;
opp_1 = find_opposite_point(scan_plane, 1);

x_sweep = linspace(sp(1,1), sp(opp_1,1), res);
y_sweep = linspace(sp(1,2), sp(opp_1,2), res);
z_sweep = linspace(sp(1,3), sp(opp_1,3), res);

cnt = 1;
if z_sweep(1) == z_sweep(end)
    for i = 1:res
        for j = 1:res       
            scan_plane_points(cnt) = Receiver([x_sweep(j), y_sweep(i), z_sweep(j)]);
            cnt = cnt + 1;
        end
    end
else
    for i = 1:res
        for j = 1:res       
            scan_plane_points(cnt) = Receiver([x_sweep(j), y_sweep(j), z_sweep(i)]);
            cnt = cnt + 1;
        end
    end
end

%%
% Plot the scan points on the scan plane, plus the distance vector from all
% mics to a given scan point
[~, segments] = bf_delay_and_sum_NF(R, y_sim' , scan_plane_points(45), fs, c);

fh = plot_room([scan_plane walls], S, [scan_plane_points, R]);

figure(fh)
ax = gca; 
hold on;
for i = 1:length(segments)
    seg = [segments(i).start_point; segments(i).end_point];
    line(seg(:,1), seg(:,2), seg(:,3), 'LineStyle', '--');             
end
%%
% beamform the signals towards all points on the scan plane and store
y_bf = {};
Y_map = zeros(res, res);
cnt = 1;
reverseStr = '';
for i = 1:res
    for j = 1:res  
        msg = ['Generating scan point ' num2str(cnt) ' / ' num2str(res*res) '...'];
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
        y_bf{i, j} = bf_delay_and_sum_NF(R, y_sim' , scan_plane_points(cnt), fs, c);
        Y_map(i, j) = rms(y_bf{i, j});
        cnt = cnt + 1;
    end
end

%%
% Plot the beamformed scan map
[X,Z] = meshgrid(x_sweep, z_sweep);
figure();
surface(X, Z, 20*log10(abs(Y_map)));

%%
% place the generated image in context in the room 3D plot

% reduce the absorption coefficient in the walls so that they are plottet
% more transparent
walls_to_plot = walls;
for i = 1:length(walls_to_plot)
    walls_to_plot(i).abs_coeff = 0.1;
end

fh2 = plot_room(walls_to_plot, S, R);

figure(fh2)
ax = gca; 
hold on;
xImage = [sp(4,1) sp(3,1); sp(1,1) sp(2,1)];
yImage = [sp(4,2) sp(3,2); sp(1,2) sp(2,2)];
zImage = [sp(4,3) sp(3,3); sp(1,3) sp(2,3)];
surf(xImage, yImage, zImage,...    % Plot the surface
     'CData', 20*log10(abs(Y_map)),...
     'FaceColor','texturemap');