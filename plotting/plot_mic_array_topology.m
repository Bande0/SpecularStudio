function plot_mic_array_topology(R, varargin)
    
    default_params.topology = 'custom';
    default_params.squish_params.width = 1;
    default_params.squish_params.height = 1;
    default_params.squish_params.do_squish = 0;
    default_params.plane = 'xy';
    default_params.do_plot_mic_array_indexes = 0;
   
    if isempty(varargin)
        array_params = default_params;
    else
        array_params = varargin{1};
    end

    % ---- construct title string
    try
        if strcmp(array_params.topology, 'archimedean')    
            title_string = ['Archimedean', char(10),...
                            'no. mics: ', num2str(array_params.N), char(10), ...
                            'r0: ', num2str(array_params.r0), char(10),...
                            'r_max: ', num2str(array_params.rmax), char(10),...
                            'phi: ', num2str(array_params.archimedean.phi)];
        elseif strcmp(array_params.topology, 'dougherty')   
            title_string = ['Dougherty', char(10),...
                            'no. mics: ', num2str(array_params.N), char(10), ...
                            'r0: ', num2str(array_params.r0), char(10),...
                            'r_max: ', num2str(array_params.rmax), char(10),...
                            'v: ', num2str(array_params.dougherty.v)];
        elseif strcmp(array_params.topology, 'multi')   
            title_string = ['Multi-Dougherty', char(10),...
                            'no. mics: ', num2str(array_params.N), char(10), ...
                            'no. arms: ', num2str(array_params.multi.N_a), char(10), ...
                            'r0: ', num2str(array_params.r0), char(10),...
                            'r_max: ', num2str(array_params.rmax), char(10),...
                            'v: ', num2str(array_params.multi.v)];
        elseif strcmp(array_params.topology, 'custom')
           title_string = ['Custom topology']; 
        else 
           error('Unrecognized topology: "%s"', array_params.topology); 
        end
    catch
        title_string = 'TITLE_STRING_ERROR';
    end

    % ---- plot the mic topology

    rm = [R(:).location];
    rm = reshape(rm, 3, length(R));
    
    % check if array has a depth in all dimensions
    xrange = max(rm(1, :)) - min(rm(1, :));
    yrange = max(rm(2, :)) - min(rm(2, :));
    zrange = max(rm(3, :)) - min(rm(3, :));

    % if it's a 3D array, make a simple 3D plot
    if (xrange > 0) && (yrange > 0) && (zrange > 0)
        all_max = max(max(rm));
        all_min = min(min(rm));
        max_range = max(max(rm)) - min(min(rm));
        figure()
        for i = 1:length(R)
            rcv = R(i).location;
            plot3(rcv(1), rcv(2), rcv(3),'bo');
            hold on;
            text(rcv(1) + xrange*0.05, rcv(2), rcv(3), num2str(i), 'Fontsize', 12, 'Color', [0.4940 0.1840 0.5560]); 
        end         
        
        grid on
        xlim([all_min-max_range*0.2 all_max+max_range*0.2]);
        ylim([all_min-max_range*0.2 all_max+max_range*0.2]);
        zlim([all_min-max_range*0.2 all_max+max_range*0.2]);
        axis square 
    % otherwise, do a 2D-plot
    else
        x_idx = 1;
        if strcmp(array_params.plane, 'xy') 
            y_idx = 2;
        elseif strcmp(array_params.plane, 'xz') 
            y_idx = 3;
        else
            error('ERROR! Unsupported plane: %s', plane)
        end

        % plot X/Y limits
        rect_w = array_params.squish_params.width;
        rect_h = array_params.squish_params.height;
        min_x = min(min(rm(x_idx,:)), -rect_w/2);
        min_y = min(min(rm(y_idx,:)), -rect_h/2);
        max_x = max(max(rm(x_idx,:)), rect_w/2);
        max_y = max(max(rm(y_idx,:)), rect_h/2);
        xy_lim_min = min(min_x, min_y) * 1.2;
        xy_lim_max = max(max_x, max_y) * 1.2;        

        figure('units','normalized','outerposition',[0.2 0.2 0.6 0.6])
        plot(rm(x_idx,:),rm(y_idx,:),'bo');  % mic array
        % plot mic array indexes
        if array_params.do_plot_mic_array_indexes
            for i = 1:length(rm)
                text(rm(x_idx, i) + xrange*0.05, rm(y_idx, i), num2str(i), 'Fontsize', 12, 'Color', [0.4940 0.1840 0.5560]);
            end        
        end
        hold on;
        plot(0,0,'rx','MarkerSize',12,'LineWidth',2);  % center point
        if array_params.squish_params.do_squish
            rectangle('Position', [min_x, min_y, rect_w, rect_h], 'LineStyle', '--');  % containing rectangle    
        end
        xlim([xy_lim_min xy_lim_max]);
        ylim([xy_lim_min xy_lim_max]);
        title(title_string, 'Interpreter', 'None');
        hold on
        axis square;
        grid on;
    end
end