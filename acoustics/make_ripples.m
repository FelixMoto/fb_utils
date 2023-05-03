function out = make_ripples(y, fs, ripple_fs, N, gain)
%
% function that creates ripples in the input array
% designed to be used for acoustic processing
%
% input:
%   y - 1D vector with data 
%   fs - sample rate of y (Hz)
%   ripple_fs - frequency of ripples (Hz)
%   N - number of iterations for ripple effect
%   gain - ripple attenuation factor - can either be a scalar or vector of
%   size N 
%

% handle input
if ~isvector(y)
    error('y must be 1D vector');
end

if (isvector(gain) && length(gain) == N) || length(gain)==1
    gain = gain(:);
elseif ndims(gain) > 2 || length(gain) ~= N
    error('gain must either be double or vector of size N');
end


% force into first axis
y = y(:);
len_y = length(y);

% determine ripple distance
ripple_length = round(fs / ripple_fs); 

% zero padding
y = [y' zeros(1,N*ripple_length + 1)];

% creatae attenuated copies and then delay
delays = gain .* repmat(y,[N,1]);
ishift = [1:N]' .* ripple_length;
for shift = 1:N
    delays(shift,:) = circshift(delays(shift,:), ishift(shift));
end


y = mean([y; delays],1);
out = y(1:len_y);


end
