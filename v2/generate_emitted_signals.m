function sig_params = generate_emitted_signals(sig_params, len_s, fs)
% Generates source signals based on the provided parameters
%
%   Input arguments:
%
%   sig_params - struct array containing sources (locations and signal parameters)
%       .location: struct containing x/y/z fields for coordinates
%       .signal_params: signal parameters
%   len_s - length of signals to be generated (in seconds)
%   fs - sampling rate in Hz
%
%   Output arguments:
%
%   sig_params - Updated struct array with the generated signals stored.
%       .signal: emitted signal by the source

no_sigs = length(sig_params);
no_samples = len_s * fs;
t = 0:1/fs:len_s - 1/fs; %time axis

% generate signals and store in struct
for i = 1:no_sigs
    % ---- Generate signals
    A = sig_params(i).signal_params.amplitude;    
    if strcmp(sig_params(i).signal_params.type, 'sine')        
        f = sig_params(i).signal_params.frequency;
        sig_params(i).signal = A * sin(2*pi*f*t);                
    elseif strcmp(sig_params(i).signal_params.type, 'whitenoise')
        sig_params(i).signal = A * rand(1,no_samples) - 0.5 * A;        
    else 
        error('Unrecognized signal type for signal nr. %s: "%s"', num2str(i), sig_params(i).signal_params.type);
    end
    
    % ---- Apply filters
    % if no filters are defined, define a pass-thru as the first filter
    if ~isfield(sig_params(i).signal_params, 'filters') 
        sig_params(i).signal_params.filters(1).b = 1;
        sig_params(i).signal_params.filters(1).a = 1;
    end
    
    for j = 1:length(sig_params(i).signal_params.filters)
        b = sig_params(i).signal_params.filters(j).b;
        a = sig_params(i).signal_params.filters(j).a;
        sig_params(i).signal = filter(b, a, sig_params(i).signal);
    end
end

end