function [] = speechpreprocess(path, playPlot)
%SPEACHPREPROCESS Reads a sound file and converts to MFCC sequence.
%
% Inputs:           path    string, filepath to sound file
%                   plots   logical, plot the signal in time domain
%
% Outputs:
%
% Usage:

% check valid data types
assert(isstring(path)||iscellstr(path)||ischar(path),...
    ['path variable is not type string array, cell array of character',...
    'vectors, or character array.'])
assert(islogical(playPlot),'plot variable is not type logical.')

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

% Plot audio in time domain
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

% Frame blocking
frameLen = 256;
frameDelay = 100;
xLen = length(x);
numFrames = floor((xLen - frameLen)/frameDelay) + 1;
frames = zeros(frameLen, numFrames);
iSample = 1;
frameNum = 1;
while (iSample < xLen)
    frames(:,frameNum) = x(iSample:iSample+frameLen-1);
    iSample = iSample + frameDelay;
    frameNum = frameNum + 1;
end

end