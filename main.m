%{
Main script for MATLAB Project voice_recognition

Authors: Tanuj Kalakuntla, Trevor Vidano
Date: 03/20/2021

In accordance with the completion of UC Davis' EEC 201: Digital Signal
Processing.
%}
clc; clear all; close all;

%% Collect Training Data
numSpeakers = 11;
TrainDir = fullfile('Data','Training_Data');
TrainDataBase = cell(1,numSpeakers);
for i = 1:numSpeakers
    filename = 's' + string(i) + '.wav';
    [audio,Fs] = audioread(fullfile(TrainDir,filename));
    TrainDataBase{i} = {audio,Fs};
end 

%% Build Codebook for each Train Data
numClusters = 8;
numFilters = 32;
numCoeffs = 12;
frameDuration = 25;
strideDuration = 10;
% Build classifier and train on TrainDataBase..
classifier = speakerClassifier(numClusters,numFilters,numCoeffs,...
                               frameDuration,strideDuration);
codeBooks = classifier.train(TrainDataBase);

%% Collect Test Data
TestDir = fullfile('Data','Test_Data');
TestDataBase = cell(1,8);
TestCases = [(1:8)',randperm(8)'];
for i = 1:8
    filename = 's' + string(TestCases(i,2)) + '.wav';
    [audio,Fs] = audioread(fullfile(TestDir,filename));
    TestDataBase{i} = {audio,Fs};
end

%% Classify Test Data
[testMatch,err] = classifier.classify(TestDataBase);

% Compute error statistics
accuracy = mean(TestCases(:,2)==cell2mat(testMatch));
fprintf('With Train/Test dataset provided: ');
fprintf('Accuracy = %.1f %% \n',accuracy*100);

%% Test Functionality
classifier.test(TrainDataBase)

%% Test with New Voices (roommates)
roommatesDir = fullfile('Data','Roommates');
[roomTest,roomTrain] = loadRoommatesData(roommatesDir);

roomClassifier = speakerClassifier();
[~] = roomClassifier.train(roomTrain);
[roomMatch,err1] = roomClassifier.classify(roomTest);