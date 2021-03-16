%{
Main script for MATLAB Project voice_recognition

Authors: Tanuj Kalakuntla, Trevor Vidano
Date: 03/20/2021

In accordance with the completion of UC Davis' EEC 201: Digital Signal
Processing.
%}
clc; clear all; close all;

% Collect Training Data
numSpeakers = 11;
TrainDir = fullfile('Data','Training_Data');
TrainDataBase = cell(1,numSpeakers);
for i = 1:numSpeakers
    filename = 's' + string(i) + '.wav';
    [audio,Fs] = audioread(fullfile(TrainDir,filename));
    TrainDataBase{i} = {audio,Fs};
end 

% Build Codebook for each Train Data
numClusters = 8;
numFilters = 32;
numCoeffs = 12;
frameDuration = 25;
strideDuration = 10;

classifier = speakerClassifier(numClusters,numFilters,numCoeffs,...
                               frameDuration,strideDuration);
codeBooks = classifier.train(TrainDataBase);

% Collect Test Data
TestDir = fullfile('Data','Test_Data');
TestDataBase = cell(1,8);
TestCases = [(1:8)',randperm(8)'];
for i = 1:8
    filename = 's' + string(TestCases(i,2)) + '.wav';
    [audio,Fs] = audioread(fullfile(TestDir,filename));
    TestDataBase{i} = {audio,Fs};
end

% Classify Test Data

testMatch = classifier.classify(TestDataBase);

% Compute error statistics
accuracy = mean(TestCases(:,2)==testMatch);
fprintf('Accuracy = %.1f %% \n',accuracy*100);

%test functionality
status = classifier.test(TrainDataBase,32,25,10,numClusters)

% path = fullfile('Data','Test_Data','s7.wav');
% MFCC1 = speechpreprocess(path,uint8(32),uint8(12),false);
% [audioIn, fs] = audioread(path);
% MFCC2 = mfcc(audioIn,fs,'LogEnergy','Ignore');
% 
% [idx,C,sumd] = kmeans(MFCC1(2:end,:)',numClusters,'Replicates',20,'MaxIter',80);
% 
% clusterFit = zeros(numClusters,1);
% for i = 1:numClusters
%     clusterFit(i) = sumd(i)/sum(idx==i);
% end
% clusterFit

% Visualize cluster..
% figure; hold on;
% scatter(MFCC1(2,:),MFCC1(3,:))
% scatter(C(:,1),C(:,2),'kx');
% hold off;
% xlabel('MFCC 2');ylabel('MFCC 3'); zlabel('MFCC 4');

% figure;
% scatter3(MFCC2(:,1),MFCC2(:,2),MFCC2(:,3))
% xlabel('MFCC 2');ylabel('MFCC 3'); zlabel('MFCC 4');