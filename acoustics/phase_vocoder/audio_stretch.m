function Yout = audio_stretch(X,window,overlap,Fs,len_fac)
% Y = stretch_audio(X,window,overlap,Fs,len_fac)
%
%


% compute the analysis and synthesis overlap to generate sound output with
% stretched or compressed by the factor len_fac

% analysis
[Pxx,Mag,Phase] = periodogram_analysis(X,window,overlap,Fs);


% synthesis
Yout = periodogram_synthesis(Pxx,Mag,Phase,window,overlap);

end
