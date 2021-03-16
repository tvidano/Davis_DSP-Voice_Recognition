function [testData,trainData] = loadRoommatesData(path)
%LOADROOMMATESDATA Loads data and performs some pre-processing.
%
% Inputs    path            path to roommates audio recording dataset.
%
% Outputs   testData        cell array containing audio samples for
%                           training
%           trainData       cell array containing audio samples for testing

trainData = cell(4,1);
testData = cell(4,1);
for i = 1:4
    trainPath = 's' + string(i) + 'Train.wav';
    [audio,Fs] = audioread(fullfile(path,trainPath));
    trainData{i} = {audio,Fs};
    testPath = 's' + string(i) + 'Test.wav';
    [audio,Fs] = audioread(fullfile(path,testPath));
    testData{i} = {audio,Fs};
end
end

