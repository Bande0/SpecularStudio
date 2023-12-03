clear all
close all
clc
addpath(fullfile(pwd, '..'));
addpath(fullfile(pwd, '..', 'utility'));
addpath(fullfile(pwd, '..', 'jsonlab'));
addpath(fullfile(pwd, '..', 'plotting'));

% speed of sound
c = 343;
% map resolution
res = 40;

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

% --- define scan plane for beamformer --- %
scan_plane = RectangularSurface(1,...
                                [0,5.5,0],...
                                [6,4.5,0],...
                                [6,4.5,4],...
                                [0,5.5,4],...
                                0.4);
% scan_plane = RectangularSurface(1,...
%                                 [7,8,4],...
%                                    [7,8,0],...
%                                    [-1,8,0],...
%                                    [-1,8,4],...
%                                 0.4);
% scan_plane = RectangularSurface(1,...
%                                 [7,8,4],...
%                                 [-1,8,4],...
%                                 [-1,0,4],...
%                                 [7,0,4],...
%                                 0.4);
                            
S = [PointSource([3, 5, 2]),...
%      PointSource([3, 3, 2]),...
    ];                          

sp = scan_plane.points;

opp_1 = find_opposite_point(scan_plane, 1);

xstart = sp(1,1);
ystart = sp(1,2);
zstart = sp(1,3);
xend = sp(opp_1,1);
yend = sp(opp_1,2);
zend = sp(opp_1,3);

x_sweep = linspace(xstart, xend, res);
y_sweep = linspace(ystart, yend, res);
z_sweep = linspace(zstart, zend, res);

% build points on the scan plane
cnt = 1;
if zstart == zend
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

% load mic signals 
[x, fs] = audioread([pwd '/../output_files/audio/piano_wet_order_2_mics_16.wav']);

%%
% Plot the scan points on the scan plane, plus the distance vector from all
% mics to a given scan point
[y, segments] = bf_delay_and_sum_NF(R, x' , scan_plane_points(45), fs, c);

fh = plot_room(scan_plane, S, [scan_plane_points, R]);

figure(fh)
ax = gca; 
hold on;
for i = 1:length(segments)
    seg = [segments(i).start_point; segments(i).end_point];
    line(seg(:,1), seg(:,2), seg(:,3), 'LineStyle', '--');             
end
%%
% beamform the signals towards all points on the scan plane and store
y = {};
Y_map = zeros(res, res);
cnt = 1;
reverseStr = '';
for i = 1:res
    for j = 1:res  
        msg = ['Generating scan point ' num2str(cnt) ' / ' num2str(res*res) '...'];
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
        y{i, j} = bf_delay_and_sum_NF(R, x' , scan_plane_points(cnt), fs, c);
        Y_map(i, j) = rms(y{i, j});
        cnt = cnt + 1;
    end
end

%%
% Plot the beamformed scan map
[X,Z] = meshgrid(x_sweep, z_sweep);
surface(X, Z, 20*log10(abs(Y_map)));

%%
% place the generated image in context in the room 3D plot
fh2 = plot_room([], S, R);

figure(fh2)
ax = gca; 
hold on;
xImage = [sp(4,1) sp(3,1); sp(1,1) sp(2,1)];
yImage = [sp(4,2) sp(3,2); sp(1,2) sp(2,2)];
zImage = [sp(4,3) sp(3,3); sp(1,3) sp(2,3)];
surf(xImage, yImage, zImage,...    % Plot the surface
     'CData', 20*log10(abs(Y_map)),...
     'FaceColor','texturemap');