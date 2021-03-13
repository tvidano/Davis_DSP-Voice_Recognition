%{
Main script for MATLAB Project voice_recognition

Authors: Tanuj Kalakuntla, Trevor Vidano
Date: 03/20/2021

In accordance with the completion of UC Davis' EEC 201: Digital Signal
Processing.
%}
clc; clearvars; close all;
path = fullfile('Data','Test_Data','s7.wav');
MFCC1 = speechpreprocess(path,uint8(32),uint8(12),false);
[audioIn, fs] = audioread(path);
MFCC2 = mfcc(audioIn,fs,'LogEnergy','Ignore');

% Visualize cluster..
figure;
scatter3(MFCC1(2,:),MFCC1(3,:),MFCC1(4,:))
xlabel('MFCC 2');ylabel('MFCC 3'); zlabel('MFCC 4');
figure;
scatter3(MFCC2(:,1),MFCC2(:,2),MFCC2(:,3))
xlabel('MFCC 2');ylabel('MFCC 3'); zlabel('MFCC 4');