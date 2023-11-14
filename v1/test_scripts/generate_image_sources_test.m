close all
clc
clear all
addpath('..\');

% --------------- Reflective surfaces
i_wall = 1;
walls(i_wall).idx = i_wall;
walls(i_wall).points = [[0,-4,0];...               
                        [0,-4,4];...
                        [0,2,4];...     
                        [0,2,0];...
                        ];
i_wall = i_wall + 1;                    

walls(i_wall).idx = i_wall;
walls(i_wall).points = [[0,2,0];...               
                        [0,2,4];...
                        [8,3,4];...     
                        [8,3,0];...
                        ];    
i_wall = i_wall + 1;

walls(i_wall).idx = i_wall;
walls(i_wall).points = [[0,-4,0];...               
                        [0,-4,4];...
                        [8,-5,4];...     
                        [8,-5,0];...
                        ];    
i_wall = i_wall + 1;
                                    
                    
% Define a source to be mirrored      
S = struct();
S.location = [6, -1, 2];



% initialize and verify surfaces
walls = init_surfaces(walls);
% We run this extra check now, since in this simple simulator, intersection
% points are only calculated correctly for surfaces that are rectangles and
% are parallel to at least one coordinate axis
walls = verify_surfaces(walls);

% generate all image sources for a point source
src_list = generate_image_sources(S, walls, 3);

% number of N'th order image sources
% N = 3;
% length(find(cellfun('length', {img_list.path}) == N))

%%  plotting
figure()

colors = {[0 0.4470 0.7410],...
          [0.8500 0.3250 0.0980],... 
          [0.9290 0.6940 0.1250],...
          [0.4940 0.1840 0.5560],...
          [0.4660 0.6740 0.1880],...
          [0.3010 0.7450 0.9330],...
          [0.6350 0.0780 0.1840],...
         };

% plotting walls and original source
for w_idx = 1:length(walls)
    wp = walls(w_idx).points;
    n = walls(w_idx).normal;
    
    fill3(wp(:,1), wp(:,2), wp(:,3), 'g');  % surface
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

% plotting image sources
for i = 1:size(src_list, 1)
    order = length(src_list(i).path);
    if order == 0 % original source
        P = src_list(i).location;
        plot3(P(1), P(2), P(3),'x','MarkerSize',10,'LineWidth',3,'Color',colors{mod(order,length(colors)) + 1});   % image source
    else % image sources
        iP = src_list(i).location;
        oP = src_list(i).path(end).location; % the point it got mirrored from
        plot3(iP(1), iP(2), iP(3),'x','MarkerSize',10,'LineWidth',3,'Color',colors{mod(order,length(colors)) + 1});   % image source
        intersect_line = [iP; oP];
        line(intersect_line(:,1), intersect_line(:,2), intersect_line(:,3), 'LineStyle', '--'); % line connecting original and mirrored point
    end
end

grid on
xlim([-20 20])
ylim([-20 20])
zlim([-20 20])
axis square
