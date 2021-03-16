function [MFCCs] = speechpreprocess(x, fs, numFilters, ...
                                    frameDuration, strideDuration, ...
                                    istest)
%SPEACHPREPROCESS Reads a sound file and converts to MFCC sequence.
%
% Inputs:       x               audio sample
%               numFilters      number of filters in the mel-freq. bank
%               frameDuration   length of frame in ms
%               strideDuration  millisec. to slide each frame forward
%               istest          logical, make plots for testing
%
% Outputs:
%
% Usage:

% check valid data types
assert(isnumeric(x),'sample variable is not type numeric.')
assert(islogical(istest),'plot variable is not type logical.')
assert(isnumeric(numFilters), 'numFilters variable is not type numeric.')

% Assign default values to empty variables
if isempty(numFilters)
    numFilters = 32;
elseif isempty(frameDuration)
    frameDuration = 25;
elseif isempty(strideDuration)
    strideDuration = 10;
end

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

% Pre-Emphasis Filter
alpha = 0.95;
x = x - alpha*[x(2:end);0];

% Compute CFCC
frameLen = round(frameDuration*10^-3*fs); % samples
frameDelay = round(strideDuration*10^-3*fs); % samples
xLen = length(x);
numFrames = ceil((xLen - frameLen)/frameDelay) + 1;
% zero pad signal to be exactly numFrames long
padLen = numFrames*frameDelay + frameLen;
x = [x;zeros(padLen - xLen,1)];
xLen = length(x);

hammingWindow = hamming(frameLen,'periodic');
H = melBank(frameLen, numFilters, 0, fs/2, fs);

spectrums = zeros(ceil(frameLen/2), numFrames);
melSpectrums = zeros(numFilters, numFrames);
% MFCCs = zeros(numCoeffs, numFrames);
MFCCs = zeros(numFilters, numFrames);
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
    yPS = (1/length(yDFT))*abs(yDFT).^2;
%     yPS = abs(yDFT).^2;
    % Compute mel-frequency spectrum
% 	filterBanks = H*yPS;
    filterBanks = abs(H).^2*yPS;
    MFS = db(filterBanks);
%     MFS = MFS - mean(MFS);
    % Apply DCT..
    MFCC = dct(MFS);
%     MFCC = MFCC(2:numCoeffs+1);
    MFCC = (MFCC - mean(MFCC))/std(MFCC);
    
    % Store
    spectrums(:,iFrame) = yPS;
    melSpectrums(:,iFrame) = MFS;
    MFCCs(:,iFrame) = MFCC;
    
    iSample = iSample + frameDelay;
    iFrame = iFrame + 1;
end

% Test 2: Plot audio in time domain and play audio
if istest
    % Plot Audio in Time Domain
    xLen = length(x);
    t = 0:1/fs:xLen/fs-1/fs;
    
    figure;
    plot(t,x');
    title('Test 2: Audio File in Time Domain');
    xlabel('Time [s]');
    ylabel('Amplitude');
    grid on;
    
    % Calculate number of ms in 256 samples..
    numMs = 256/fs*1000;
    fprintf('Test 2: There are %.2f ms of speech in 256 samples.\n',numMs);
    
    % Play audio file
    sound(x,fs);
    
    % Test 3 Plot Mel Filter Banks
    figure;
    plot(linspace(0,fs/2,length(H)),H); 
    title('Mel Filter Banks'); xlabel('Freq [Hz]'); ylabel('Amplitude');
    
    % Test 4 Visualize Spectrogram
    t = linspace(0,xLen/fs,numFrames);
    f = linspace(0,fs/2,ceil(frameLen/2));
    figure; surf(t,f,spectrums, 'EdgeColor', 'none');
    cBar = colorbar; ylabel(cBar, 'Power (dB)');
    title('Test 4: Spectrogram Before Mel-freq Wrapping')
    view(0,90); xlabel('Time [s]'); ylabel('Frequency [Hz]');
    axis tight;
    
    % Test 4 Visualize Mel Spectrogram
    t = linspace(0,xLen/fs,numFrames);
    f = linspace(0,fs/2,numFilters);
    figure; surf(t,f,melSpectrums, 'EdgeColor', 'none');
    cBar = colorbar; ylabel(cBar, 'Power (dB)');
    title('Test 4: Spectrogram After Mel-freq Wrapping')
    view(0,90); xlabel('Time [s]'); ylabel('Frequency [Hz]');
    axis tight;
    
    % Test 5 Visualize MFCCs
    coeffs = 2:length(MFCCs);
    coeffs = 1:size(MFCCs,1);
    figure; surf(t,coeffs,MFCCs, 'EdgeColor', 'none');
    title('Test 5: Cepstrogram, Spectrogram of MFCCs')
    cBar = colorbar; ylabel(cBar, 'Power (dB)');
    view(0,90); xlabel('Time [s]'); ylabel('MFCC Number');
    axis tight;
end

end