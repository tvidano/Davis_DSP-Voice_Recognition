%{
Main script for MATLAB Project voice_recognition

Authors: Tanuj Kalakuntla, Trevor Vidano
Date: 03/20/2021

In accordance with the completion of UC Davis' EEC 201: Digital Signal
Processing.
%}
clc; clearvars; close all;

% Build Codebook for each Train Data
numClusters = uint8(8);
numFilters = uint8(32);
numMFCCs = uint8(12);
numTrain = 11;
TrainDir = fullfile('Data','Training_Data');
codeBooks = cell(numTrain,1);
for i = 1:numTrain
    filename = 's' + string(i) + '.wav';
    path = fullfile(TrainDir,filename);
    MFCCs = speechpreprocess(path,numFilters,false);
    [idx,C,sumd] = kmeans(MFCCs(2:numMFCCs+1,:)',numClusters,...
                          'Replicates',20,'MaxIter',80);
    codeBooks{i} = C;
end

% Classify Test Data
numTest = 8;
TestDir = fullfile('Data','Test_Data');
testMatch = zeros(8,1);
rng(22);
TestCases = [(1:8)',randperm(8)'];

for i = 1:numTest
    filename = 's' + string(TestCases(i,2)) + '.wav';
    path = fullfile(TestDir,filename);
    MFCCs = speechpreprocess(path,numFilters,false);
    MFCCs = MFCCs(2:numMFCCs+1,:);
    
    lowestDist = inf;
    iLowest = 0;
    for j = 1:numTrain
        [nearestCentrDist,idx_test] = pdist2(codeBooks{j},MFCCs',...
                                             'euclidean','Smallest',1);
        dist = mean(nearestCentrDist);
        if dist < lowestDist
            lowestDist = dist;
            iLowest = j;
        end
    end
    testMatch(i) = iLowest;
end 

% Compute error statistics
accuracy = mean(TestCases(:,2)==testMatch);
fprintf('Accuracy = %.1f %% \n',accuracy*100);

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