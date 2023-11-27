function [ R, params ] = create_array_topology( params )
% Creates a microphone array from different spiral equations
    
    topology = params.topology; % topology type - archimedean | dougherty | multi
    N = params.N;               % no. mics
    r0 = params.r0;             % minimum radius
    rmax = params.rmax;         % maximum radius

    if ~isfield(params, 'plane')
        plane = 'xy';
    else
        plane = params.plane;
    end
    if ~isfield(params, 'x_offset')
        x_offset = 0;
    else
        x_offset = params.x_offset;
    end
    if ~isfield(params, 'y_offset')
        y_offset = 0;
    else
        y_offset = params.y_offset;
    end
    if ~isfield(params, 'z_offset')
        z_offset = 0;
    else
        z_offset = params.z_offset;
    end

    % "squish" the resulting topology into a containing rectangle
    squish_params = params.squish_params;

    % --------- Archimedean spiral
    if strcmp(topology, 'archimedean')        
        phi = params.archimedean.phi;   

        R = [];
        for n = 1:N
            theta = (n-1)*phi/(N-1);
            rn =  r0 + (rmax - r0)/phi * theta;

            x = rn * cos(theta);
            y = rn * sin(theta);
            if strcmp(plane, 'xy') 
                mic = Receiver([x, y, 0]);
            elseif strcmp(plane, 'xz') 
                mic = Receiver([x, 0, y]);
            else
                error('ERROR! Unsupported plane: %s', plane)
            end
            mic.idx = n;
            R = [R mic];
        end
    % --------- Dougherty log-spiral     
    elseif strcmp(topology, 'dougherty')       
        v = params.dougherty.v;   % constant angle parameter 

        R = [];
        l_max = r0*sqrt(1 + cot(v)^2)/cot(v) * (rmax/r0 - 1);
        for n = 1:N
            l_n = (n-1)/(N-1)*l_max;
            theta = 1/cot(v) * log(1 + (cot(v)*l_n / r0*sqrt(1 + cot(v)^2)));
            rn = r0 * exp(cot(v) * theta);

            x = rn * cos(theta);
            y = rn * sin(theta);
            if strcmp(plane, 'xy') 
                mic = Receiver([x, y, 0]);
            elseif strcmp(plane, 'xz') 
                mic = Receiver([x, 0, y]);
            else
                error('ERROR! Unsupported plane: %s', plane)
            end
            mic.idx = n;
            R = [R mic];
        end
    % --------- Multi Dougherty log-spiral
    elseif strcmp(topology, 'multi')        
        N_a = params.multi.N_a; % number of spiral arms
        v = params.multi.v;     % constant angle parameter

        % if there are fewer mics than mic arms, throw an error
        if (N < N_a)
            error('ERROR! Can not create multi-spiral with fewer mics than arms! Mics: %d, Arms: %d', N, N_a);
        end

        % re-calculating number of mics
        N_m = floor(N/N_a); % no. mics per arm
        N = N_m * N_a;      % new N (rounded)
        params.N = N;       % storing new N in return struct

        R = [];
        l_max = r0*sqrt(1 + cot(v)^2)/cot(v) * (rmax/r0 - 1);
        idx = 0;
        for m = 1:N_a
            for n = 1:N_m
                idx = idx + 1;   

                l_n = (n-1)/(N_m)*l_max;

                theta = 1/cot(v) * log(1 + (cot(v)*l_n / r0*sqrt(1 + cot(v)^2)));
                rn = r0 * exp(cot(v) * theta);
                % rotating the thetas based on arm index
                theta = theta + (m-1)/N_a * 2*pi;

                x = rn * cos(theta);
                y = rn * sin(theta);
                if strcmp(plane, 'xy') 
                    mic = Receiver([x, y, 0]);
                elseif strcmp(plane, 'xz') 
                    mic = Receiver([x, 0, y]);
                else
                    error('ERROR! Unsupported plane: %s', plane)
                end
                mic.idx = (m-1)*N_a + n;
                R = [R mic];
            end
        end
    else 
       error('Unrecognized topology: "%s"', topology); 
    end

    % -- squishing into a containing rectangle
    if squish_params.do_squish    
        height = params.squish_params.height;
        width = params.squish_params.width; 

        rm = [R(:).location];
        rm = reshape(rm, 3, length(R));

        current_width = max(rm(1,:)) - min(rm(1,:));
        if strcmp(plane, 'xy') 
            for i = 1:length(R)
                current_height = max(rm(2,:)) - min(rm(2,:));
            end      
        elseif strcmp(plane, 'xz') 
            for i = 1:length(R)
                current_height = max(rm(3,:)) - min(rm(3,:));
            end      
        else
            error('ERROR! Unsupported plane: %s', plane)
        end

        h_squish = height / current_height;
        w_squish = width / current_width;

        % we don't "stretch", just "squish"
        if (w_squish < 1)
            for i = 1:length(R)
                R(i).location(1) = w_squish * R(i).location(1);
            end
        end
        if (h_squish < 1)
            if strcmp(plane, 'xy') 
                for i = 1:length(R)
                    R(i).location(2) = h_squish * R(i).location(2);
                end      
            elseif strcmp(plane, 'xz') 
                for i = 1:length(R)
                    R(i).location(3) = h_squish * R(i).location(3);
                end      
            else
                error('ERROR! Unsupported plane: %s', plane)
            end
        end
    end

    % adding offset to mics
    for i = 1:length(R)
        R(i).location(1) = R(i).location(1) + x_offset;
        if strcmp(plane, 'xy') 
            R(i).location(2) = R(i).location(2) + y_offset;
            R(i).location(3) = R(i).location(3) + z_offset;
        elseif strcmp(plane, 'xz') 
            R(i).location(2) = R(i).location(2) + z_offset;
            R(i).location(3) = R(i).location(3) + y_offset;
        else
            error('ERROR! Unsupported plane: %s', plane)
        end    
    end


end