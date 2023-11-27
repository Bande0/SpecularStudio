function sig = generate_source_signals(obj)
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

    sig_params = obj.sig_params;
    len_s = obj.len_s;
    fs = obj.fs;

    no_samples = len_s * fs;
    sig = zeros(length(sig_params), no_samples);
    
    for i_sig = 1:length(sig_params)
        % load an audio file as the source signal
        if strcmp(sig_params(i_sig).type, 'file')
            if ~isfield(sig_params(i_sig), 'gain_dB') 
                gain = 1.0;
            else
                gain = 10^(sig_params(i_sig).gain_dB / 20);
            end

            [x, fs_orig] = audioread(sig_params(i_sig).file_path);        
            if fs ~= fs_orig
               x = resample(x, fs, fs_orig); 
            end

            sig(i_sig, :) = x(1:no_samples)' * gain;    
        else % Generate the source signal from provided parameters
            A = sig_params(i_sig).amplitude;    
            if strcmp(sig_params(i_sig).type, 'sine')        
                f = sig_params(i_sig).frequency;
                t = 0:1/fs:len_s - 1/fs; %time axis
                sig(i_sig, :) = A * sin(2*pi*f*t);                
            elseif strcmp(sig_params(i_sig).type, 'whitenoise')
                sig(i_sig, :) = A * rand(1,no_samples) - 0.5 * A;        
            else 
                error('Unrecognized signal type for signal nr. %s: "%s"', num2str(i), sig_params.type);
            end

            % ---- Apply filters
            % if no filters are defined, define a pass-thru as the first filter
            if ~isfield(sig_params(i_sig), 'filters') 
                sig_params(i_sig).filters(1).b = 1;
                sig_params(i_sig).filters(1).a = 1;
            end

            for j = 1:length(sig_params(i_sig).filters)
                b = sig_params(i_sig).filters(j).b;
                a = sig_params(i_sig).filters(j).a;
                sig(i_sig, :) = filter(b, a, sig(i_sig, :));
            end
        end
    end

end