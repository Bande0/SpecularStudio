function [ mic_coords, params ] = create_array_topology( params )
    
topology = params.topology; % topology type - archimedean | dougherty | multi
N = params.N;               % no. mics
r0 = params.r0;             % minimum radius
rmax = params.rmax;         % maximum radius

% "squish" the resulting topology into a containing rectangle
squish_params = params.squish_params;

% --------- Archimedean spiral
if strcmp(topology, 'archimedean')        
    phi = params.archimedean.phi;   

    mic_coords = zeros(3, N);
    for n = 1:N
        theta = (n-1)*phi/(N-1);
        rn =  r0 + (rmax - r0)/phi * theta;

        mic_coords(1, n) = rn * cos(theta);
        mic_coords(2, n) = rn * sin(theta);
    end
% --------- Dougherty log-spiral     
elseif strcmp(topology, 'dougherty')       
    v = params.dougherty.v;   % constant angle parameter 

    mic_coords = zeros(3, N);
    l_max = r0*sqrt(1 + cot(v)^2)/cot(v) * (rmax/r0 - 1);
    for n = 1:N
        l_n = (n-1)/(N-1)*l_max;
        theta = 1/cot(v) * log(1 + (cot(v)*l_n / r0*sqrt(1 + cot(v)^2)));
        rn = r0 * exp(cot(v) * theta);

        mic_coords(1, n) = rn * cos(theta);
        mic_coords(2, n) = rn * sin(theta);
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
                
    mic_coords = zeros(3, N);
    l_max = r0*sqrt(1 + cot(v)^2)/cot(v) * (rmax/r0 - 1);
    idx = 0;
    for m = 1:N_a
        for n = 1:N_m
            idx = idx + 1;   

%             l_n = (n-1)/(N_m-1)*l_max;
%             l_n = n/N_m*l_max;
            l_n = (n-1)/(N_m)*l_max;
            
            theta = 1/cot(v) * log(1 + (cot(v)*l_n / r0*sqrt(1 + cot(v)^2)));
            rn = r0 * exp(cot(v) * theta);
            % rotating the thetas based on arm index
            theta = theta + (m-1)/N_a * 2*pi;

            mic_coords(1, idx) = rn * cos(theta);
            mic_coords(2, idx) = rn * sin(theta);
        end
    end
else 
   error('Unrecognized topology: "%s"', topology); 
end

% -- squishing into a containing rectangle
if squish_params.do_squish    
    height = params.squish_params.height;
	width = params.squish_params.width; 
    
    current_height = max(mic_coords(2,:)) - min(mic_coords(2,:));
    current_width = max(mic_coords(1,:)) - min(mic_coords(1,:));

    h_squish = height / current_height;
    w_squish = width / current_width;

    % we don't "stretch", just "squish"
    if (w_squish < 1)
        mic_coords(1,:) = w_squish * mic_coords(1,:);
    end
    if (h_squish < 1)
        mic_coords(2,:) = h_squish * mic_coords(2,:);
    end
end

end