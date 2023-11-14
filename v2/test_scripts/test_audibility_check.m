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
                                
                    
% Define a source to be mirrored      
S = struct();
S.location = [3, 4, 2];
% Define a receiver
R.location = [5, 2, 2];     


% generate all image sources for a point source
max_order = 4;
src_list = generate_image_sources(S, walls, max_order);
% run an audibility check on the image sources
src_list_valid = verify_image_sources(src_list, walls, R);

%%  plotting
colors = {[0 0.4470 0.7410],...
              [0.8500 0.3250 0.0980],... 
              [0.9290 0.6940 0.1250],...
              [0.4940 0.1840 0.5560],...
              [0.4660 0.6740 0.1880],...
              [0.3010 0.7450 0.9330],...
              [0.6350 0.0780 0.1840],...
             };
         
for plot_order = 1:max_order    
    % number of N'th order image sources
    no_refl = length(find(cellfun('length', {src_list_valid.path}) == plot_order));    
    titlestring = ['Number of ' num2str(plot_order) 'th order reflections: ' num2str(no_refl)];

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

    % plotting source
    src = S.location;
    plot3(src(1), src(2), src(3),'bx','MarkerSize',10,'LineWidth',3);

    % plotting receiver
    rcv = R.location;
    plot3(rcv(1), rcv(2), rcv(3),'kx','MarkerSize',10,'LineWidth',3);

    % plotting image sources
    for i = 1:size(src_list_valid, 1)
        order = length(src_list_valid(i).path);
        if order == 0 % original source
            P = src_list_valid(i).location;
            plot3(P(1), P(2), P(3),'x','MarkerSize',10,'LineWidth',3,'Color',colors{mod(order,length(colors)) + 1});   % image source
        elseif order == plot_order % image sources
            iP = src_list_valid(i).location;
            oP = src_list_valid(i).path(end).location; % the point it got mirrored from
            plot3(iP(1), iP(2), iP(3),'x','MarkerSize',10,'LineWidth',3,'Color',colors{mod(order,length(colors)) + 1});   % image source
            %intersect_line = [iP; oP];
            %line(intersect_line(:,1), intersect_line(:,2), intersect_line(:,3), 'LineStyle', '--'); % line connecting original and mirrored point
        end
    end

    % plotting reflection paths
    clr_cnt = 1;
    for i = 1:size(src_list_valid, 1)
        order = length(src_list_valid(i).path);
        if order == plot_order
            for j = 1:length(src_list_valid(i).segments)
                A = src_list_valid(i).segments(j).start;
                B = src_list_valid(i).segments(j).end;
                segment = [A; B];
                line(segment(:,1), segment(:,2), segment(:,3), 'LineStyle', '--', 'Color', colors{mod(clr_cnt,length(colors)) + 1});             
            end
            clr_cnt = clr_cnt + 1;
        end
    end

    grid on
    % xlim([-2 10])
    % ylim([-7 5])
    % zlim([-4 8])
    xlim([-6 10])
    ylim([-6 10])
    zlim([-6 10])
    axis square
    title(titlestring);
end
