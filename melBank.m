function [H] = melBank(fftLen, numFilters, minF, maxF, fs)
%MELBANK Create mel-frequency filter bank
%   Detailed explanation goes here
% Define conversion functions.
toMel = @(f) 1125*log(1 + f/700);
toFreq = @(m) 700*(exp(m/1125) - 1);

% Separate into evenly-spaced bin in mel-scale.
melMinF = toMel(minF);
melMaxF = toMel(maxF);
numMels = numFilters + 2;
mels = linspace(melMinF, melMaxF, numMels);
% Convert back.
freqs = toFreq(mels);

% Compute which fft indices freqs correspond to.
iFFT = floor((fftLen + 1)*freqs/fs);

% Create filterbanks.
H = zeros(numFilter, fftLen);
for filter = 1:numFilters
    % Compute left-half triangle freq. gains
    % Compute right-half traingle freq. gains
    % Combine left and right half.
    % Store filter in row
end

end

