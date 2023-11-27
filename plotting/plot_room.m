function plot_room(walls, S, varargin)

    if isempty(varargin)
       R = [];
    else
       R = varargin{1} ;
    end
    
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
    wp_all = [];
    for w_idx = 1:length(walls)
        wp = walls(w_idx).points;
        n = walls(w_idx).normal;
        wp_all = [wp_all; wp]; % storing all wall points in an array for calculating axis limits later

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
    
    % calculating plot axis limits
    max_val = max(max(wp_all));
    min_val = min(min(wp_all));
    range = max_val - min_val;
    plot_max = ceil(max_val + range*0.2);
    plot_min = floor(min_val - range*0.2);    
    
    grid on
    xlim([plot_min plot_max])
    ylim([plot_min plot_max])
    zlim([plot_min plot_max])
    axis square
end
