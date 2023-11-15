function sig = generate_source_signal(sig_params, len_s, fs)
% Generates source signals based on the provided parameters
%
%   Input arguments:
%
%   sig_params - struct array containing signal parameters
%   len_s - length of signals to be generated (in seconds)
%   fs - sampling rate in Hz
%
%   Output arguments:
%
%   signal: emitted signal

    no_samples = len_s * fs;
    t = 0:1/fs:len_s - 1/fs; %time axis

    % load an audio file as the source signal
    if strcmp(sig_params.type, 'file')
        if ~isfield(sig_params, 'gain_dB') 
            gain = 1.0;
        else
            gain = 10^(sig_params.gain_dB / 20);
        end

        [x, fs_orig] = audioread(sig_params.file_path);        
        if fs ~= fs_orig
           x = resample(x, fs, fs_orig); 
        end
                
        sig = x(1:no_samples)' * gain;    
    else % Generate the source signal from provided parameters
        A = sig_params.amplitude;    
        if strcmp(sig_params.type, 'sine')        
            f = sig_params.frequency;
            sig = A * sin(2*pi*f*t);                
        elseif strcmp(sig_params.type, 'whitenoise')
            sig = A * rand(1,no_samples) - 0.5 * A;        
        else 
            error('Unrecognized signal type for signal nr. %s: "%s"', num2str(i), sig_params.type);
        end

        % ---- Apply filters
        % if no filters are defined, define a pass-thru as the first filter
        if ~isfield(sig_params, 'filters') 
            sig_params.filters(1).b = 1;
            sig_params.filters(1).a = 1;
        end

        for j = 1:length(sig_params.filters)
            b = sig_params.filters(j).b;
            a = sig_params.filters(j).a;
            sig = filter(b, a, sig);
        end
    end

end