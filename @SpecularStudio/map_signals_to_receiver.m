function [y, ir] = map_signals_to_receiver(obj, i_rcv, img_src_list)
% Simulates the signals seen by a microphone array in a simple soundfield
% including a point source and specular reflections modelled as image
% sources
%
%   Input arguments:
%
%   r - [3 x 1] array containing the x/y/z coordinates of the microphone
%   img_src_list: list of PointSource objects, each defining a source 
%   (either a physical or image source). The list elements contain the
%   following:
%         .location - x/y/z coordinates of the source
%         .emitted_signal - the signal radiated by the (image) source
%         .path - struct array describing the reflection path through which
%               the source has been obtained (empty struct for original source)
%         .segments
%         .idx
%         .order
%   c - speed of sound in m/s
%   fs - sampling rate in Hz
%
%   Output arguments:
%
%   y:  microphone signal
%   ir: Impulse response between mic and source

c = obj.c;
fs = obj.fs;
r = obj.R(i_rcv).location';

if ~all(size(r) == [3 1])
   error('ERROR! Microphone geometry has wrong format - it must be an array of size 3 x 1'); 
end

no_img_src = length(img_src_list);
no_samples = length(img_src_list(1).emitted_signal);  % signal length is common for all sources

% calculate distance from each mic to each (image) source
r_src = zeros(1, no_img_src);
for j = 1:no_img_src    
    % |r| = sqrt((r_s - r_m)^2)
    r_src(j) = sqrt((img_src_list(j).location(1) - r(1)).^2 + (img_src_list(j).location(2) - r(2)).^2 + (img_src_list(j).location(3) - r(3)).^2);    
end

% we take the largest of the source-receiver distances and adjust the
% necessary length for estimated impulse responses accordingly
max_delay_samples = max(r_src)/c * fs;
ir_len = 2^nextpow2(max_delay_samples); % length of IRs
no_blocks = 8;  % number of blocks we want to divide the full signal into 
N = 2^(nextpow2(no_samples / no_blocks) - 1);  % block size that satisfies this

% map source signals onto mics
y = zeros(1, no_samples);
for j = 1:no_img_src
    % y = 1/r * x(t - r/c) 
    img_sig = 1/r_src(j) * SpecularStudio.delay_sig(img_src_list(j).emitted_signal, r_src(j)/c, fs);
    y = y + img_sig;      
end

%% Calculate IRs
% truncate to integer number of blocks
L = floor(no_samples / N)*N;

% ref signal (i.e. true source) - it is always the first in the list
x = squeeze(img_src_list(1).emitted_signal(1:L));
% [Pxx,F] = pwelch(x, 1024, 256, 256, fs);
x = reshape(x, N, L/N);
% Duplicate frames to get 50 % overlap
x = [zeros(N,1), x(:,1:end-1); x];
% Apply Hanning window
x = x .* (hanning(2*N, 'periodic') * ones(1, L/N));
% Compute FFT to go to "STFT" domain    
X = fft(x, 2*N);


d = squeeze(y(1:L));
% [Pdd,F] = pwelch(d, 1024, 256, 256, fs);
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
ir = ir(1:ir_len); 

end