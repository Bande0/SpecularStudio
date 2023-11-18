function plot_reflection_paths(walls, img_lists_all, i_src, i_rcv, plot_order)
    % pick out the image source list for the source and receiver in
    % question
    img_list_all = img_lists_all{i_src, i_rcv};

    colors = {[0 0.4470 0.7410],...
              [0.8500 0.3250 0.0980],... 
              [0.9290 0.6940 0.1250],...
              [0.4940 0.1840 0.5560],...
              [0.4660 0.6740 0.1880],...
              [0.3010 0.7450 0.9330],...
              [0.6350 0.0780 0.1840],...
             };
   
    % filter out only N'th order image sources
    img_list = img_list_all(find(cellfun('length', {img_list_all.path}) == plot_order));   
    titlestring = ['Number of ' num2str(plot_order) 'th order reflections ' char(10),...
                   'source no. ' num2str(i_src), char(10),...
                   ' receiver no. ' num2str(i_rcv) ' : ' char(10),...
                   num2str(length(img_list))];

    % source location is always the 1st element in the full image list:
    S = img_list_all(1).location;
    % Receiver location is always the start point of the first segment of
    % any reflection path (as the segments were constructed by backtracing,
    % starting from the receiver.
    % However, for "0'th order" (i.e: direct path) the segments parameter
    % is not filled out so we will just go with the second element of the
    % image source list 
    R = img_list(2).segments.start_point;
        
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

    % plotting source
    plot3(S(1), S(2), S(3),'bx','MarkerSize',10,'LineWidth',3);

    % plotting receiver
    plot3(R(1), R(2), R(3),'kx','MarkerSize',10,'LineWidth',3);

    % plotting reflection paths
    clr_cnt = 1;
    for i = 1:length(img_list)
        for j = 1:length(img_list(i).segments)
            A = img_list(i).segments(j).start_point;
            B = img_list(i).segments(j).end_point;
            segment = [A; B];
            line(segment(:,1), segment(:,2), segment(:,3), 'LineStyle', '--', 'Color', colors{mod(clr_cnt,length(colors)) + 1});             
        end
        clr_cnt = clr_cnt + 1;      
    end

    % FIXME hardcoded axis limits
    grid on
    xlim([-6 10])
    ylim([-6 10])
    zlim([-6 10])
    axis square
    title(titlestring);

end