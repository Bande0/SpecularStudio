close all
clc
clear all
addpath([pwd '/..']);

% --------------- Reflective surfaces
i_wall = 1;
walls(i_wall) = RectangularSurface(i_wall,...
                                   [2,0,0],...
                                   [0,0,4],...
                                   [0,2,4],...
                                   [2,2,0],...
                                   1.0);
i_wall = i_wall + 1; 


walls(i_wall) = RectangularSurface(i_wall,...
                                   [4,0,0],...
                                   [6,0,4],...
                                   [6,2,4],...
                                   [4,2,0],...
                                   1.0);
i_wall = i_wall + 1; 

walls(i_wall) = RectangularSurface(i_wall,...
                                   [1,5,0],...
                                   [1,3,5],...
                                   [5,3,5],...
                                   [5,5,0],...
                                   1.0);
i_wall = i_wall + 1;              
                    
% define a point to be mirrored      
%P = [2, 1, 3];
P = [2, 1, 7];


% calculate intersection and mirror points
P_m = zeros(length(walls), 3);
P_int = zeros(length(walls), 3);
for i = 1:length(walls)
    [P_m(i,:), P_int(i,:)] = walls(i).mirror_point(P);
end


%%  plotting
figure()

for w_idx = 1:length(walls)
    wp = walls(w_idx).points;
    n = walls(w_idx).normal;
    iP = P_int(w_idx, :);
    mP = P_m(w_idx, :);


    fill3(wp(:,1), wp(:,2), wp(:,3), 'g');  % surface
    hold on
    plot3(P(1), P(2), P(3),'x','MarkerSize',10,'LineWidth',3);    % original point
    plot3(iP(1), iP(2), iP(3),'rx','MarkerSize',10,'LineWidth',3);  % intersect point
    plot3(mP(1), mP(2), mP(3),'kx','MarkerSize',10,'LineWidth',3);   % mirror point
    intersect_line = [P; mP];
    line(intersect_line(:,1), intersect_line(:,2), intersect_line(:,3), 'LineStyle', '--'); % line connecting original and mirrored point
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
xlim([-2 10])
ylim([-2 10])
zlim([-2 10])
axis square
