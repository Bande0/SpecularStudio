function y = delay_sig(x, delay_sec, fs)
% delays a signal by a given amount of seconds using linear phase filtering
% in the freq. domain

    % take a long FFT of the full signal
    no_samples = length(x);
    NFFT = 2^nextpow2(no_samples);
    f = fs*(0:NFFT/2)/NFFT;  % freq. axis including Nyquist frequency
    
    X = fft(x, NFFT);
    X1 = X(1:NFFT/2+1); % keep half of the FFT + nyquist freq.

    % define a linear phase delay filter
    D = exp(-1i*2*pi*f*delay_sec);

    Y1 = X1.* D;

    Y = [Y1 conj(Y1(end-1: -1: 2))]; % reconstruct full FFT
    y = real(ifft(Y));
    y = y(1:no_samples);

end






