function [H] = melBank(fftLen, numFilters, minF, maxF, fs)
%MELBANK Create mel-scale filter bank.
%
% Inputs:       fftLen      length of fft
%               numFilters  number of filters to be used in filter bank
%               minF        minimum frequency in Hz
%               maxF        maximum frequency in Hz
%               fs          sample frequency
%
% Output:       H           a matrix containing the filterbank amplitudes.
%
% Usage:        To compute the mel-scale spectrum of a column-vector s:
%
%               sDFT = fft(s);
%               sPS = (1/length(sDFT))*(abs(sDFT)^2);
%               H = melBank(length(sDFT), 20, 2, 2e4, 1.5e3);
%               filterBanks = H*sPS;
%               fbdB = 20*log10(filterBanks);
             
% Define conversion functions.
toMel = @(f) 2595*log10(1 + f/700);
toFreq = @(m) 700*(10.^(m/2595) - 1);

% Separate into evenly-spaced bin in mel-scale.
melMinF = toMel(minF);
melMaxF = toMel(maxF);
mels = linspace(melMinF, melMaxF, numFilters + 2);
% Convert back.
freqs = toFreq(mels);

% Compute which fft indices the freqs correspond to.
iFFT = round(floor(fftLen/2)/(fs/2)*freqs + 1);

% Create filterbanks.
H = zeros(numFilters, ceil(fftLen/2));
for iFilter = 2:numFilters+1
    % Find frequencies associated with triangle filter..
    iLeft = iFFT(iFilter - 1);
    iCenter = iFFT(iFilter);
    iRight = iFFT(iFilter + 1);
    % Calculate left half of filter..
    for i = iLeft:(iCenter-1)
        H(iFilter-1, i) = (i - iLeft)/(iCenter - iLeft);
    end
    % Calculate right half of filter..
    for i = iCenter:(iRight-1)
        H(iFilter-1, i) = (iRight - i)/(iRight - iCenter);
    end
end
H = sparse(H);
end

