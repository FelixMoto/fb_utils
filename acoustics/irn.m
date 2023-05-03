function rippled_noise = irn(stim_length,stim_fs,ripple_fs,N,gain)
%
%   rippled_noise = irn(stim_length,stim_fs,ripple_fs,N,gain)
%
% creates iterated rippled unfiltered gaussian noise of desired length 
%
% inputs:
%   stim_length - length of noise in seconds
%   stim_fs - desired sample rate
%   ripple_fs - determines the pitch frequency
%   N - number of iterations
%   gain - determindes the factor by which the delays are multiplied
%

% handle input
if length(gain) ~= N && length(gain) ~= 1
    error('gain must either of size N or a single value');
end

if isvector(gain)
    gain = gain(:);
end


% determine stim length and ripple distance
y_length = stim_length * stim_fs;
ripple_length = round(stim_fs / ripple_fs); 

% create padded gaussian noise
noise = [randn(1,y_length) zeros(1,N*ripple_length + 1)];


% creatae attenuated delays
delays = gain .* repmat(noise,[N,1]);
ishift = [1:N]' .* ripple_length;
for shift = 1:N
    delays(shift,:) = circshift(delays(shift,:), ishift(shift));
end

rippled_noise = mean([noise; delays],1);
rippled_noise = rippled_noise(1:y_length);

end