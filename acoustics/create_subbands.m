function subbands = create_subbands(y, fs, fs_new, passbands)
%
%   subbands = create_subbands(y, fs, fs_new, passbands)
%
% filters input signal into N passbands with a third-order zero phase
% butterworth filter
% N is length(passbands)-1, where passbands is a 1D vector indicating
% the boundaries of all passbands
%

% handle input
if ~isvector(y)
    error('input signal must be vector');
else
    y = y(:);
end

if isempty(fs_new)
    doresample = false;
elseif ~isempty(fs_new) || fs ~= fs_new
    doresample = true;
else
    doresample = false;
end

if ~isvector(passbands)
    error('input signal must be vector');
else
    passbands = passbands(:);
end


% demean signal 
y = y - mean(y);

% input matrix
L = length(y);
N = length(passbands) - 1;
subbands = zeros(L,N);
 
for k = 1:N
    [b,a] = butter(3,2*[passbands(k) passbands(k+1)]/fs);
    tmp = filtfilt(b,a,y);
    subbands(:,k) = tmp;
end


% resample signal
if doresample == true
    subbands = resample(subbands,fs,fs_new);
end


end

