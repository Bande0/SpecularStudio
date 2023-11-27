function [x, y, ir] = run_simulation(obj)
%TODO

    % --------------- Plot room setup --------------- %
    if obj.do_plot_room
        plot_room(obj.walls, obj.S, obj.R);
    end

    % generate/load signals emitted by point source(s)
    x = obj.generate_source_signals();
    if size(x, 1) ~= length(obj.S)
        error('ERROR: Number or source signals must match number of sources!');
    end

    img_lists = {};
    y = {};
    ir = {};    
    % loop through all point sources and generate image sources
    for i_src = 1:length(obj.S)        
        tic;

        no_all_img_src = obj.count_all_image_sources();
        disp(['Generating ' num2str(no_all_img_src) ' image sources for point source no.' num2str(i_src) '...']);
        % generate all possible image sources ("valid and "invalid") for a point source
        img_list_all = obj.generate_image_sources(obj.S(i_src), obj.max_order);

        for i_rcv = 1:length(obj.R)
            % run an "audibility check" on all image sources and discard the ones that
            % are not reachable through a valid path from the receiver
            disp(['Running audibility check for mic ' num2str(i_rcv) '/' num2str(length(obj.R)) '...']);
            img_lists{i_src, i_rcv} = obj.audibility_check(img_list_all, i_rcv);
            % Assign emitted signals to each source (true source + image source) by
            % following the reflection path and applying the absorption from each wall
            % encountered along the way to the emitted signal
            disp(['Assigning signals to image sources for mic ' num2str(i_rcv) '/' num2str(length(obj.R)) '...']);
            img_lists{i_src, i_rcv} = SpecularStudio.assign_signals_to_image_sources(img_lists{i_src, i_rcv}, x(i_src, :));
            % map image source signals as seen by the microphone and estimate
            % impulse response
            disp(['Mapping signals onto mic ' num2str(i_rcv) '/' num2str(length(obj.R)) '...']);
            [y{i_src, i_rcv}, ir{i_src, i_rcv}] = obj.map_signals_to_receiver(i_rcv, img_lists{i_src, i_rcv});
            % plot all max.order reflection paths for current source and
            % receiver
            if obj.do_plot_reflection_paths
                plot_reflection_paths(obj.walls, img_lists, i_src, i_rcv, obj.max_order);
            end
        end
        toc;

        %% plot IRs
        if obj.do_plot_IRs
            plot_irs(ir, i_src);
        end

        %% export audio
        if obj.do_export_audio
            Y_out = [];
            for i = 1:length(obj.R)
                Y_out = [Y_out; y{i_src, i}];
            end
            if ~exist(fullfile(pwd, 'output_files'), 'dir')
                mkdir(fullfile(pwd, 'output_files'));
            end
            audiowrite(fullfile(pwd, ['output_files/' obj.sig_params(i_src).name '_wet_order_' num2str(obj.max_order) '_mics_' num2str(length(obj.R)) '.wav']), Y_out', obj.fs);   
            audiowrite(fullfile(pwd, ['output_files/' obj.sig_params(i_src).name '_dry.wav']), x(i_src, :), obj.fs);
            disp([char(10) 'Output files exported to: ' char(10) fullfile(pwd, 'output_files')]);
        end

    %     %% playback
    %     Y = [y{i_src, 1}; y{i_src, 2}];
    %     soundsc(x(i_src, :), obj.fs);
    %     pause(obj.len_s + 1);
    %     soundsc(Y, obj.fs);
    %     pause(obj.len_s + 1);
    end

end

