function [testData,trainData] = loadVoxCeleb(path,samplePerSpeaker)
%LOADVOXCELEB Loads data from voxCeleb wav files
%
% Inputs    path                path to voxCeleb directory
%           samplePerSpeaker    number of test and train samples per
%                               speaker
%
% Outputs   testData            cell array containing audio samples for
%                               training
%           trainData           cell array containing audio samples for
%                               training

% Get number of available speakers
voxFiles = dir(path);
speakerDirs = getSubDirs(voxFiles);
numSpeakers = length(speakerDirs);
% Get recording events for each speaker, and each audio sample
voxItems = cell(numSpeakers,1);
for i = 1:numSpeakers
    speakerDir = speakerDirs(i);
    speakerPath = fullfile(path,speakerDir.name);
    speakerFiles = dir(speakerPath);
    speakerEvents = getSubDirs(speakerFiles);
    numEvents = length(speakerEvents);
    voxItems{i} = cell(numEvents,1);
    for j = 1:numEvents
        eventDir = speakerEvents(j);
        eventPath = fullfile(speakerPath,eventDir.name);
        samples = dir(eventPath);
        fileFlag = ~[samples.isdir];
        samples = samples(fileFlag);
        numSamples = length(samples);
        % Create string array of each sample wav file
        samplePaths = strings(numSamples,1);
        for k = 1:numSamples
            samplePaths(k) = fullfile(eventPath,samples(k).name);
        end
        voxItems{i}{j} = samplePaths;
    end
end

% Build test and train data from randomly selecting an event and sample of
% each event
testData = cell(numSpeakers,1);
trainData = cell(numSpeakers,1);
for i = 1:numSpeakers
    numEvents = length(voxItems{i});
    samplePop = 1:numEvents;
    % Remove any events with insufficient number of audio samples
    for j = 1:numEvents
        if length(voxItems{i}{j}) < samplePerSpeaker
            samplePop = samplePop(samplePop~=j);
        end
    end
    if samplePop < 2
        error(['Unable to find 2 events with %.0f samples each for ',...
               'every speaker'],samplePerSpeaker);
    end
    eventSample = randsample(samplePop,2);
    testEvent = eventSample(1);
    trainEvent = eventSample(2);
    testPaths = randsample(voxItems{i}{testEvent},samplePerSpeaker);
    trainPaths = randsample(voxItems{i}{trainEvent},samplePerSpeaker);
    % Collect audio data
    for k = 1:samplePerSpeaker
        [testSample,testFs] = audioread(testPaths(k));
        testData{i} = [testData{i};testSample];
        [trainSample,trainFs] = audioread(trainPaths(k));
        trainData{i} = [trainData{i};trainSample];
    end
    testData{i} = {testData{i},testFs};
    trainData{i} = {trainData{i},trainFs};
end
end

