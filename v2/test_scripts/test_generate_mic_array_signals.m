% close all
clc
clear all
addpath([pwd '/..']);


% --------------- Signal properties --------------- %
fs = 32000;     % sampling rate
c = 343;        % speed of sound
len_s = 5;      % signal length in seconds

% sig_params.type = 'sine';
% sig_params.amplitude = 1.0;
% sig_params.frequency = 900;
% x = generate_source_signal(sig_params, len_s, fs); 

% sig_params.type = 'whitenoise';
% sig_params.amplitude = 0.5;
% % fc = 5000;
% % fc_n = fc/(fs/2);
% % [b,a] = butter(6, fc_n, 'low');
% % sig_params.filters(1).b = b;
% % sig_params.filters(1).a = a;
% x = generate_source_signal(sig_params, len_s, fs);

sig_params.type = 'file';
% sig_params.file_path = 'C:\git\SpecularStudio\audio_files\IEEEMix2_16k.wav';
sig_params.file_path = fullfile(pwd, '../../audio_files/piano_44100Hz.wav');
sig_params.gain_dB = -12.0;
x = generate_source_signal(sig_params, len_s, fs);


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
S = PointSource([5, 5, 2]);
 
% --------------- Mic array topology --------------- %
N = 16;                     % num. mics
topology = 'multi';         % archimedean | dougherty | multi
r0 = 0.2;                  % minimum radius
rmax = 1.0;                 % maximum radius

% height and width of the rectangle that the topology should be "squished"
% into
squish = true;  % enable/disable squishing
rect_h = 0.5;
rect_w = 2;

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
array_params.plane = 'xz';
array_params.x_offset = 3;
array_params.y_offset = 2;
array_params.z_offset = 1;

R = create_array_topology(array_params);

% R = [Receiver([4, 2, 2]),...
%      Receiver([2, 2, 2])];



% generate all possible image sources for a point source
max_order = 1;
tic;

no_all_img_src = count_all_image_sources(length(walls), max_order);
disp(['Generating ' num2str(no_all_img_src) ' image sources...']);
img_list_all = generate_image_sources(S, walls, max_order);

img_lists = {};
y = {};
ir = {};

for i = 1:length(R)
    % run an "audibility check" on all image sources and discard the ones that
    % are not reachable through a valid path from the receiver
    disp(['Running audibility check for mic ' num2str(i) '/' num2str(length(R)) '...']);
    img_lists{i} = audibility_check(img_list_all, walls, R(i));
    % Assign emitted signals to each source (true source + image source) by
    % following the reflection path and applying the absorption from each wall
    % encountered along the way to the emitted signal
    disp(['Assigning signals to image sources for mic ' num2str(i) '/' num2str(length(R)) '...']);
    img_lists{i} = assign_signals_to_image_sources(img_lists{i}, x);
    % map image source signals as seen by the microphone and estimate
    % impulse response
    disp(['Mapping signals onto mic ' num2str(i) '/' num2str(length(R)) '...']);
    [y{i}, ir{i}] = map_signals_to_receiver(R(i), img_lists{i}, c, fs);   
end
toc;

%%  plotting
colors = {[0 0.4470 0.7410],...
              [0.8500 0.3250 0.0980],... 
              [0.9290 0.6940 0.1250],...
              [0.4940 0.1840 0.5560],...
              [0.4660 0.6740 0.1880],...
              [0.3010 0.7450 0.9330],...
              [0.6350 0.0780 0.1840],...
             };
         
    
figure()

% plotting walls
for w_idx = 1:length(walls)
    wp = walls(w_idx).points;
    n = walls(w_idx).normal;

    fill3(wp(:,1), wp(:,2), wp(:,3), 'g', 'FaceAlpha', 0.5);  % surface
    hold on    
    quiver3(wp(1,1), wp(1,2), wp(1,3),...
            n(1), n(2), n(3),'LineWidth', 2, 'MaxHeadSize', 0.8);  % line normal vector
    quiver3(wp(2,1), wp(2,2), wp(2,3),...
            n(1), n(2), n(3),'LineWidth', 2, 'MaxHeadSize', 0.8);  % line normal vector
    quiver3(wp(3,1), wp(3,2), wp(3,3),...
            n(1), n(2), n(3),'LineWidth', 2, 'MaxHeadSize', 0.8);  % line normal vector   
    quiver3(wp(4,1), wp(4,2), wp(4,3),...
            n(1), n(2), n(3),'LineWidth', 2, 'MaxHeadSize', 0.8);  % line normal vector       

end

% plotting sources
for i = 1:length(S)
    src = S(i).location;
    plot3(src(1), src(2), src(3),'bx','MarkerSize',10,'LineWidth',3);
end

% plotting receivers
for i = 1:length(R)
    rcv = R(i).location;
    plot3(rcv(1), rcv(2), rcv(3),'k.','MarkerSize',10);
end

grid on
xlim([-6 10])
ylim([-6 10])
zlim([-6 10])
axis square

% plotting IRs

figure()
cols = floor(sqrt(length(R)));
rows = length(R) / cols;
cnt = 1;
for i = 1:rows
    for j = 1:cols
        subplot(rows, cols, cnt)
        plot(ir{cnt});
        cnt = cnt + 1;
    end
end

% %%
% Y = [y{1}; y{2}];
% soundsc(x, fs);
% pause(len_s + 1);
% soundsc(Y, fs);

% %%
% Y_out = [];
% for i = 1:length(R)
%     Y_out = [Y_out; y{i}];
% end
% audiowrite(fullfile(pwd, ['../../output_files/wet_order_' num2str(max_order) '_mics_' num2str(length(R)) '_topo_' topology '.wav']), Y_out', fs);
% 
% audiowrite(fullfile(pwd, ['../../output_files/dry.wav']), x, fs);
