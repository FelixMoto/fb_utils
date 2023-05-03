function [Pxx,Magnitude_out,Phase_out] = periodogram_analysis(X,window,overlap,Fs)
% Pxx = get_periodogram(X,window,overlap,Fs)
%
% work in progress
% function to compute spectra in slding windows
%

% check inputs
if mod(window,2) ~= 0
    nfft2 = (window+1)/2;
else
    nfft2 = window/2+1;
end

% parameters
max_peak = 50;
eps_peak = 0.005;

hopsize = window - overlap;
dtin = window / Fs;
dtout = dtin * 1.2; % just to test things

phold = zeros(1,overlap);
phadvance = zeros(1,overlap);
all2pi = 2*pi*[0:100];

xlen = length(X);
win = hanning(window);
f = Fs*(0:(window/2))/window;


% determine number of windowing steps
nstep = 1 + floor((xlen-window)/hopsize);

% pad end with last digit
%overhang = xlen - (window+(nstep-1)*overlap);
overhang = window - xlen + (nstep * hopsize);
if overhang > 0
    pad = ones(hopsize,1) .* X(end);
    X = [X; pad];
    nstep = nstep + 1;
end

% output variables
Pxx = zeros(window,nstep);
Magnitude_out = zeros(nfft2,nstep);
Phase_out = zeros(nfft2,nstep);

for istep = 1:nstep
    % index and attenuate window
    idx = [1:window] + (istep-1) * hopsize;
    xwin = X(idx) .* win;
    
    % spectrum
    xfft = fft(xwin);
    % magnitude and phase
    x_mag_in = abs(xfft(1:nfft2));
    x_phase_in = angle(xfft(1:nfft2));
    
    % find and sort peaks in spectrum
    peaks = findPeaks4(x_mag_in,max_peak,eps_peak,f);
    [~,ind_s] = sort(x_mag_in(peaks(:,2)));
    peaksort = peaks(ind_s,:);
    p_center = peaksort(:,2);
    
    % improved frequency estimation
    bestf = zeros(size(p_center));
    for ipeak = 1:length(p_center)
        d_theta = x_phase_in(p_center(ipeak)) - phold(1,p_center(ipeak)) + all2pi;
        fest = d_theta ./ (2*pi*dtin);
        [~,indf] = min(abs(f(p_center(ipeak)) - fest));
        bestf(ipeak) = fest(indf);
    end
    
    % generate output magnitude and phase
    x_mag_out = x_mag_in;
    x_phase_out = x_phase_in;
    for ipeak = 1:length(p_center)
        fdes = bestf(ipeak);
        freq_ind = [peaksort(ipeak,1):peaksort(ipeak,3)];
        
        x_mag_out(freq_ind) = x_mag_in(freq_ind);
        % dtin was dtout originally !
        phadvance(1,peaksort(ipeak,2)) = phadvance(1,peaksort(ipeak,2)) + 2*pi*fdes*dtin;
        pi_zero = pi*ones(1,length(freq_ind));
        pcent = peaksort(ipeak,2) - peaksort(ipeak,1) + 1;
        ind_p_center = [(2 - mod(pcent,2)) : 2 : length(freq_ind)];
        pi_zero(ind_p_center) = zeros(1,length(ind_p_center));
        x_phase_out(freq_ind) = phadvance(1,peaksort(ipeak,1)) + pi_zero;
    end
    
    
    Pxx(:,istep) = xfft;
    Magnitude_out(:,istep) = x_mag_out;
    Phase_out(:,istep) = x_phase_out;
end

end
