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
MFCC2 = mfcc(audioIn,fs);

% Visualize cluster..
figure;
scatter3(MFCC1(1,:),MFCC1(2,:),MFCC1(3,:))
xlabel('MFCC 1');ylabel('MFCC 2'); zlabel('MFCC 3');