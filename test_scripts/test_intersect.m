close all
clc
clear all
addpath([pwd '/..']);


i_wall = 1;
walls(i_wall) = RectangularSurface(1,...
                                   [2,0,0],...
                                   [0,0,4],...
                                   [0,2,4],...
                                   [2,2,0],...
                                   1.0);
                    
P1 = [-1, 1, 4];
P2 = [5, 2, 0];

P_int = zeros(length(walls), 3);
for i = 1:length(walls)
    [P_int(i,:), contains] = walls(i).intersect(P1, P2);
end

%%  plotting
figure()

for w_idx = 1:length(walls)
    wp = walls(w_idx).points;
    n = walls(w_idx).normal;
    iP = P_int(w_idx, :);

    fill3(wp(:,1), wp(:,2), wp(:,3), 'g');  % surface
    hold on
    plot3(P1(1), P1(2), P1(3),'x','MarkerSize',10,'LineWidth',3);    % original point 1
    plot3(P2(1), P2(2), P2(3),'kx','MarkerSize',10,'LineWidth',3);    % original point 2
    plot3(iP(1), iP(2), iP(3),'rx','MarkerSize',10,'LineWidth',3);  % intersect point    
    intersect_line = [P1; P2];
    line(intersect_line(:,1), intersect_line(:,2), intersect_line(:,3), 'LineStyle', '--'); % line connecting original points
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

