function [MFCCs] = speechpreprocess(path, numFilters, numCoeffs, playPlot)
%SPEACHPREPROCESS Reads a sound file and converts to MFCC sequence.
%
% Inputs:           path        string, filepath to sound file
%                   plots       logical, plot the signal in time domain
%                   numFilters  number of filters in the mel-freq. bank
%                   numCoeffs   number of ceptral coefficients to keep
%
% Outputs:
%
% Usage:

% check valid data types
assert(isstring(path)||iscellstr(path)||ischar(path),...
    ['path variable is not type string array, cell array of character',...
    'vectors, or character array.'])
assert(islogical(playPlot),'plot variable is not type logical.')
assert(isinteger(numFilters), 'numFilters variable is not type integer.')

[x, fs] = audioread(path);

% Peak Normalization
if size(x,2) == 1
    peak = max(abs(x));
    x = x/peak;
elseif size(x,2) == 2
    % Convert Stereo to Mono
    xMono = x(:,1) + x(:,2);
    peak = max(abs(xMono));
    xMono = xMono/peak;
    
    peakL = max(abs(x(:,1)));
    peakR = max(abs(x(:,2)));
    stereoPeak = max([peakL, peakR]);
    
    xMono = xMono*stereoPeak;
    x = xMono;
elseif size(x,2) > 2
    error('speachpreprocess:tooManyChannels',...
        'Error. \nAudio file must contain 1 or 2 channels, not %i',...
        size(x,2));
end

% Get ground-truth Spectrogram..
% figure;
% S = melSpectrogram(x,fs);
% [numBands,numFrames] = size(S);
% fprintf('Num bands: %d\n',numBands);
% fprintf('Num frames: %d\n',numFrames);
% melSpectrogram(x,fs);

% Plot audio in time domain and play audio
if playPlot
    xLen = length(x);
    t = 0:1/fs:xLen/fs-1/fs;
    
    figure;
    plot(t,x');
    title('Audio File in Time Domain');
    xlabel('Time [s]');
    ylabel('Amplitude');
    grid on;
    
    numMs = 256/fs*1000;
    fprintf('There are %.2f ms of speech in 256 samples.\n',numMs);
    
    % Play audio file
    sound(x,fs);
end

% Pre-Emphasis Filter
% alpha = 0.95;
% x = x - alpha*[x(2:end);0];

% Compute CFCC
frameDuration = 25; % ms
strideDuration = 10; % ms
frameLen = round(frameDuration*10^-3*fs);
frameDelay = round(strideDuration*10^-3*fs);
xLen = length(x);
numFrames = ceil((xLen - frameLen)/frameDelay) + 1;
% zero pad signal to be exactly numFrames long
padLen = numFrames*frameDelay + frameLen;
x = [x;zeros(padLen - xLen,1)];
xLen = length(x);

hammingWindow = hamming(frameLen,'periodic');
H = melBank(frameLen, numFilters, 0, fs/2, fs);
% figure; plot(linspace(0,fs/2,length(H)),H); title('Mel Filter Banks');

melSpectrums = zeros(numFilters, numFrames);
MFCCs = zeros(numCoeffs, numFrames);
iSample = 1;
iFrame = 1;
while (iFrame <= numFrames)
    % Frame blocking
    frame = x(iSample:iSample+frameLen-1);
    % Window each frame
    y = frame.*hammingWindow;
    % Compute fourier spectrum and power spectrum
    yDFT = fft(y);
    yDFT = yDFT(1:ceil(frameLen/2));
    yPS = (1/xLen)*abs(yDFT).^2;
    % Compute mel-frequency spectrum
	filterBanks = H*yPS;
    MFS = 20*log10(filterBanks);
    MFS = MFS - mean(MFS);
    % Apply DCT..
    MFCC = dct(MFS);
    MFCC = MFCC(2:numCoeffs+1);
    MFCC = MFCC - mean(MFCC);
    
    % Store
    melSpectrums(:,iFrame) = MFS;
    MFCCs(:,iFrame) = MFCC;
    
    iSample = iSample + frameDelay;
    iFrame = iFrame + 1;
end

% Visualize
% t = linspace(0,xLen/fs,numFrames);
% f = linspace(0,fs/2,numFilters);
% figure; surf(t,f,melSpectrums, 'EdgeColor', 'none');
% cBar = colorbar; ylabel(cBar, 'Power (dB)');
% view(0,90); xlabel('Time [s]'); ylabel('Frequency [Hz]');
% axis tight;

% coeffs = 2:numCoeffs+1;
% figure; surf(t,coeffs,MFCCs, 'EdgeColor', 'none');
% cBar = colorbar; ylabel(cBar, 'Power (dB)');
% view(0,90); xlabel('Time [s]'); ylabel('MFCC Number');
% axis tight;

end