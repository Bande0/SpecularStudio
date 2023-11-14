% close all
clc
clear all
addpath('..\');

% --------------- Reflective surfaces
i_wall = 1;
walls(i_wall) = RectangularSurface(i_wall,...
                                   [0,0,0],...
                                   [6,0,0],...
                                   [6,0,4],...
                                   [0,0,4],...
                                   1.0);
i_wall = i_wall + 1; 

walls(i_wall) = RectangularSurface(i_wall,...
                                   [0,0,0],...
                                   [-1,8,0],...
                                   [-1,8,4],...
                                   [0,0,4],...
                                   1.0);
i_wall = i_wall + 1; 

walls(i_wall) = RectangularSurface(i_wall,...
                                   [0,0,0],...
                                   [1,8,0],...
                                   [1,8,4],...
                                   [0,0,4],...
                                   1.0);
i_wall = i_wall + 1; 

walls(i_wall) = RectangularSurface(i_wall,...
                                   [6,0,0],...
                                   [7,8,0],...
                                   [7,8,4],...
                                   [6,0,4],...
                                   1.0);
i_wall = i_wall + 1; 


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


grid on
% xlim([-2 10])
% ylim([-7 5])
% zlim([-4 8])
xlim([-6 10])
ylim([-6 10])
zlim([-6 10])
axis square

