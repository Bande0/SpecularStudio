function plot_room(walls, sources, varargin)
% plots a room geometry + optionally N'th order reflection paths between a
% source and a receiver
% Walls and source(s) are mandatory arguments, the rest is optional (used
% only for reflection path plotting)

    R = [];
    S = sources;
    img_lists_all = [];
    i_src = [];
    i_rcv = [];
    plot_order = [];     
    if ~isempty(varargin)       
       R = varargin{1} ;
       if length(varargin) > 1
           img_lists_all = varargin{2} ; 
       end
       if length(varargin) > 2
           i_src = varargin{3}; 
           S = sources(i_src);
       end
       if length(varargin) > 3
           i_rcv = varargin{4};
           R = R(i_rcv);   
       end
       if length(varargin) > 4
           plot_order = varargin{5}; 
       end           
    end
    
    % pick out the image source list for the source and receiver in
    % question    
    if length(varargin) > 4
        img_list_all = img_lists_all{i_src, i_rcv};
        % filter out only N'th order image sources
        img_list = img_list_all(find(cellfun('length', {img_list_all.path}) == plot_order));   
        titlestring = ['Number of ' num2str(plot_order) 'th order reflections ' char(10),...
                       'source no. ' num2str(i_src), char(10),...
                       ' receiver no. ' num2str(i_rcv) ' : ' char(10),...
                       num2str(length(img_list))];
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
    hold on
    
    % plotting walls
    wp_all = [];
    for w_idx = 1:length(walls)
        wp = walls(w_idx).points;
        n = walls(w_idx).normal;
        wp_all = [wp_all; wp]; % storing all wall points in an array for calculating axis limits later

        facealpha = walls(w_idx).abs_coeff * 0.9;
        
        fill3(wp(:,1), wp(:,2), wp(:,3), 'g', 'FaceAlpha', facealpha);  % surface            
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
        if length(varargin) > 4
            plot3(rcv(1), rcv(2), rcv(3),'kx','MarkerSize',10,'LineWidth',3);
        else
            plot3(rcv(1), rcv(2), rcv(3),'k.','MarkerSize',10);
        end
    end
    
    % plotting reflection paths
    if length(varargin) > 4
        clr_cnt = 1;
        for i = 1:length(img_list)

            % corner case: we are plotting the direct path
            if isempty(img_list(i).segments)
                segment = [S.location; R.location];
                line(segment(:,1), segment(:,2), segment(:,3), 'LineStyle', '--', 'Color', colors{mod(clr_cnt,length(colors)) + 1});             
            end

            for j = 1:length(img_list(i).segments)
                A = img_list(i).segments(j).start_point;
                B = img_list(i).segments(j).end_point;
                segment = [A; B];
                line(segment(:,1), segment(:,2), segment(:,3), 'LineStyle', '--', 'Color', colors{mod(clr_cnt,length(colors)) + 1});             
            end
            clr_cnt = clr_cnt + 1;      
        end
        
        title(titlestring);
    end
    
    % calculating plot axis limits
    % base limits on wall locations
    max_val = max(max(wp_all));
    min_val = min(min(wp_all));
    % corner case: if there are no walls (i.e. free field), base limits on
    % source and receiver locations
    if isempty(max_val) && isempty(min_val)
        max_val = max([R(:).location S(:).location]);
        min_val = min([R(:).location S(:).location]);       
    end
    range = max_val - min_val;
    plot_max = ceil(max_val + range*0.2);
    plot_min = floor(min_val - range*0.2);       
        
    grid on
    xlim([plot_min plot_max]);
    ylim([plot_min plot_max]);
    zlim([plot_min plot_max]);
    axis square
    view(-45, 45);
end
