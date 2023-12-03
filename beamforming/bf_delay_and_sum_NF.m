function [y, segments] = bf_delay_and_sum_NF(R, x , P, fs, c)
%   Input arguments:
%
%   rm - mic array geometry
%   x - microphone input signals
%   P - location of focus point
%   fs - sampling frequency
%   c - speed of sound 
%
%   Output arguments:
%
%   y - beamformer output

    rm = [R(:).location];
    rm = reshape(rm, 3, length(R));

    % distance from array center to focus point
    % FIXME this assumes that the array center is at the origin
    r = sqrt(P.location(1)^2 + P.location(2)^2 + P.location(3)^2);

    % delay values from focus point to each mic
    delays = zeros(1, length(R));
    segments = []; 
    %distance from focus point to a given mic (|r-rm|) 
    for i = 1:length(R)
        dist = sqrt((P.location(1)-rm(1,i)).^2 + (P.location(2)-rm(2,i)).^2 + (P.location(3)-rm(3,i)).^2); %|r-rm|
        segment = LineSegment(P.location, rm(:,i)');
        segments = [segments segment]; 
        delays(i) = (r-dist)/c; % (|r|-|r-rm|)/c
    end

    y = zeros(1, length(x));
    % do the delay-and-sum beamforming
    % FIXME this is not undoing the amplitude, only the phase
    for i = 1:length(R)               
        tmp = SpecularStudio.delay_sig(x(i, :), delays(i), fs);
        y = y + tmp; 
    end

    y = y / (length(R)); 

end

