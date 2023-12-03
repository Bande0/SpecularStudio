clear all
close all
clc
addpath(fullfile(pwd, '..'));
addpath(fullfile(pwd, '..', 'utility'));
addpath(fullfile(pwd, '..', 'jsonlab'));
addpath(fullfile(pwd, '..', 'plotting'));

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

res = 10;

x_sweep = linspace(xstart, xend, res);
y_sweep = linspace(ystart, yend, res);
z_sweep = linspace(zstart, zend, res);

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

fh = plot_room(scan_plane, S, [scan_plane_points, R]);

% load mic signals 
[x, fs] = audioread([pwd '/../output_files/audio/piano_wet_order_2_mics_16.wav']);

c = 343;
[y, segments] = bf_delay_and_sum_NF(R, x' , scan_plane_points(45), fs, c);

figure(fh)
ax = gca; 
hold on;
for i = 1:length(segments)
    seg = [segments(i).start_point; segments(i).end_point];
    line(seg(:,1), seg(:,2), seg(:,3), 'LineStyle', '--');             
end
