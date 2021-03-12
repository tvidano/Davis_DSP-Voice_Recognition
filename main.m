%{
Main script for MATLAB Project voice_recognition

Authors: Tanuj Kalakuntla, Trevor Vidano
Date: 03/20/2021

In accordance with the completion of UC Davis' EEC 201: Digital Signal
Processing.
%}
clc; clearvars; close all;
path = fullfile('Data','Test_Data','s7.wav');
speechpreprocess(path,uint8(32),uint8(12),false)