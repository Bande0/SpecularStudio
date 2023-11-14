function y = map_signals_to_mic_array(rm, sources, c, fs)
% Simulates the signals seen by a microphone array in a simple soundfield
% Sources are modelled as point sources
%
% OBS currently only free-field conditions
%
%   Input arguments:
%
%   rm - [3 x M] array containing the microphone array geometry 
%        (x,y,z coordinates of each microphone)
%   sources - struct array containing sources (locations and signal parameters)
%       .location: struct containing x/y/z fields for coordinates
%       .signal_params: signal parameters
%       .signal: emitted signal by the source
%   c - speed of sound in m/s
%   fs - sampling rate in Hz
%
%   Output arguments:
%
%   y - struct containing sources signals mapped onto the microphone array
%          and impulse responses
%       .sigs: [no_mics x no_src x no_samples] array containing signals
%       .irs:  [no_mics x no_src x ir_len] array containing IRs

no_mics = size(rm,2);
no_src = length(sources);
no_samples = length(sources(1).signal);  % signal length is common for all sources

% TODO
N = 1024; % block size
ir_len = 512; % length of IRs

y.sigs = zeros(no_mics, no_src, no_samples);
y.irs = zeros(no_mics, no_src, ir_len);



% calculate distance from each mic to each source
r_src = zeros(no_mics, no_src);
for j = 1:no_src    
    % |r| = sqrt((r_s - r_m)^2)
    r_src(:,j) = sqrt((sources(j).location.x - rm(1,:)).^2 + (sources(j).location.y - rm(2,:)).^2 + (sources(j).location.z - rm(3,:)).^2);    
end

% map source signals onto mics
for i = 1:no_mics
    for j = 1:no_src        
        % y = 1/r * x(t - r/c) 
        y.sigs(i, j, :) = 1/r_src(i,j) * delay_sig(sources(j).signal, r_src(i,j)/c, fs);  
    end
end

%% Calculate IRs
% truncate to integer number of blocks
L = floor(no_samples / N)*N;

for j = 1:no_src
    % ref signal (i.e. source)
    x = squeeze(sources(j).signal(1:L));
    x = reshape(x, N, L/N);
    % Duplicate frames to get 50 % overlap
    x = [zeros(N,1), x(:,1:end-1); x];
    % Apply Hanning window
    x = x .* (hanning(2*N, 'periodic') * ones(1, L/N));
    % Compute FFT to go to "STFT" domain    
    X = fft(x, 2*N);
    
    for i = 1:no_mics    
        d = squeeze(y.sigs(i, j, 1:L));
        d = reshape(d, N, L/N);       
        
        % Duplicate frames to get 50 % overlap
        d = [zeros(N,1), d(:,1:end-1); d];
        % Apply hanning window
        d = d .* (hanning(2*N, 'periodic') * ones(1, L/N));
        % Compute FFT to go to "STFT" domain
        D = fft(d, 2*N);
        
        % Compute auto corr and xcorr
        Sxd = mean(conj(X) .* D, 2);
        Sxx = mean(conj(X) .* X, 2);

        % compute impulse response
        ir = ifft(Sxd ./ Sxx);
        y.irs(i, j, :) = ir(1:ir_len); 
    end
end


end