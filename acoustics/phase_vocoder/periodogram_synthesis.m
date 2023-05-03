function Y = periodogram_synthesis(Pxx,Mag_In,Phase_In,window,overlap)
% Y = periodogram_synthesis(Pxx,window,overlap,Fs)
%
%


% check inputs
if mod(window,2) ~= 0
    nfft2 = (window+1)/2;
else
    nfft2 = window/2+1;
end

[nfft,nstep] = size(Pxx);
hopsize = window - overlap;

% creat output variable
Y_len = nstep*hopsize + overlap;
Y = zeros(Y_len,1);

for istep = 1:nstep
    xfft = Pxx(:,istep);
    mag_step = Mag_In(:,istep);
    phase_step = Phase_In(:,istep);

    compl = mag_step .* exp(sqrt(-1)*phase_step);
    compl(nfft2) = xfft(nfft2);
    compl = [compl; fliplr(conj(compl(2:nfft2)))];
    wave = real(ifft(compl));
    
    % get indices for each window
    indout = round( ((istep-1)*hopsize+1):((istep-1)*hopsize+nfft));
    % overlap and add
    Y(indout,1) = Y(indout,1) + wave;
end

Y = 0.8*Y/max(max(abs(Y)));

end
